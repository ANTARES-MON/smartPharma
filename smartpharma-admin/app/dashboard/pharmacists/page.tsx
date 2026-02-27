'use client';

import { useEffect, useState } from 'react';
import { Users, Search, Download, Package, ShoppingCart, TrendingUp } from 'lucide-react';
import { getAllPharmacists, deleteUser, getPharmacistStats } from '@/lib/api';
import type { User } from '@/types';

export default function PharmacistsPage() {
    const [pharmacists, setPharmacists] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<string>('actif');
    const [deleteLoading, setDeleteLoading] = useState(false);
    const [selectedPharmacist, setSelectedPharmacist] = useState<User | null>(null);
    const [pharmacistStats, setPharmacistStats] = useState<any>(null);
    const [statsLoading, setStatsLoading] = useState(false);

    useEffect(() => {
        loadPharmacists();
    }, [statusFilter]);

    const loadPharmacists = async () => {
        setLoading(true);
        try {
            // Never show en_attente here — they have their own dedicated page
            const params = statusFilter === 'all'
                ? { statut: 'actif,suspendu' }  // exclude en_attente in "Tous" view
                : { statut: statusFilter };
            const data = await getAllPharmacists(params);
            setPharmacists(data.pharmacists);
        } catch (error) {
            console.error('Error loading pharmacists:', error);
        } finally {
            setLoading(false);
        }
    };

    const loadPharmacistStats = async (pharmacistId: number) => {
        setStatsLoading(true);
        try {
            const data = await getPharmacistStats(pharmacistId);
            setPharmacistStats(data.stats);
        } catch (error) {
            console.error('Error loading stats:', error);
            setPharmacistStats(null);
        } finally {
            setStatsLoading(false);
        }
    };

    const handleViewDetails = (pharmacist: User) => {
        setSelectedPharmacist(pharmacist);
        loadPharmacistStats(pharmacist.idUtilisateur);
    };

    const handleDelete = async (pharmacist: User) => {
        if (!confirm(`Êtes-vous sûr de vouloir supprimer ${pharmacist.nomComplet} ?`)) {
            return;
        }

        setDeleteLoading(true);
        try {
            await deleteUser(pharmacist.idUtilisateur);
            alert(`${pharmacist.nomComplet} a été supprimé avec succès`);
            loadPharmacists(); // Reload the list
        } catch (error: any) {
            alert(error.response?.data?.message || 'Erreur lors de la suppression');
        } finally {
            setDeleteLoading(false);
        }
    };

    // Safety net: never show en_attente pharmacists on this page
    const filteredPharmacists = pharmacists.filter((p) =>
        p.statut !== 'en_attente' && (
            p.nomComplet.toLowerCase().includes(searchQuery.toLowerCase()) ||
            p.email.toLowerCase().includes(searchQuery.toLowerCase())
        )
    );

    const getStatusBadge = (statut: string) => {
        const map: Record<string, { label: string; color: string; bg: string }> = {
            actif: { label: 'Actif', color: '#10b981', bg: 'rgba(16,185,129,0.12)' },
            en_attente: { label: 'En attente', color: '#f59e0b', bg: 'rgba(245,158,11,0.12)' },
            suspendu: { label: 'Suspendu', color: '#ef4444', bg: 'rgba(239,68,68,0.12)' },
        };
        const s = map[statut] ?? { label: statut, color: '#9ca3af', bg: 'rgba(156,163,175,0.1)' };
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-medium"
                style={{ color: s.color, background: s.bg }}
            >
                <span className="w-1.5 h-1.5 rounded-full" style={{ background: s.color }} />
                {s.label}
            </span>
        );
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-[400px]">
                <div className="w-10 h-10 rounded-full border-2 border-emerald-400 border-t-transparent animate-spin" />
            </div>
        );
    }

    return (
        <div className="space-y-5">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-xl font-bold text-white">Pharmaciens</h1>
                    <p className="text-sm text-gray-500 mt-0.5">Gérez tous les pharmaciens enregistrés</p>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 rounded-xl" style={{ background: 'rgba(16,185,129,0.1)', border: '1px solid rgba(16,185,129,0.2)' }}>
                    <Users className="w-4 h-4 text-emerald-400" />
                    <span className="text-emerald-400 font-bold text-lg">{filteredPharmacists.length}</span>
                    <span className="text-emerald-500/70 text-sm">pharmaciens</span>
                </div>
            </div>

            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-600 w-4 h-4" />
                    <input
                        type="text"
                        placeholder="Rechercher par nom ou email..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 text-sm rounded-xl text-gray-300 placeholder-gray-600 outline-none transition-colors"
                        style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.08)' }}
                    />
                </div>
                <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="px-3 py-2 text-sm rounded-xl text-gray-300 outline-none"
                    style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.08)' }}
                >
                    <option value="all">Tous</option>
                    <option value="actif">Actif</option>
                    <option value="suspendu">Suspendu</option>
                </select>
            </div>

            {/* Pharmacists Table */}
            {filteredPharmacists.length === 0 ? (
                <div className="rounded-2xl p-12 text-center" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}>
                    <Users className="w-12 h-12 text-gray-600 mx-auto mb-3" />
                    <p className="text-sm font-medium text-white mb-1">Aucun pharmacien trouvé</p>
                    <p className="text-sm text-gray-600">Modifiez vos filtres pour voir plus de résultats</p>
                </div>
            ) : (
                <div className="rounded-2xl overflow-hidden" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}>
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr style={{ borderBottom: '1px solid rgba(255,255,255,0.07)' }}>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Nom</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Email</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Téléphone</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Pharmacie</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Statut</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Date</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredPharmacists.map((pharmacist) => (
                                    <tr key={pharmacist.idUtilisateur} className="transition-colors hover:bg-white/[0.02]" style={{ borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                                        <td className="px-5 py-3.5">
                                            <div className="flex items-center gap-2.5">
                                                <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0"
                                                    style={{ background: 'linear-gradient(135deg,#10b981,#059669)' }}
                                                >
                                                    {pharmacist.nomComplet?.charAt(0).toUpperCase()}
                                                </div>
                                                <span className="text-sm font-medium text-gray-100">{pharmacist.nomComplet}</span>
                                            </div>
                                        </td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{pharmacist.email}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{pharmacist.telephone || '-'}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{pharmacist.pharmacy?.nom || '-'}</td>
                                        <td className="px-5 py-3.5">{getStatusBadge(pharmacist.statut)}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{new Date(pharmacist.created_at).toLocaleDateString('fr-FR')}</td>
                                        <td className="px-5 py-3.5">
                                            <div className="flex gap-3">
                                                <button onClick={() => handleViewDetails(pharmacist)} className="text-xs font-medium text-emerald-400 hover:text-emerald-300 transition-colors">
                                                    Détails
                                                </button>
                                                <button onClick={() => handleDelete(pharmacist)} className="text-xs font-medium text-red-400 hover:text-red-300 transition-colors">
                                                    Supprimer
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Details Modal */}
            {selectedPharmacist && (
                <div className="fixed inset-0 flex items-center justify-center z-50 p-4" style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)' }}>
                    <div className="rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto" style={{ background: '#13151e', border: '1px solid rgba(255,255,255,0.1)' }}>
                        {/* Modal header */}
                        <div className="p-5" style={{ borderBottom: '1px solid rgba(255,255,255,0.07)' }}>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white"
                                        style={{ background: 'linear-gradient(135deg,#10b981,#059669)' }}
                                    >
                                        {selectedPharmacist.nomComplet?.charAt(0).toUpperCase()}
                                    </div>
                                    <div>
                                        <h2 className="text-base font-bold text-white">{selectedPharmacist.nomComplet}</h2>
                                        <p className="text-xs text-gray-500">{selectedPharmacist.email}</p>
                                    </div>
                                </div>
                                <button onClick={() => setSelectedPharmacist(null)} className="p-2 rounded-lg text-gray-500 hover:text-white hover:bg-white/5 transition-colors">
                                    ✕
                                </button>
                            </div>
                        </div>

                        <div className="p-5 space-y-4">
                            {/* Info grid */}
                            <div className="grid grid-cols-2 gap-3">
                                {([
                                    ['Téléphone', selectedPharmacist.telephone || '-'],
                                    ['Ville', selectedPharmacist.ville || '-'],
                                    ['Statut', selectedPharmacist.statut],
                                    ['Inscription', new Date(selectedPharmacist.created_at).toLocaleDateString('fr-FR')],
                                ] as [string, string][]).map(([label, val]) => (
                                    <div key={label} className="p-3 rounded-xl" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.06)' }}>
                                        <p className="text-[10px] uppercase tracking-wider text-gray-600 mb-0.5">{label}</p>
                                        <p className="text-sm font-medium text-gray-200">{val}</p>
                                    </div>
                                ))}
                            </div>

                            {/* Pharmacy */}
                            {selectedPharmacist.pharmacy && (
                                <div className="p-3 rounded-xl" style={{ background: 'rgba(16,185,129,0.08)', border: '1px solid rgba(16,185,129,0.2)' }}>
                                    <p className="text-[10px] uppercase tracking-wider text-emerald-600 mb-1">Pharmacie</p>
                                    <p className="text-sm font-medium text-emerald-300">{selectedPharmacist.pharmacy.nom}</p>
                                    {selectedPharmacist.pharmacy.adresse && <p className="text-xs text-emerald-500/60 mt-0.5">{selectedPharmacist.pharmacy.adresse}</p>}
                                </div>
                            )}

                            {/* Statistics */}
                            {statsLoading && (
                                <div className="flex items-center gap-2 text-sm text-gray-600 py-2">
                                    <div className="w-4 h-4 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin" />
                                    Chargement des statistiques...
                                </div>
                            )}
                            {pharmacistStats && (
                                <div className="space-y-3" style={{ borderTop: '1px solid rgba(255,255,255,0.07)', paddingTop: '1rem' }}>
                                    <p className="text-[11px] uppercase tracking-wider text-gray-600 font-semibold">Statistiques</p>
                                    <div className="grid grid-cols-3 gap-3">
                                        {[
                                            { label: 'Médicaments', value: pharmacistStats.total_medications ?? 0, icon: Package, color: '#6366f1', bg: 'rgba(99,102,241,0.1)' },
                                            { label: 'Réservations', value: pharmacistStats.total_reservations ?? 0, icon: ShoppingCart, color: '#10b981', bg: 'rgba(16,185,129,0.1)' },
                                            { label: 'En attente', value: pharmacistStats.pending_reservations ?? 0, icon: TrendingUp, color: '#f59e0b', bg: 'rgba(245,158,11,0.1)' },
                                        ].map(({ label, value, icon: Icon, color, bg }) => (
                                            <div key={label} className="p-3 rounded-xl text-center" style={{ background: bg, border: `1px solid ${color}33` }}>
                                                <Icon className="w-4 h-4 mx-auto mb-1" style={{ color }} />
                                                <p className="text-xl font-bold" style={{ color }}>{value}</p>
                                                <p className="text-[10px] text-gray-600 mt-0.5">{label}</p>
                                            </div>
                                        ))}
                                    </div>
                                    <div className="grid grid-cols-2 gap-3">
                                        <div className="p-3 rounded-xl text-center" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.06)' }}>
                                            <p className="text-[10px] text-gray-600">Terminées</p>
                                            <p className="text-lg font-bold text-white">{pharmacistStats.completed_reservations ?? 0}</p>
                                        </div>
                                        <div className="p-3 rounded-xl text-center" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.06)' }}>
                                            <p className="text-[10px] text-gray-600">Taux complétion</p>
                                            <p className="text-lg font-bold text-white">
                                                {pharmacistStats.total_reservations > 0
                                                    ? Math.round((pharmacistStats.completed_reservations / pharmacistStats.total_reservations) * 100)
                                                    : 0}%
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            )}

                            {/* License photo */}
                            {selectedPharmacist.photo_licence && (
                                <div className="space-y-2" style={{ borderTop: '1px solid rgba(255,255,255,0.07)', paddingTop: '1rem' }}>
                                    <p className="text-[11px] uppercase tracking-wider text-gray-600 font-semibold">Photo de licence</p>
                                    <div className="rounded-xl overflow-hidden" style={{ border: '1px solid rgba(255,255,255,0.08)' }}>
                                        <img
                                            src={`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}`}
                                            alt="Licence du pharmacien"
                                            className="w-full h-auto object-contain max-h-64 cursor-pointer hover:opacity-80 transition"
                                            onClick={() => window.open(`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}`, '_blank')}
                                        />
                                    </div>
                                    <a
                                        href={`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}/download`}
                                        download
                                        className="flex items-center justify-center gap-2 w-full py-2 rounded-xl text-sm font-medium"
                                        style={{ background: 'rgba(59,130,246,0.12)', border: '1px solid rgba(59,130,246,0.3)', color: '#60a5fa' }}
                                    >
                                        <Download className="w-4 h-4" /> Télécharger la licence
                                    </a>
                                </div>
                            )}
                        </div>

                        <div className="px-5 pb-5">
                            <button
                                onClick={() => setSelectedPharmacist(null)}
                                className="w-full py-2 rounded-xl text-sm font-medium text-gray-400 hover:text-white transition-colors"
                                style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.07)' }}
                            >
                                Fermer
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
