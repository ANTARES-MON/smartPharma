export interface User {
  idUtilisateur: number;
  nomComplet: string;
  email: string;
  telephone: string | null;
  ville: string | null;
  adresse: string | null;
  photo_licence: string | null;
  role: 'client' | 'pharmacien' | 'admin';
  statut: 'actif' | 'en_attente' | 'suspendu';
  created_at: string;
  updated_at: string;
  pharmacy?: Pharmacy;
}

export interface Pharmacy {
  idPharmacie: number;
  nom: string;
  adresse: string;
  latitude: number;
  longitude: number;
}

export interface Stats {
  totalUsers: number;
  totalClients: number;
  totalPharmacists: number;
  pendingPharmacists: number;
  activePharmacists: number;
  totalPharmacies: number;
  totalReservations: number;
  recentRegistrations: number;
}

export interface RegistrationData {
  date: string;
  count: number;
  clients: number;
  pharmacists: number;
}

export interface MonthlyActivity {
  month: string;
  users: number;
  reservations: number;
}

export interface RecentActivity {
  idUtilisateur: number;
  nomComplet: string;
  email: string;
  role: string;
  statut: string;
  created_at: string;
}
