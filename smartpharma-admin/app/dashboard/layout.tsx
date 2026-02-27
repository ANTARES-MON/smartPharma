'use client';

import { useEffect, useState, useRef, useCallback } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import {
    LayoutDashboard,
    Users,
    Clock,
    LogOut,
    Menu,
    X,
    UserCheck,
    ChevronRight,
    Bell,
    Settings,
    UserPlus,
    CheckCheck,
} from 'lucide-react';
import { adminLogout, getPendingPharmacists } from '@/lib/api';
import type { User } from '@/types';

const NAV = [
    { name: "Vue d'ensemble", href: '/dashboard', icon: LayoutDashboard, exact: true },
    { name: 'Pharmaciens', href: '/dashboard/pharmacists', icon: UserCheck, exact: false },
    { name: 'Clients', href: '/dashboard/clients', icon: Users, exact: false },
    { name: 'En attente', href: '/dashboard/pending', icon: Clock, exact: false },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
    const router = useRouter();
    const pathname = usePathname();
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [adminUser, setAdminUser] = useState<any>(null);

    // ── Notifications ──
    const [pendingList, setPendingList] = useState<User[]>([]);
    const [notifOpen, setNotifOpen] = useState(false);
    const [seenCount, setSeenCount] = useState(0);
    const notifRef = useRef<HTMLDivElement>(null);

    const unreadCount = Math.max(0, pendingList.length - seenCount);

    const fetchPending = useCallback(async () => {
        try {
            const data = await getPendingPharmacists();
            setPendingList(data.pharmacists ?? []);
        } catch { /* silent */ }
    }, []);

    useEffect(() => {
        const token = localStorage.getItem('adminToken');
        const user = localStorage.getItem('adminUser');
        if (!token || !user) { router.push('/'); return; }
        setAdminUser(JSON.parse(user));
        fetchPending();
        const interval = setInterval(fetchPending, 30_000);
        return () => clearInterval(interval);
    }, [router, fetchPending]);

    // Close dropdown on outside click
    useEffect(() => {
        const handler = (e: MouseEvent) => {
            if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
                setNotifOpen(false);
            }
        };
        document.addEventListener('mousedown', handler);
        return () => document.removeEventListener('mousedown', handler);
    }, []);

    const handleBellClick = () => {
        setNotifOpen(v => !v);
    };

    const markAllAsRead = () => {
        setSeenCount(pendingList.length);
    };

    const handleLogout = async () => {
        try { await adminLogout(); } catch { }
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        router.push('/');
    };

    const isActive = (item: typeof NAV[0]) =>
        item.exact ? pathname === item.href : pathname.startsWith(item.href);

    const pageTitle = NAV.find(n => isActive(n))?.name ?? 'Dashboard';

    if (!adminUser) {
        return (
            <div className="min-h-screen flex items-center justify-center" style={{ background: '#0f1117' }}>
                <div className="flex flex-col items-center gap-4">
                    <div className="w-10 h-10 rounded-full border-2 border-emerald-400 border-t-transparent animate-spin" />
                    <p className="text-sm text-gray-500">Chargement...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen flex" style={{ background: '#0f1117' }}>

            {/* Mobile backdrop */}
            {sidebarOpen && (
                <div className="fixed inset-0 z-20 bg-black/60 backdrop-blur-sm lg:hidden"
                    onClick={() => setSidebarOpen(false)} />
            )}

            {/* Sidebar */}
            <aside className={`
                fixed inset-y-0 left-0 z-30 flex flex-col w-64 transform transition-transform duration-300 ease-in-out
                lg:static lg:translate-x-0 lg:flex
                ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
            `} style={{
                    background: 'linear-gradient(180deg, #13151e 0%, #0f1117 100%)',
                    borderRight: '1px solid rgba(255,255,255,0.06)',
                }}>
                {/* Logo */}
                <div className="flex items-center justify-between h-16 px-5 shrink-0"
                    style={{ borderBottom: '1px solid rgba(255,255,255,0.06)' }}>
                    <div className="flex items-center gap-2.5">
                        <div className="w-7 h-7 rounded-lg flex items-center justify-center overflow-hidden">
                            {/* eslint-disable-next-line @next/next/no-img-element */}
                            <img src="/logo-bw.png" alt="SmartPharma" width={28} height={28}
                                style={{ objectFit: 'contain', mixBlendMode: 'screen' }} />
                        </div>
                        <span className="text-white font-semibold text-sm tracking-wide">SmartPharma</span>
                    </div>
                    <button onClick={() => setSidebarOpen(false)} className="lg:hidden text-gray-500 hover:text-white transition-colors">
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <div className="px-5 pt-6 pb-2">
                    <p className="text-[10px] font-semibold tracking-widest uppercase text-gray-600">Navigation</p>
                </div>

                <nav className="flex-1 px-3 space-y-0.5 overflow-y-auto">
                    {NAV.map((item) => {
                        const Icon = item.icon;
                        const active = isActive(item);
                        return (
                            <a key={item.href} href={item.href}
                                className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 group relative"
                                style={active
                                    ? { background: 'rgba(16,185,129,0.12)', color: '#10b981' }
                                    : { color: '#9ca3af' }
                                }>
                                {active && <span className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-5 rounded-r bg-emerald-400" />}
                                <Icon className="w-4 h-4 shrink-0" />
                                <span className="flex-1">{item.name}</span>
                                {active && <ChevronRight className="w-3.5 h-3.5 opacity-60" />}
                            </a>
                        );
                    })}
                </nav>

                <div className="shrink-0 p-3" style={{ borderTop: '1px solid rgba(255,255,255,0.06)' }}>
                    <button onClick={handleLogout}
                        className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors text-gray-500 hover:text-red-400 hover:bg-red-500/10">
                        <LogOut className="w-4 h-4" />
                        Déconnexion
                    </button>
                </div>
            </aside>

            {/* Main */}
            <div className="flex-1 flex flex-col min-w-0">

                {/* Top bar */}
                <header className="sticky top-0 z-10 flex items-center justify-between h-16 px-4 lg:px-7 shrink-0"
                    style={{
                        background: 'rgba(15,17,23,0.85)',
                        borderBottom: '1px solid rgba(255,255,255,0.06)',
                        backdropFilter: 'blur(12px)',
                    }}>
                    <div className="flex items-center gap-3">
                        <button onClick={() => setSidebarOpen(true)}
                            className="lg:hidden text-gray-500 hover:text-white transition-colors">
                            <Menu className="w-5 h-5" />
                        </button>
                        <div>
                            <h1 className="text-sm font-semibold text-white">{pageTitle}</h1>
                            <p className="text-[11px] text-gray-600 hidden sm:block">SmartPharma Admin</p>
                        </div>
                    </div>

                    <div className="flex items-center gap-2">
                        {/* Live dot */}
                        <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11px] font-mono text-emerald-400"
                            style={{ background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.2)' }}>
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                            En ligne
                        </div>

                        {/* Notification Bell */}
                        <div ref={notifRef} className="relative">
                            <button onClick={handleBellClick}
                                className="relative w-8 h-8 flex items-center justify-center rounded-lg text-gray-500 hover:text-white hover:bg-white/5 transition-colors">
                                <Bell className="w-4 h-4" />
                                {unreadCount > 0 && (
                                    <span className="absolute -top-0.5 -right-0.5 min-w-[16px] h-4 px-0.5 flex items-center justify-center rounded-full text-[10px] font-bold text-white"
                                        style={{ background: '#ef4444' }}>
                                        {unreadCount > 9 ? '9+' : unreadCount}
                                    </span>
                                )}
                            </button>

                            {/* Dropdown */}
                            {notifOpen && (
                                <div className="absolute right-0 top-10 w-80 rounded-xl shadow-2xl overflow-hidden z-50"
                                    style={{ background: '#13151e', border: '1px solid rgba(255,255,255,0.1)' }}>

                                    {/* Header */}
                                    <div className="flex items-center justify-between px-4 py-3"
                                        style={{ borderBottom: '1px solid rgba(255,255,255,0.07)' }}>
                                        <div className="flex items-center gap-2">
                                            <Bell className="w-4 h-4 text-amber-400" />
                                            <span className="text-sm font-semibold text-white">Notifications</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            {pendingList.length > 0 && (
                                                <span className="text-xs px-2 py-0.5 rounded-full font-medium text-amber-400"
                                                    style={{ background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.2)' }}>
                                                    {pendingList.length} en attente
                                                </span>
                                            )}
                                            {pendingList.length > 0 && (
                                                <button
                                                    onClick={markAllAsRead}
                                                    title="Marquer tout comme lu"
                                                    className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-medium transition-all"
                                                    style={unreadCount > 0
                                                        ? { color: '#10b981', background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.2)' }
                                                        : { color: '#6b7280', background: 'transparent', border: '1px solid transparent', cursor: 'default' }
                                                    }
                                                    disabled={unreadCount === 0}
                                                >
                                                    <CheckCheck className="w-3.5 h-3.5" />
                                                    <span>Tout lire</span>
                                                </button>
                                            )}
                                        </div>
                                    </div>

                                    {/* List */}
                                    <div className="max-h-72 overflow-y-auto">
                                        {pendingList.length === 0 ? (
                                            <div className="px-4 py-8 text-center">
                                                <Bell className="w-8 h-8 text-gray-700 mx-auto mb-2" />
                                                <p className="text-sm text-gray-600">Aucune notification</p>
                                            </div>
                                        ) : (
                                            pendingList.map((pharmacist) => (
                                                <div key={pharmacist.idUtilisateur}
                                                    className="flex items-start gap-3 px-4 py-3 hover:bg-white/[0.03] transition-colors cursor-pointer"
                                                    style={{ borderBottom: '1px solid rgba(255,255,255,0.04)' }}
                                                    onClick={() => { router.push('/dashboard/pending'); setNotifOpen(false); }}>
                                                    <div className="w-8 h-8 rounded-full flex items-center justify-center shrink-0 mt-0.5"
                                                        style={{ background: 'rgba(245,158,11,0.15)', border: '1px solid rgba(245,158,11,0.25)' }}>
                                                        <UserPlus className="w-4 h-4 text-amber-400" />
                                                    </div>
                                                    <div className="flex-1 min-w-0">
                                                        <p className="text-sm font-medium text-gray-100 truncate">
                                                            {pharmacist.nomComplet}
                                                        </p>
                                                        <p className="text-xs text-gray-500 mt-0.5">
                                                            Nouvelle inscription pharmacien
                                                        </p>
                                                        <p className="text-[11px] text-gray-700 mt-0.5">
                                                            {new Date(pharmacist.created_at).toLocaleDateString('fr-FR', {
                                                                day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit'
                                                            })}
                                                        </p>
                                                    </div>
                                                    <div className="w-2 h-2 rounded-full bg-amber-400 shrink-0 mt-2" />
                                                </div>
                                            ))
                                        )}
                                    </div>

                                    {/* Footer */}
                                    {pendingList.length > 0 && (
                                        <div style={{ borderTop: '1px solid rgba(255,255,255,0.07)' }}>
                                            <button
                                                onClick={() => { router.push('/dashboard/pending'); setNotifOpen(false); }}
                                                className="w-full py-3 text-xs font-medium text-emerald-400 hover:text-emerald-300 transition-colors">
                                                Voir toutes les demandes →
                                            </button>
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>

                        <button className="w-8 h-8 flex items-center justify-center rounded-lg text-gray-500 hover:text-white hover:bg-white/5 transition-colors">
                            <Settings className="w-4 h-4" />
                        </button>
                    </div>
                </header>

                <main className="flex-1 p-4 lg:p-7 overflow-auto">
                    {children}
                </main>
            </div>
        </div>
    );
}
