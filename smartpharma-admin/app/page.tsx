'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import Particles, { initParticlesEngine } from '@tsparticles/react';
import { loadSlim } from '@tsparticles/slim';
import type { ISourceOptions, Engine } from '@tsparticles/engine';
import { adminLogin } from '@/lib/api';

// ─── tsParticles config ───────────────────────────────────────────────────────
// Goated black & white neon constellation:
//  • 180 glowing white particles forming a live constellation net
//  • Hover → grab: cursor pulls threads of light toward it
//  • Click → push: burst of new particles from click point
//  • Particles pulse in opacity for a breathing / neon flicker feel
//  • Shadow blur adds real neon glow without any extra CSS
const PARTICLES_CONFIG: ISourceOptions = {
  fullScreen: { enable: false },
  background: { color: { value: '#000000' } },
  fpsLimit: 120,
  interactivity: {
    events: {
      onClick: { enable: true, mode: 'push' },
      onHover: { enable: true, mode: 'grab' },
      resize: { enable: true },
    },
    modes: {
      grab: {
        distance: 220,
        links: { opacity: 1, color: '#ffffff' },
      },
      push: { quantity: 8 },
      repulse: { distance: 180, duration: 0.4 },
    },
  },
  particles: {
    number: {
      value: 180,
      density: { enable: true },
    },
    color: {
      value: ['#ffffff', '#e0e0e0', '#c0c0c0'],
    },
    shape: { type: 'circle' },
    opacity: {
      value: { min: 0.15, max: 0.9 },
      animation: {
        enable: true,
        speed: 0.6,
        sync: false,
        startValue: 'random',
      },
    },
    size: {
      value: { min: 0.8, max: 2.8 },
    },
    shadow: {
      enable: true,
      color: '#ffffff',
      blur: 8,
    },
    links: {
      enable: true,
      color: '#ffffff',
      distance: 140,
      opacity: 0.25,
      width: 0.7,
      shadow: {
        enable: true,
        color: '#ffffff',
        blur: 4,
      },
    },
    move: {
      enable: true,
      speed: 0.9,
      direction: 'none',
      random: true,
      straight: false,
      outModes: { default: 'bounce' },
      attract: { enable: false },
    },
  },
  detectRetina: true,
};

