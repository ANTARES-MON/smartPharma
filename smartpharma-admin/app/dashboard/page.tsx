'use client';

import { useEffect, useState } from 'react';
import {
    Users,
    Clock,
    Building2,
    ShoppingBag,
    TrendingUp,
    CheckCircle,
    XCircle,
    ArrowUpRight,
    RefreshCw,
} from 'lucide-react';
import { getStats, getPendingPharmacists, getMonthlyActivity, getRecentActivity } from '@/lib/api';
import type { Stats, User, MonthlyActivity as MonthlyActivityType, RecentActivity } from '@/types';

// ── Stat card ─────────────────────────────────────────────────────────────────
function StatCard({
    name, value, icon: Icon, gradient, change,
}: {
    name: string;
    value: number;
    icon: React.ElementType;
    gradient: string;
    change?: string;
}) {
    return (
        <div
            className="relative overflow-hidden rounded-2xl p-5 flex flex-col gap-3 group transition-all duration-300 hover:-translate-y-0.5"
            style={{
                background: 'rgba(255,255,255,0.04)',
                border: '1px solid rgba(255,255,255,0.07)',
            }}
        >
            {/* Subtle background glow */}
            <div
                className="absolute -top-8 -right-8 w-24 h-24 rounded-full opacity-10 group-hover:opacity-20 transition-opacity blur-2xl"
                style={{ background: gradient }}
            />

            <div className="flex items-start justify-between relative">
                <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                    style={{ background: gradient + '22' }}
                >
                    <Icon className="w-5 h-5" style={{ color: gradient.split(',')[1]?.trim().split(')')[0] ?? '#10b981' }} />
                </div>
                {change && (
                    <span className="text-xs font-medium text-emerald-400 flex items-center gap-0.5">
                        <ArrowUpRight className="w-3 h-3" />{change}
                    </span>
                )}
            </div>

            <div className="relative">
                <p className="text-[11px] font-medium uppercase tracking-wider text-gray-500">{name}</p>
                <p className="text-3xl font-bold text-white mt-1">{value.toLocaleString()}</p>
            </div>
        </div>
    );
}

// ── Status badge ─────────────────────────────────────────────────────────────
function StatusBadge({ status }: { status: string }) {
    const map: Record<string, { label: string; color: string; bg: string }> = {
        actif: { label: 'Actif', color: '#10b981', bg: 'rgba(16,185,129,0.12)' },
        en_attente: { label: 'En attente', color: '#f59e0b', bg: 'rgba(245,158,11,0.12)' },
        inactif: { label: 'Inactif', color: '#ef4444', bg: 'rgba(239,68,68,0.12)' },
    };
    const s = map[status] ?? { label: status, color: '#9ca3af', bg: 'rgba(156,163,175,0.1)' };
    return (
        <span
            className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-medium"
            style={{ color: s.color, background: s.bg }}
        >
            <span className="w-1.5 h-1.5 rounded-full" style={{ background: s.color }} />
            {s.label}
        </span>
    );
}

