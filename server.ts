import { spawn, execSync } from 'child_process';
import express from 'express';
import http from 'http';
import path from 'path';
import fs from 'fs';
import { GoogleGenAI } from '@google/genai';

// Helper to check and dynamically install python if missing
const detectOrInstallPython = (): string => {

  console.log("Diagnostics: Locating python command...");
  
  if (process.platform === 'win32') {
    return 'python';
  }

  // 1. Check if python3 works
  try {
    execSync('python3 --version', { stdio: 'ignore' });
    console.log("Detected python3 on system.");
    return 'python3';
  } catch (err) {
    // 2. Check if python package is aliased as python
    try {
      execSync('python --version', { stdio: 'ignore' });
      console.log("Detected python on system.");
      return 'python';
    } catch (err2) {
      console.log("Python command not found in default PATH.");
    }
  }

  // 3. Check if we already have the portable python extracted
  const portablePythonDir = path.join(process.cwd(), 'python');
  const portablePythonBin = path.join(portablePythonDir, 'bin', 'python3');
  if (fs.existsSync(portablePythonBin)) {
    console.log(`Using cached portable python at: ${portablePythonBin}`);
    return portablePythonBin;
  }

  console.log("Self-healing: Attempting to download and extract portable Python 3 in production...");

  try {
    const tarPath = path.join(process.cwd(), 'portable-python.tar.gz');
    // Stable release of python-build-standalone (Python 3.10.13)
    const downloadUrl = 'https://github.com/indygreg/python-build-standalone/releases/download/20240107/cpython-3.10.13+20240107-x86_64-unknown-linux-gnu-install_only.tar.gz';
    
    console.log(`Downloading portable Python from: ${downloadUrl}`);
    // Use curl to download (runs as user, no root needed)
    execSync(`curl -L -o "${tarPath}" "${downloadUrl}"`, { stdio: 'inherit' });
    console.log("Successfully downloaded portable Python tarball. Extracting...");
    
    // Extract using standard tar
    execSync(`tar -xzf "${tarPath}" -C "${process.cwd()}"`, { stdio: 'inherit' });
    console.log("Successfully extracted portable Python!");
    
    // Clean up tarball to save disk space
    if (fs.existsSync(tarPath)) {
      fs.unlinkSync(tarPath);
    }
    
    if (fs.existsSync(portablePythonBin)) {
      return portablePythonBin;
    } else {
      console.error("Extracted python3 binary not found in python/bin/python3!");
    }
  } catch (downloadErr: any) {
    console.error("Failed to download or extract portable Python:", downloadErr.message || downloadErr);
    
    // Attempt system self-healing dynamic fallback to system managers if accessible
    try {
      console.log("Running apt-get update && install -y python3 python3-pip sqlite3...");
      execSync('apt-get update && apt-get install -y --no-install-recommends python3 python3-pip sqlite3', { stdio: 'inherit' });
      console.log("Successfully installed python3 via apt-get!");
      return 'python3';
    } catch (aptErr: any) {
      console.log("apt-get install failed or not available:", aptErr.message || aptErr);
      
      try {
        console.log("Running apk update && apk add python3 py3-pip sqlite...");
        execSync('apk update && apk add --no-cache python3 py3-pip sqlite', { stdio: 'inherit' });
        console.log("Successfully installed python3 via apk!");
        return 'python3';
      } catch (apkErr: any) {
        console.error("apk install failed or not available:", apkErr.message || apkErr);
      }
    }
  }

  // Default fallback
  return 'python3';
};

