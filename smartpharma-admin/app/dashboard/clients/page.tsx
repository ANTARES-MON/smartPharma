'use client';

import { useEffect, useState } from 'react';
import { Users, Search, Trash2, ShoppingCart, CheckCircle, XCircle } from 'lucide-react';
import { getAllClients, deleteUser, getClientStats } from '@/lib/api';
import type { User } from '@/types';

export default function ClientsPage() {
    const [clients, setClients] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<string>('all');
    const [deleteLoading, setDeleteLoading] = useState(false);
    const [selectedClient, setSelectedClient] = useState<User | null>(null);
    const [clientStats, setClientStats] = useState<any>(null);
    const [statsLoading, setStatsLoading] = useState(false);

    useEffect(() => {
        loadClients();
    }, [statusFilter]); // eslint-disable-line

    const loadClients = async () => {
        setLoading(true);
        try {
            const params = statusFilter !== 'all' ? { statut: statusFilter } : undefined;
            const data = await getAllClients(params);
            setClients(data.clients);
        } catch (error) {
            console.error('Error loading clients:', error);
        } finally {
            setLoading(false);
        }
    };

    const loadClientStats = async (clientId: number) => {
        setStatsLoading(true);
        try {
            const data = await getClientStats(clientId);
            setClientStats(data.stats);
        } catch (error) {
            console.error('Error loading stats:', error);
            setClientStats(null);
        } finally {
            setStatsLoading(false);
        }
    };

    const handleViewDetails = (client: User) => {
        setSelectedClient(client);
        loadClientStats(client.idUtilisateur);
    };

    const handleDelete = async (client: User) => {
        if (!confirm(`Êtes-vous sûr de vouloir supprimer ${client.nomComplet} ?`)) {
            return;
        }

        setDeleteLoading(true);
        try {
            await deleteUser(client.idUtilisateur);
            alert(`${client.nomComplet} a été supprimé avec succès`);
            loadClients(); // Reload the list
        } catch (error: any) {
            alert(error.response?.data?.message || 'Erreur lors de la suppression');
        } finally {
            setDeleteLoading(false);
        }
    };

    const filteredClients = clients.filter((c) =>
        c.nomComplet.toLowerCase().includes(searchQuery.toLowerCase()) ||
        c.email.toLowerCase().includes(searchQuery.toLowerCase())
    );

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
                    <h1 className="text-xl font-bold text-white">Clients</h1>
                    <p className="text-sm text-gray-500 mt-0.5">Gérez tous les clients enregistrés</p>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 rounded-xl" style={{ background: 'rgba(99,102,241,0.1)', border: '1px solid rgba(99,102,241,0.2)' }}>
                    <Users className="w-4 h-4 text-indigo-400" />
                    <span className="text-indigo-400 font-bold text-lg">{filteredClients.length}</span>
                    <span className="text-indigo-400/60 text-sm">clients</span>
                </div>
            </div>

            {/* Search + Filter */}
            <div className="flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-600 w-4 h-4" />
                    <input
                        type="text"
                        placeholder="Rechercher par nom ou email..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 text-sm rounded-xl text-gray-300 placeholder-gray-600 outline-none"
                        style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.08)' }}
                    />
                </div>
                <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="px-3 py-2 text-sm rounded-xl text-gray-300 outline-none"
                    style={{ background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.08)' }}
                >
                    <option value="all">Tous les statuts</option>
                    <option value="actif">Actif</option>
                    <option value="suspendu">Suspendu</option>
                </select>
            </div>

            {/* Clients Table */}
            {filteredClients.length === 0 ? (
                <div className="rounded-2xl p-12 text-center" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}>
                    <Users className="w-12 h-12 text-gray-600 mx-auto mb-3" />
                    <p className="text-sm font-medium text-white mb-1">Aucun client trouvé</p>
                    <p className="text-sm text-gray-600">Aucun client ne correspond à votre recherche</p>
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
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Ville</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Date</th>
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredClients.map((client) => (
                                    <tr key={client.idUtilisateur} className="transition-colors hover:bg-white/[0.02]" style={{ borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                                        <td className="px-5 py-3.5">
                                            <div className="flex items-center gap-2.5">
                                                <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0"
                                                    style={{ background: 'linear-gradient(135deg,#6366f1,#8b5cf6)' }}
                                                >
                                                    {client.nomComplet?.charAt(0).toUpperCase()}
                                                </div>
                                                <span className="text-sm font-medium text-gray-100">{client.nomComplet}</span>
                                            </div>
                                        </td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{client.email}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{client.telephone || '-'}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{client.ville || '-'}</td>
                                        <td className="px-5 py-3.5 text-sm text-gray-400">{new Date(client.created_at).toLocaleDateString('fr-FR')}</td>
                                        <td className="px-5 py-3.5">
                                            <div className="flex gap-3">
                                                <button onClick={() => handleViewDetails(client)} className="text-xs font-medium text-emerald-400 hover:text-emerald-300 transition-colors">
                                                    Détails
                                                </button>
                                                <button onClick={() => handleDelete(client)} className="text-xs font-medium text-red-400 hover:text-red-300 transition-colors">
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
            {selectedClient && (
                <div className="fixed inset-0 flex items-center justify-center z-50 p-4" style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)' }}>
                    <div className="rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto" style={{ background: '#13151e', border: '1px solid rgba(255,255,255,0.1)' }}>
                        {/* Header */}
                        <div className="p-5" style={{ borderBottom: '1px solid rgba(255,255,255,0.07)' }}>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white"
                                        style={{ background: 'linear-gradient(135deg,#6366f1,#8b5cf6)' }}
                                    >
                                        {selectedClient.nomComplet?.charAt(0).toUpperCase()}
                                    </div>
                                    <div>
                                        <h2 className="text-base font-bold text-white">{selectedClient.nomComplet}</h2>
                                        <p className="text-xs text-gray-500">{selectedClient.email}</p>
                                    </div>
                                </div>
                                <button onClick={() => setSelectedClient(null)} className="p-2 rounded-lg text-gray-500 hover:text-white hover:bg-white/5 transition-colors">
                                    ✕
                                </button>
                            </div>
                        </div>

                        <div className="p-5 space-y-4">
                            {/* Info grid */}
                            <div className="grid grid-cols-2 gap-3">
                                {([
                                    ['Téléphone', selectedClient.telephone || '-'],
                                    ['Ville', selectedClient.ville || '-'],
                                    ['Adresse', selectedClient.adresse || '-'],
                                    ['Inscription', new Date(selectedClient.created_at).toLocaleDateString('fr-FR')],
                                ] as [string, string][]).map(([label, val]) => (
                                    <div key={label} className="p-3 rounded-xl" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.06)' }}>
                                        <p className="text-[10px] uppercase tracking-wider text-gray-600 mb-0.5">{label}</p>
                                        <p className="text-sm font-medium text-gray-200">{val}</p>
                                    </div>
                                ))}
                            </div>

                            {/* Statistics */}
                            {statsLoading && (
                                <div className="flex items-center gap-2 text-sm text-gray-600 py-2">
                                    <div className="w-4 h-4 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin" />
                                    Chargement des statistiques...
                                </div>
                            )}
                            {clientStats && (
                                <div className="space-y-3" style={{ borderTop: '1px solid rgba(255,255,255,0.07)', paddingTop: '1rem' }}>
                                    <p className="text-[11px] uppercase tracking-wider text-gray-600 font-semibold">Statistiques</p>
                                    <div className="grid grid-cols-3 gap-3">
                                        {[
                                            { label: 'Réservations', value: clientStats.total_reservations ?? 0, icon: ShoppingCart, color: '#10b981', bg: 'rgba(16,185,129,0.1)' },
                                            { label: 'Terminées', value: clientStats.completed_reservations ?? 0, icon: CheckCircle, color: '#6366f1', bg: 'rgba(99,102,241,0.1)' },
                                            { label: 'Annulées', value: clientStats.cancelled_reservations ?? 0, icon: XCircle, color: '#ef4444', bg: 'rgba(239,68,68,0.1)' },
                                        ].map(({ label, value, icon: Icon, color, bg }) => (
                                            <div key={label} className="p-3 rounded-xl text-center" style={{ background: bg, border: `1px solid ${color}33` }}>
                                                <Icon className="w-4 h-4 mx-auto mb-1" style={{ color }} />
                                                <p className="text-xl font-bold" style={{ color }}>{value}</p>
                                                <p className="text-[10px] text-gray-600 mt-0.5">{label}</p>
                                            </div>
                                        ))}
                                    </div>

                                    {clientStats.recent_reservations?.length > 0 && (
                                        <div>
                                            <p className="text-[10px] uppercase tracking-wider text-gray-600 mb-2">Réservations récentes</p>
                                            <div className="space-y-1.5">
                                                {clientStats.recent_reservations.map((res: any, idx: number) => (
                                                    <div key={idx} className="flex items-center justify-between px-3 py-2 rounded-lg" style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid rgba(255,255,255,0.05)' }}>
                                                        <span className="text-sm text-gray-300">{res.nomMedicament}</span>
                                                        <span className="text-[11px] px-2 py-0.5 rounded-full" style={{
                                                            color: res.statut === 'termine' ? '#10b981' : res.statut === 'annule' ? '#ef4444' : '#f59e0b',
                                                            background: res.statut === 'termine' ? 'rgba(16,185,129,0.1)' : res.statut === 'annule' ? 'rgba(239,68,68,0.1)' : 'rgba(245,158,11,0.1)',
                                                        }}>{res.statut}</span>
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>

                        <div className="px-5 pb-5">
                            <button
                                onClick={() => setSelectedClient(null)}
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