export default function DashboardPage() {
    const [stats, setStats] = useState<Stats | null>(null);
    const [pendingList, setPendingList] = useState<User[]>([]);
    const [recentActivity, setRecentActivity] = useState<RecentActivity[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);

    const load = async (silent = false) => {
        if (!silent) setLoading(true);
        else setRefreshing(true);
        try {
            const [s, p, r] = await Promise.all([
                getStats(), getPendingPharmacists(), getRecentActivity(),
            ]);
            setStats(s.stats);
            setPendingList(p.pharmacists.slice(0, 5));
            setRecentActivity(r.recentActivity);
        } catch { }
        setLoading(false);
        setRefreshing(false);
    };

    useEffect(() => {
        if (localStorage.getItem('adminToken')) load();
        else setLoading(false);
    }, []); // eslint-disable-line

    const statCards = [
        { name: 'Utilisateurs Actifs', value: stats?.totalUsers || 0, icon: Users, gradient: 'linear-gradient(135deg, #6366f1, #8b5cf6)' },
        { name: 'En Attente', value: stats?.pendingPharmacists || 0, icon: Clock, gradient: 'linear-gradient(135deg, #f59e0b, #d97706)' },
        { name: 'Pharmacies Actives', value: stats?.totalPharmacies ?? 0, icon: Building2, gradient: 'linear-gradient(135deg, #3b82f6, #2563eb)' },
        { name: 'Réservations', value: stats?.totalReservations || 0, icon: ShoppingBag, gradient: 'linear-gradient(135deg, #ec4899, #db2777)' },
        { name: 'Inscriptions (7j)', value: stats?.recentRegistrations || 0, icon: TrendingUp, gradient: 'linear-gradient(135deg, #14b8a6, #0d9488)' },
    ];

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-[400px]">
                <div className="flex flex-col items-center gap-3">
                    <div className="w-10 h-10 rounded-full border-2 border-emerald-400 border-t-transparent animate-spin" />
                    <p className="text-xs text-gray-600">Chargement des données…</p>
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-6">

            {/* ── Header ── */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Bonjour</h1>
                    <p className="text-sm text-gray-500 mt-0.5">Voici un aperçu de votre plateforme aujourd'hui.</p>
                </div>
                <button
                    onClick={() => load(true)}
                    disabled={refreshing}
                    className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-gray-400 hover:text-white transition-colors"
                    style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.07)' }}
                >
                    <RefreshCw className={`w-3.5 h-3.5 ${refreshing ? 'animate-spin' : ''}`} />
                    Actualiser
                </button>
            </div>

            {/* ── Stat grid ── */}
            <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-4">
                {statCards.map(c => <StatCard key={c.name} {...c} />)}
            </div>

            {/* ── Middle row ── */}
            <div className="grid grid-cols-1 lg:grid-cols-5 gap-5">

                {/* Pending list — 3 cols */}
                <div className="lg:col-span-3 rounded-2xl p-5"
                    style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}
                >
                    <div className="flex items-center justify-between mb-4">
                        <div>
                            <h2 className="text-sm font-semibold text-white">Pharmaciens en attente</h2>
                            <p className="text-[11px] text-gray-600 mt-0.5">Approbations récentes</p>
                        </div>
                        <a href="/dashboard/pending"
                            className="text-[11px] font-medium text-emerald-400 hover:text-emerald-300 transition-colors flex items-center gap-1"
                        >
                            Voir tout <ArrowUpRight className="w-3 h-3" />
                        </a>
                    </div>

                    {pendingList.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-10 text-gray-600">
                            <CheckCircle className="w-8 h-8 mb-2 opacity-40" />
                            <p className="text-sm">Aucun pharmacien en attente</p>
                        </div>
                    ) : (
                        <div className="space-y-2">
                            {pendingList.map((p) => (
                                <div key={p.idUtilisateur}
                                    className="flex items-center gap-3 p-3 rounded-xl transition-colors hover:bg-white/[0.03]"
                                    style={{ border: '1px solid rgba(255,255,255,0.05)' }}
                                >
                                    <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0"
                                        style={{ background: 'linear-gradient(135deg, #f59e0b, #d97706)' }}
                                    >
                                        {p.nomComplet?.charAt(0).toUpperCase()}
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm font-medium text-white truncate">{p.nomComplet}</p>
                                        <p className="text-[11px] text-gray-500 truncate">{p.email}</p>
                                    </div>
                                    <StatusBadge status="en_attente" />
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* Recent activity — 2 cols */}
                <div className="lg:col-span-2 rounded-2xl p-5"
                    style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}
                >
                    <div className="mb-4">
                        <h2 className="text-sm font-semibold text-white">Activité récente</h2>
                        <p className="text-[11px] text-gray-600 mt-0.5">Derniers enregistrements</p>
                    </div>

                    {recentActivity.length === 0 ? (
                        <p className="text-center text-sm text-gray-600 py-10">Aucune activité</p>
                    ) : (
                        <div className="space-y-3">
                            {recentActivity.slice(0, 6).map((a) => (
                                <div key={a.idUtilisateur} className="flex items-center gap-3">
                                    <div className={`w-7 h-7 rounded-full flex items-center justify-center shrink-0 text-[10px] font-bold text-white`}
                                        style={{
                                            background: a.role === 'pharmacien'
                                                ? 'linear-gradient(135deg,#10b981,#059669)'
                                                : 'linear-gradient(135deg,#6366f1,#8b5cf6)',
                                        }}
                                    >
                                        {a.nomComplet?.charAt(0).toUpperCase()}
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <p className="text-[12px] font-medium text-gray-200 truncate">{a.nomComplet}</p>
                                        <p className="text-[10px] text-gray-600">
                                            {a.role === 'client' ? 'Client' : 'Pharmacien'} •{' '}
                                            {new Date(a.created_at).toLocaleDateString('fr-FR')}
                                        </p>
                                    </div>
                                    <div>
                                        {a.statut === 'actif' ? <CheckCircle className="w-3.5 h-3.5 text-emerald-400" /> :
                                            a.statut === 'en_attente' ? <Clock className="w-3.5 h-3.5 text-amber-400" /> :
                                                <XCircle className="w-3.5 h-3.5 text-red-400" />}
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </div>

        </div>
    );
}
