'use client';

import { useEffect, useState } from 'react';
import { Clock, CheckCircle, XCircle, Eye, Download } from 'lucide-react';
import { getPendingPharmacists, approvePharmacist, rejectPharmacist } from '@/lib/api';
import type { User } from '@/types';

export default function PendingPage() {
    const [pharmacists, setPharmacists] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedPharmacist, setSelectedPharmacist] = useState<User | null>(null);
    const [actionLoading, setActionLoading] = useState(false);

    useEffect(() => {
        loadPendingPharmacists();
    }, []);

    const loadPendingPharmacists = async () => {
        setLoading(true);
        try {
            const data = await getPendingPharmacists();
            setPharmacists(data.pharmacists);
        } catch (error) {
            console.error('Error loading pending pharmacists:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleApprove = async (id: number) => {
        if (!confirm('Approuver ce pharmacien?')) return;

        setActionLoading(true);
        try {
            await approvePharmacist(id);
            await loadPendingPharmacists();
            setSelectedPharmacist(null);
        } catch (error) {
            console.error('Error approving pharmacist:', error);
            alert("Erreur lors de l'approbation");
        } finally {
            setActionLoading(false);
        }
    };

    const handleReject = async (id: number) => {
        const reason = prompt('Raison du rejet (optionnel):');
        if (reason === null) return; // User cancelled

        setActionLoading(true);
        try {
            await rejectPharmacist(id, reason || undefined);
            await loadPendingPharmacists();
            setSelectedPharmacist(null);
        } catch (error) {
            console.error('Error rejecting pharmacist:', error);
            alert("Erreur lors du rejet");
        } finally {
            setActionLoading(false);
        }
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
                    <h1 className="text-xl font-bold text-white">Pharmaciens en attente</h1>
                    <p className="text-sm text-gray-500 mt-0.5">Examinez et approuvez les demandes d&apos;inscription</p>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 rounded-xl" style={{ background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.2)' }}>
                    <Clock className="w-4 h-4 text-amber-400" />
                    <span className="text-amber-400 font-bold text-lg">{pharmacists.length}</span>
                    <span className="text-amber-500/70 text-sm">en attente</span>
                </div>
            </div>

            {/* List */}
            {pharmacists.length === 0 ? (
                <div className="rounded-2xl p-12 text-center" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.07)' }}>
                    <CheckCircle className="w-12 h-12 text-emerald-400 mx-auto mb-3 opacity-60" />
                    <h3 className="text-base font-semibold text-white mb-1">Aucune demande en attente</h3>
                    <p className="text-sm text-gray-600">Toutes les demandes ont été traitées!</p>
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
                                    <th className="px-5 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-gray-500">Date</th>
                                    <th className="px-5 py-3.5 text-right text-[11px] font-semibold uppercase tracking-wider text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {pharmacists.map((pharmacist) => (
                                    <tr key={pharmacist.idUtilisateur} className="transition-colors hover:bg-white/[0.02]" style={{ borderBottom: '1px solid rgba(255,255,255,0.04)' }}>
                                        <td className="px-5 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0"
                                                    style={{ background: 'linear-gradient(135deg,#f59e0b,#d97706)' }}
                                                >
                                                    {pharmacist.nomComplet?.charAt(0).toUpperCase()}
                                                </div>
                                                <span className="text-sm font-medium text-gray-100">{pharmacist.nomComplet}</span>
                                            </div>
                                        </td>
                                        <td className="px-5 py-4 text-sm text-gray-400">{pharmacist.email}</td>
                                        <td className="px-5 py-4 text-sm text-gray-400">{pharmacist.telephone || '-'}</td>
                                        <td className="px-5 py-4 text-sm text-gray-400">{new Date(pharmacist.created_at).toLocaleDateString('fr-FR')}</td>
                                        <td className="px-5 py-4">
                                            <div className="flex items-center justify-end gap-1">
                                                <button
                                                    onClick={() => setSelectedPharmacist(pharmacist)}
                                                    className="p-1.5 rounded-lg text-blue-400 hover:bg-blue-500/10 transition-colors"
                                                    title="Voir détails"
                                                >
                                                    <Eye className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleApprove(pharmacist.idUtilisateur)}
                                                    disabled={actionLoading}
                                                    className="p-1.5 rounded-lg text-emerald-400 hover:bg-emerald-500/10 transition-colors disabled:opacity-40"
                                                    title="Approuver"
                                                >
                                                    <CheckCircle className="w-4 h-4" />
                                                </button>
                                                <button
                                                    onClick={() => handleReject(pharmacist.idUtilisateur)}
                                                    disabled={actionLoading}
                                                    className="p-1.5 rounded-lg text-red-400 hover:bg-red-500/10 transition-colors disabled:opacity-40"
                                                    title="Rejeter"
                                                >
                                                    <XCircle className="w-4 h-4" />
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

            {/* Detail Modal */}
            {selectedPharmacist && (
                <div className="fixed inset-0 flex items-center justify-center z-50 p-4" style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)' }}>
                    <div className="rounded-2xl max-w-4xl w-full p-6 max-h-[90vh] overflow-y-auto" style={{ background: '#13151e', border: '1px solid rgba(255,255,255,0.1)' }}>
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <h2 className="text-lg font-bold text-white">Détails du pharmacien</h2>
                                <p className="text-xs text-gray-500 mt-0.5">Dossier de candidature</p>
                            </div>
                            <button onClick={() => setSelectedPharmacist(null)} className="p-2 rounded-lg text-gray-500 hover:text-white hover:bg-white/5 transition-colors">
                                <XCircle className="w-5 h-5" />
                            </button>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {/* Left - Info */}
                            <div className="space-y-4">
                                {([
                                    ['Nom complet', selectedPharmacist.nomComplet],
                                    ['Email', selectedPharmacist.email],
                                    ['Téléphone', selectedPharmacist.telephone || 'Non renseigné'],
                                    ['Date inscription', new Date(selectedPharmacist.created_at).toLocaleString('fr-FR')],
                                ] as [string, string][]).map(([label, val]) => (
                                    <div key={label} className="p-3 rounded-xl" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.06)' }}>
                                        <p className="text-[11px] font-medium uppercase tracking-wider text-gray-600 mb-1">{label}</p>
                                        <p className="text-sm font-medium text-gray-100">{val}</p>
                                    </div>
                                ))}
                                {selectedPharmacist.pharmacy && (
                                    <div className="p-3 rounded-xl" style={{ background: 'rgba(16,185,129,0.08)', border: '1px solid rgba(16,185,129,0.2)' }}>
                                        <p className="text-[11px] font-medium uppercase tracking-wider text-emerald-600 mb-1">Pharmacie</p>
                                        <p className="text-sm font-medium text-emerald-300">{selectedPharmacist.pharmacy.nom}</p>
                                        {selectedPharmacist.pharmacy.adresse && <p className="text-xs text-emerald-500/70 mt-0.5">{selectedPharmacist.pharmacy.adresse}</p>}
                                    </div>
                                )}
                            </div>

                            {/* Right - License photo */}
                            <div>
                                <p className="text-[11px] font-medium uppercase tracking-wider text-gray-600 mb-2">Photo de licence</p>
                                {selectedPharmacist.photo_licence ? (
                                    <div className="space-y-3">
                                        <div className="rounded-xl overflow-hidden" style={{ border: '1px solid rgba(255,255,255,0.08)' }}>
                                            <img
                                                src={`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}`}
                                                alt="Licence du pharmacien"
                                                className="w-full h-auto object-contain max-h-72 cursor-pointer hover:opacity-80 transition"
                                                onClick={() => window.open(`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}`, '_blank')}
                                            />
                                        </div>
                                        <a
                                            href={`${process.env.NEXT_PUBLIC_API_URL}/admin/license-photo/${selectedPharmacist.idUtilisateur}/download`}
                                            download
                                            className="flex items-center justify-center gap-2 w-full px-4 py-2 rounded-xl text-sm font-medium transition-colors"
                                            style={{ background: 'rgba(59,130,246,0.12)', border: '1px solid rgba(59,130,246,0.3)', color: '#60a5fa' }}
                                        >
                                            <Download className="w-4 h-4" />
                                            Télécharger la licence
                                        </a>
                                    </div>
                                ) : (
                                    <div className="rounded-xl p-8 text-center" style={{ border: '2px dashed rgba(255,255,255,0.08)' }}>
                                        <p className="text-sm text-gray-600">Aucune photo de licence</p>
                                    </div>
                                )}
                            </div>
                        </div>

                        <div className="flex gap-3 mt-6 pt-5" style={{ borderTop: '1px solid rgba(255,255,255,0.07)' }}>
                            <button
                                onClick={() => handleApprove(selectedPharmacist.idUtilisateur)}
                                disabled={actionLoading}
                                className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-medium text-sm transition-colors disabled:opacity-40"
                                style={{ background: 'rgba(16,185,129,0.15)', border: '1px solid rgba(16,185,129,0.3)', color: '#10b981' }}
                            >
                                <CheckCircle className="w-4 h-4" /> Approuver
                            </button>
                            <button
                                onClick={() => handleReject(selectedPharmacist.idUtilisateur)}
                                disabled={actionLoading}
                                className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-medium text-sm transition-colors disabled:opacity-40"
                                style={{ background: 'rgba(239,68,68,0.12)', border: '1px solid rgba(239,68,68,0.25)', color: '#f87171' }}
                            >
                                <XCircle className="w-4 h-4" /> Rejeter
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
