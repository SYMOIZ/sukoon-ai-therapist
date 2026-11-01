// Sukoon
import { initializeApp } from "firebase/app";
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  sendPasswordResetEmail
} from "firebase/auth";

// Firebase web config comes from VITE_FIREBASE_* build-time env vars (set on Vercel / in .env)
const env = import.meta.env;
const firebaseConfig = {
  apiKey: env.VITE_FIREBASE_API_KEY,
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: env.VITE_FIREBASE_APP_ID,
  measurementId: env.VITE_FIREBASE_MEASUREMENT_ID
};

// Without a config the app still loads; only Google sign-in and password reset are unavailable
const app = firebaseConfig.apiKey ? initializeApp(firebaseConfig) : null;
export const auth = app ? getAuth(app) : null;

function requireAuth() {
  if (!auth) throw new Error("Google sign-in is not configured");
  return auth;
}

export async function loginWithGoogle() {
  const provider = new GoogleAuthProvider();

  const result = await signInWithPopup(requireAuth(), provider);

  return result.user;
}

export async function resetPassword(email: string) {
  return await sendPasswordResetEmail(requireAuth(), email);
}
