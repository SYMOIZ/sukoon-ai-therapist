<!-- Sukoon -->
<div align="center">

# Sukoon — your AI wellness companion

**Sukoon** (سکون) means *peace of mind*. It's a calm, private place to talk things through, any time of day.

[**Try it on Vercel**](https://sukoon-blue.vercel.app) · [**Try it on AWS**](https://www.sukoon.tech) · [How it works](#how-it-works) · [Run it locally](#run-it-locally)

![Sukoon landing page](docs/screenshots/00-hero.png)

</div>

> Sukoon is a wellness companion, not a clinical service. It does not diagnose and it does not replace a licensed therapist. If you are in crisis, please contact local emergency services. The chat screen has an **Emergency** button for that reason.

---

## Why we built Sukoon

Stress, anxiety and low mood don't keep office hours. At 2 a.m. there is usually no one to call, and booking a first appointment with a professional can feel like a big step.

We wanted a space that:

- **Listens right away.** Open the app and start typing. The AI companion answers in seconds, kindly and without judgement.
- **Helps you notice patterns.** A mood journal shows how your week really went.
- **Makes the next step easy.** When you're ready for a human, you can browse therapists and request a session in the same app.
- **Gives therapists and operators real tools,** so the people behind the platform can run it properly.

So Sukoon has three sides: one for **clients**, one for **therapists**, and one for **admins**.

---

## Try it in 30 seconds

1. Open **[sukoon-blue.vercel.app](https://sukoon-blue.vercel.app)** (or [www.sukoon.tech](https://www.sukoon.tech)).
2. Click **Log In**.
3. Under **Quick Demo Access**, choose **Client Demo**, **Therapist Demo** or **Admin Demo**. No password is needed.
4. As the client, open **Chat** and say hi.

![Live AI chat answered by Gemini](docs/screenshots/24-live-ai-chat-gemini.jpg)

*A real conversation on the live site, answered by Google Gemini.*

Client Demo is a sandbox. Chat and journal entries stay in your browser session, and actions that would create a permanent record (such as booking) ask you to sign up. Admin screens need a desktop-width window.

---

## What you can do

### As a client

| | |
|---|---|
| ![Client dashboard](docs/screenshots/03-client-dashboard.png) **Dashboard** — one place to chat, track your mood or find a therapist. | ![AI chat](docs/screenshots/04-client-ai-chat.png) **AI chat** — talk any time, day or night. |
| ![Mood journal](docs/screenshots/07-client-journal.png) **Mood journal** — log how you feel and look back over time. | ![Therapist directory](docs/screenshots/05-client-therapists.png) **Find a therapist** — browse profiles and specialties. |
| ![Notifications](docs/screenshots/16-notifications.png) **Notifications** — updates in one feed. | ![Settings](docs/screenshots/17-profile-settings.png) **Settings** — your profile and preferences. |

### As a therapist

| | |
|---|---|
| ![Therapist practice overview](docs/screenshots/08-therapist-dashboard.png) **Practice overview** — your practice at a glance. | ![Therapist calendar](docs/screenshots/11-therapist-appointments.png) **Calendar** — weekly schedule and session requests. |
| ![Patient registry](docs/screenshots/10-therapist-client-management.png) **Patient registry** — the clients you work with. | ![Therapist settings](docs/screenshots/09-therapist-profile.png) **Profile and settings** — how clients see you. |

### As an admin

| | |
|---|---|
| ![Admin analytics](docs/screenshots/12-admin-dashboard.png) **Analytics** — platform activity at a glance. | ![User management](docs/screenshots/13-admin-user-management.png) **User management** — search and manage accounts. |
| ![Therapist review](docs/screenshots/14-admin-therapist-review.png) **Therapist applications** — approve or reject new therapists. | ![Support tickets](docs/screenshots/15-admin-support-management.png) **Support desk** — answer tickets from users. |

### On your phone

<img src="docs/screenshots/18-responsive-mobile.png" alt="Sukoon on a phone-sized screen" width="320" />

The client app works on small screens. Admin tools are desktop-only on purpose.

---

## How it works

Sukoon runs in two places from the same code: **Vercel** (serverless) and **AWS** (a single EC2 server).

```text
                       ┌──────────────── Vercel ─────────────────┐
Browser ──HTTPS──▶     │ React app (static, Vite build)          │
                       │ /api/*  → Python function (FastAPI)     │──▶ Neon Postgres
                       │           /api/engine/generate → Gemini │
                       └─────────────────────────────────────────┘

                       ┌──────────── AWS EC2 (t3.micro) ─────────┐
Browser ──HTTPS──▶     │ nginx (TLS) → Node gateway :3000        │
 www.sukoon.tech       │   /api/engine/* → Gemini                │
                       │   other /api/*  → FastAPI :3001         │──▶ Postgres 16 (Docker, localhost only)
                       └─────────────────────────────────────────┘
```

- **Frontend:** React 19, TypeScript, Vite. The `supabase` client in `src/services` is a small local shim that calls this app's own `/api/db` and `/api/auth` endpoints.
- **API:** FastAPI and SQLAlchemy (`main.py`, `backend/`). It owns accounts, the journal, bookings, therapist tools and admin actions.
- **AI:** Google Gemini (`gemini-2.5-flash`) through `GEMINI_API_KEY`. If that isn't set, the API falls back to OpenAI (`OPENAI_API_KEY`).
- **Sign-in:** email and password with a signed bearer token, plus Continue with Google (Firebase Auth).
- **Database:** PostgreSQL. Neon on Vercel; Postgres 16 in Docker on EC2.

More detail: [architecture](docs/architecture/README_ARCHITECTURE.md) · [backend and database](docs/architecture/README_BACKEND.md) · [AWS deployment](docs/deployment/deployment.md) · [AWS services](docs/deployment/aws-services.md)

---

## Run it locally

You need Node.js, Python 3 and Docker.

```bash
npm install
pip install fastapi uvicorn sqlalchemy psycopg2-binary pydantic email-validator
docker compose up -d
```

Create a `.env` file (it is gitignored):

```text
DATABASE_URL=postgresql://sukoon:sukoon@localhost:5432/sukoon
GEMINI_API_KEY=your-gemini-key
```

Google sign-in also needs the `VITE_FIREBASE_*` values listed under [Deploy](#deploy). Everything else works without them.

Then start the app:

```bash
npm run dev
```

This starts the Node gateway on http://localhost:3000 and FastAPI on port 3001. Tables and demo data are created on first start.

## Deploy

**Vercel.** `vercel.json` builds the Vite app and serves `/api/*` from `api/index.py`. Set these environment variables on the project:

| Variable | What it's for |
|---|---|
| `DATABASE_URL` | Postgres connection (added automatically by the Neon integration) |
| `GEMINI_API_KEY` | AI chat |
| `VITE_FIREBASE_API_KEY`, `_AUTH_DOMAIN`, `_PROJECT_ID`, `_STORAGE_BUCKET`, `_MESSAGING_SENDER_ID`, `_APP_ID`, `_MEASUREMENT_ID` | Google sign-in |

**AWS.** One `t3.micro` with nginx and Let's Encrypt, the app running as `sukoon.service`, and Postgres in Docker bound to localhost. The Gemini key lives in SSM Parameter Store (`/sukoon/gemini-api-key`), not in git. Only ports 80 and 443 are open. See [docs/deployment](docs/deployment/).

Rough AWS cost if left running: about $13 a month (instance, public IPv4, 20 GiB disk). This is an estimate, not a bill.

---

## Security and privacy

- No secrets in git. Keys come from Vercel environment variables or AWS SSM.
- On AWS the database is never exposed to the internet, and there is no SSH. Server access goes through AWS Systems Manager.
- Demo logins never show passwords. The Client Demo account can't be deleted or upgraded.

## Project docs

| Topic | Where |
|---|---|
| Architecture | [docs/architecture/README_ARCHITECTURE.md](docs/architecture/README_ARCHITECTURE.md) |
| Backend and database | [docs/architecture/README_BACKEND.md](docs/architecture/README_BACKEND.md) |
| Deployment and AWS | [docs/deployment/](docs/deployment/) |
| Hackathon proof | [docs/proof/README.md](docs/proof/README.md) |
| All screenshots | [docs/screenshots/](docs/screenshots/) |

---

## 🤝 Let's connect

Built by **Syed Moiz** ([GitHub: SYMOIZ](https://github.com/SYMOIZ)).

**LinkedIn:** [Syed Moiz](https://www.linkedin.com/in/symoiz/) · **Email:** `symoiz.dev@gmail.com`

## 📜 License

**Proprietary software — all rights reserved.** © 2026 Syed Moiz.

The repository is shared for viewing and reference only. You may not copy, reproduce, modify, redistribute, use commercially, or create derivative works without prior written permission.

### 🏆 Hackathon exception

For **hackathon submission and evaluation only**, organizers, judges, reviewers and authorized participants may:

* View and review the source code
* Clone or download the repository for evaluation
* Run and test the project
* Temporarily change configuration or code when needed for testing
* Use the project only for judging, demonstration and technical evaluation

This exception **does not grant ownership, commercial rights, redistribution rights, or permission to reuse the project outside the hackathon evaluation**. All intellectual property remains with **Syed Moiz**.