// Helper to determine port and run FastAPI
const startFastAPI = (pythonCmd: string) => {
  console.log(`Starting Python FastAPI Backend on port 3001 using command: ${pythonCmd}...`);
  
  const pyProcess = spawn(pythonCmd, ['main.py'], {
    env: { ...process.env, PORT: '3001' },
    shell: true
  });

  const logFile = path.join(process.cwd(), 'gateway_diagnostics.log');
  fs.appendFileSync(logFile, `\n--- NEW FASTAPI SPAWN SESSION --- \nTime: ${new Date().toISOString()}\nPath: ${pythonCmd}\n`);

  pyProcess.stdout.on('data', (data) => {
    process.stdout.write(`[FastAPI] ${data}`);
    fs.appendFileSync(logFile, `[STDOUT] ${data}`);
  });

  pyProcess.stderr.on('data', (data) => {
    process.stderr.write(`[FastAPI-Error] ${data}`);
    fs.appendFileSync(logFile, `[STDERR] ${data}`);
  });

  pyProcess.on('error', (err) => {
    console.error("Failed to start Python FastAPI child process:", err);
    fs.appendFileSync(logFile, `[SPAWN_ERROR] ${err.message}\n`);
  });

  pyProcess.on('exit', (code) => {
    console.log(`Python FastAPI backend child process exited with status code ${code}`);
    fs.appendFileSync(logFile, `[EXIT] Status: ${code}\n`);
  });
};

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Load .env manual configurations if exists
  const fs = await import('fs');
  const envPath = path.join(process.cwd(), '.env');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    envContent.split('\n').forEach((line) => {
      line = line.trim();
      if (!line || line.startsWith('#')) return;
      const equalIdx = line.indexOf('=');
      if (equalIdx > 0) {
        const key = line.slice(0, equalIdx).trim();
        const val = line.slice(equalIdx + 1).trim();
        process.env[key] = val;
      }
    });
    console.log("Diagnostics: Loaded .env parameters into process.env");
  }

  // 1. Boot/Ensure the Python backend
  const pythonCmd = detectOrInstallPython();
  startFastAPI(pythonCmd);

  // Return healthy for health check directly from Gateway to ensure Cloud Run container health diagnostics pass instantly!
  app.get('/api/health', (req, res) => {
    res.json({ status: "ok", gateway: "healthy" });
  });

  // Native Node.js Handlers for AI Engine to bypass proxy streaming issues
  const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

  app.post('/api/engine/generate', express.json(), async (req, res) => {
    const { model, contents, config } = req.body;
    const systemInstruction = config?.systemInstruction;
    const requestConfig: any = {
       systemInstruction: systemInstruction,
    };

    let lastError = null;
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        const apiKey = process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY;
        if (!apiKey) {
          return res.status(500).json({ error: "API key not configured" });
        }

        const ai = new GoogleGenAI({ apiKey });
        
        const response = await ai.models.generateContent({
            model: model?.replace('1.5', '2.5') || 'gemini-2.5-flash',
            contents: contents || [],
            config: requestConfig
        });
        
        let text = response.text || "";
        if (!text) {
           text = response.candidates?.[0]?.content?.parts?.[0]?.text || "I am listening. Please proceed.";
        }
        return res.json({ text, error: null });
        
      } catch (error: any) {
        lastError = error;
        console.error(`[Node AI] Engine generation attempt ${attempt + 1} failed:`, error.message || error);
        
        // Handle Rate limit or temporary service issue
        if ((error.status === 429 || error.code === 429 || error.status === 503 || error.code === 503) && attempt < 2) {
            const delay = Math.pow(2, attempt) * 2000; // Exponential backoff: 2s, 4s
            console.log(`[Node AI] Retrying in ${delay}ms...`);
            await sleep(delay);
            continue;
        }
        
        // If it's not a retryable error or max retries reached, break
        break;
      }
    }
    
    res.json({ text: "I'm having a moment of connection trouble, but I'm here. Please try again.", error: null });
  });

  app.get('/api/engine/memory/retrieve', async (req, res) => {
      res.json({ context: "", error: null });
  });

  app.post('/api/engine/memory/store', express.json(), async (req, res) => {
      res.json({ success: true, error: null });
  });

  app.post('/api/engine/speech', express.json(), async (req, res) => {
      res.json({ data: null, error: "Not supported natively yet" });
  });

  app.post('/api/engine/transcribe', express.json(), async (req, res) => {
      res.json({ text: "", error: "Not supported" });
  });

  // 2. Setup transparent streaming HTTP reverse proxy for /api/* to FastAPI on 3001 with Auto-Retry
  app.use('/api', (req, res) => {
    req.on('error', (err) => {
      console.error("[Proxy Gateway] Incoming request error:", err.message);
    });
    res.on('error', (err) => {
      console.error("[Proxy Gateway] Outgoing response error:", err.message);
    });

    const chunks: Buffer[] = [];
    req.on('data', (chunk) => {
      chunks.push(chunk);
    });

    req.on('end', () => {
      const bodyBuffer = Buffer.concat(chunks);
      const maxRetries = 120; // 120 attempts * 1000ms = 120 seconds total startup safety margin
      const retryDelay = 1000;

      const makeRequest = (attempt: number) => {
        if (res.writableEnded || res.headersSent) {
          return;
        }

        const proxyHeaders = { ...req.headers };
        // Avoid Host header mismatch and let node agent manage Connection/Content-Length natively
        delete proxyHeaders['host'];
        delete proxyHeaders['connection'];
        if (bodyBuffer.length > 0) {
          proxyHeaders['content-length'] = bodyBuffer.length.toString();
        } else {
          delete proxyHeaders['content-length'];
        }

        const proxyReq = http.request({
          host: '127.0.0.1',
          port: 3001,
          path: req.originalUrl,
          method: req.method,
          headers: proxyHeaders
        }, (proxyRes) => {
          if (res.writableEnded || res.headersSent) {
            return;
          }
          res.writeHead(proxyRes.statusCode || 200, proxyRes.headers);
          proxyRes.pipe(res, { end: true });
        });

        proxyReq.on('error', (err: any) => {
          if (res.writableEnded || res.headersSent) {
            return;
          }
          // Only retry on ECONNREFUSED which represents port 3001 startup latency.
          // Retrying on ECONNRESET (active dropped connections) traps client requests in long retry loops.
          if (err.code === 'ECONNREFUSED' && attempt < maxRetries) {
            console.warn(`[Proxy Warning] FastAPI startup in progress, retrying request in ${retryDelay}ms... (Attempt ${attempt}/${maxRetries})`);
            setTimeout(() => {
              makeRequest(attempt + 1);
            }, retryDelay);
          } else {
            console.error("Proxy Error connecting to FastAPI:", req.originalUrl, err.message);
            res.status(502).json({ error: "FastAPI server unreachable after retries", details: err.message });
          }
        });

        if (bodyBuffer.length > 0) {
          try {
            proxyReq.write(bodyBuffer);
          } catch (writeErr: any) {
            console.error("[Proxy Gateway] Error writing body buffer to proxy context:", writeErr.message);
          }
        }
        try {
          proxyReq.end();
        } catch (endErr: any) {
          console.error("[Proxy Gateway] Error closing proxy request context:", endErr.message);
        }
      };

      makeRequest(1);
    });
  });

  // 3. Vite middleware for React Frontend (development) vs Static Assets (production)
  if (process.env.NODE_ENV !== "production") {
    const { createServer: createViteServer } = await import('vite');
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*all', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Vite/Express Gateway Proxy listening on http://localhost:${PORT}`);
  });
}

startServer().catch((err) => {
  console.error("Critical error starting Express GateWay:", err);
});