// ─── Scanlines ────────────────────────────────────────────────────────────────
function Scanlines() {
  return (
    <div
      className="pointer-events-none fixed inset-0 z-10"
      style={{
        background:
          'repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(255,255,255,0.015) 2px,rgba(255,255,255,0.015) 4px)',
      }}
    />
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────
export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [engineReady, setEngineReady] = useState(false);

  // Init tsParticles engine once
  const particlesInit = useCallback(async (engine: Engine) => {
    await loadSlim(engine);
  }, []);

  useEffect(() => {
    initParticlesEngine(particlesInit).then(() => setEngineReady(true));
    const t = setTimeout(() => setMounted(true), 200);
    return () => clearTimeout(t);
  }, [particlesInit]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const data = await adminLogin(email, password);
      localStorage.setItem('adminToken', data.token);
      localStorage.setItem('adminUser', JSON.stringify(data.user));
      router.push('/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Accès refusé');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-black">

      {/* ── Layer 0: tsParticles neon constellation ───────────────────────── */}
      {engineReady && (
        <Particles
          id="tsparticles"
          className="fixed inset-0 z-0"
          options={PARTICLES_CONFIG}
        />
      )}

      {/* ── Layer 1: Scanlines ────────────────────────────────────────────── */}
      <Scanlines />

      {/* ── Layer 2: Vignette — darkens edges, pulls focus to center card ─── */}
      <div
        className="pointer-events-none fixed inset-0 z-20"
        style={{
          background:
            'radial-gradient(ellipse at center, transparent 25%, rgba(0,0,0,0.72) 100%)',
        }}
      />

      {/* ── Layer 3: Login card — floating centered ───────────────────────── */}
      <div className="relative z-30 min-h-screen flex items-center justify-center px-4 py-10">
        <div
          className="w-full max-w-md"
          style={{
            opacity: mounted ? 1 : 0,
            transform: mounted ? 'translateY(0)' : 'translateY(28px)',
            transition: 'opacity 0.9s ease, transform 0.9s ease',
          }}
        >
          {/* ── Header ─────────────────────────────────────────────────────── */}
          <div className="text-center mb-8">
            {/* App logo — B&W pill icon, no background */}
            <div className="inline-flex items-center justify-center w-20 h-20 mb-4">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/logo-bw.png"
                alt="SmartPharma"
                width={80}
                height={80}
                style={{ mixBlendMode: 'screen', objectFit: 'contain' }}
              />
            </div>

            <h1
              className="text-4xl font-bold tracking-widest uppercase mb-1"
              style={{
                color: '#ffffff',
                textShadow: '0 0 20px rgba(255,255,255,0.9), 0 0 60px rgba(255,255,255,0.3)',
              }}
            >
              SmartPharma
            </h1>
            <p
              className="text-xs tracking-[0.35em] uppercase font-mono"
              style={{ color: 'rgba(255,255,255,0.4)' }}
            >
              Panneau d&apos;administration
            </p>
          </div>

          {/* ── Card ───────────────────────────────────────────────────────── */}
          <div
            className="rounded-2xl p-8 backdrop-blur-2xl"
            style={{
              background: 'rgba(0,0,0,0.82)',
              border: '1px solid rgba(255,255,255,0.18)',
              boxShadow:
                '0 0 0 1px rgba(255,255,255,0.05), 0 0 60px rgba(255,255,255,0.07), inset 0 0 40px rgba(255,255,255,0.02)',
            }}
          >
            {/* Divider row */}
            <div className="flex items-center gap-3 mb-6">
              <div className="h-px flex-1" style={{ background: 'rgba(255,255,255,0.18)' }} />
              <span
                className="text-xs font-mono tracking-widest uppercase"
                style={{ color: 'rgba(255,255,255,0.55)' }}
              >
                AUTHENTICATE
              </span>
              <div className="h-px flex-1" style={{ background: 'rgba(255,255,255,0.18)' }} />
            </div>

            {/* Error */}
            {error && (
              <div
                className="mb-5 px-4 py-3 rounded-lg font-mono text-sm flex items-center gap-2"
                style={{
                  background: 'rgba(255,60,60,0.1)',
                  border: '1px solid rgba(255,60,60,0.4)',
                  color: '#ff7070',
                }}
              >
                <span>⚠</span> {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Email */}
              <div>
                <label
                  className="block text-xs font-mono tracking-widest uppercase mb-2"
                  style={{ color: 'rgba(255,255,255,0.5)' }}
                >
                  &gt; Identifiant
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  placeholder="Email"
                  className="w-full px-4 py-3 rounded-lg font-mono text-sm outline-none transition-all duration-300"
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.18)',
                    color: '#fff',
                    caretColor: '#fff',
                  }}
                  onFocus={(e) => {
                    e.target.style.border = '1px solid rgba(255,255,255,0.75)';
                    e.target.style.boxShadow = '0 0 16px rgba(255,255,255,0.15)';
                  }}
                  onBlur={(e) => {
                    e.target.style.border = '1px solid rgba(255,255,255,0.18)';
                    e.target.style.boxShadow = 'none';
                  }}
                />
              </div>

              {/* Password */}
              <div>
                <label
                  className="block text-xs font-mono tracking-widest uppercase mb-2"
                  style={{ color: 'rgba(255,255,255,0.5)' }}
                >
                  &gt; Mot de passe
                </label>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  placeholder="••••••••••••"
                  className="w-full px-4 py-3 rounded-lg font-mono text-sm outline-none transition-all duration-300"
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.18)',
                    color: '#fff',
                    caretColor: '#fff',
                  }}
                  onFocus={(e) => {
                    e.target.style.border = '1px solid rgba(255,255,255,0.75)';
                    e.target.style.boxShadow = '0 0 16px rgba(255,255,255,0.15)';
                  }}
                  onBlur={(e) => {
                    e.target.style.border = '1px solid rgba(255,255,255,0.18)';
                    e.target.style.boxShadow = 'none';
                  }}
                />
              </div>

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 rounded-lg font-mono text-sm font-bold tracking-widest uppercase transition-all duration-300 disabled:opacity-40"
                style={{
                  background: 'rgba(255,255,255,0.1)',
                  border: '1px solid rgba(255,255,255,0.5)',
                  color: '#fff',
                  boxShadow: '0 0 20px rgba(255,255,255,0.1)',
                }}
                onMouseEnter={(e) => {
                  if (!loading) {
                    (e.target as HTMLButtonElement).style.background = 'rgba(255,255,255,0.2)';
                    (e.target as HTMLButtonElement).style.boxShadow = '0 0 35px rgba(255,255,255,0.3)';
                  }
                }}
                onMouseLeave={(e) => {
                  (e.target as HTMLButtonElement).style.background = 'rgba(255,255,255,0.1)';
                  (e.target as HTMLButtonElement).style.boxShadow = '0 0 20px rgba(255,255,255,0.1)';
                }}
              >
                {loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <span className="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                    Authentification...
                  </span>
                ) : (
                  '[ ACCÉDER AU SYSTÈME ]'
                )}
              </button>
            </form>

            {/* Footer divider */}
            <div className="mt-6 flex items-center gap-3">
              <div className="h-px flex-1" style={{ background: 'rgba(255,255,255,0.1)' }} />
              <span className="text-xs font-mono" style={{ color: 'rgba(255,255,255,0.25)' }}>
                SECURE CONNECTION
              </span>
              <div className="h-px flex-1" style={{ background: 'rgba(255,255,255,0.1)' }} />
            </div>
          </div>

          {/* Footer */}
          <div
            className="text-center mt-6 font-mono text-xs"
            style={{ color: 'rgba(255,255,255,0.18)' }}
          >
            © 2026 SmartPharma · Accès réservé aux administrateurs
          </div>
        </div>
      </div>
    </div>
  );
}
