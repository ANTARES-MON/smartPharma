String _mapStatus(String backendStatus) {
  switch (backendStatus.toLowerCase()) {
    case 'en_attente':
      return 'pending';
    case 'acceptee':
      return 'accepted';
    case 'refusee':
      return 'rejected';
    case 'terminee':
      return 'completed';
    case 'annulee':
      return 'cancelled';
    case 'pending':
    case 'accepted':
    case 'rejected':
    case 'cancelled':
    case 'completed':
      return backendStatus.toLowerCase();
    default:
      return 'pending';
  }
}

class Reservation {
  final String id;
  final String qrCode;
  final String userId;
  final String pharmacyId;
  final String stockId;

  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyPhone;
  final String medicationName;

  final String patientName;
  final String patientPhone;
  final int quantity;
  final String status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.pharmacyId,
    required this.stockId,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.pharmacyPhone,
    required this.medicationName,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.patientName = "",
    this.patientPhone = "",
    this.qrCode = "",
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final dynamic pharmacyObj = json['pharmacy'] ?? json['pharmacie'];
    final dynamic medicamentObj = json['medicament'] ?? json['medication'] ?? json['med'];
    final dynamic userObj = json['utilisateur'] ?? json['user'];

    String? readNestedName(dynamic obj) {
      if (obj is Map) {
        return (obj['nom'] ?? obj['name'] ?? obj['pharmacy_name'] ?? obj['medication_name'])?.toString();
      }
      return null;
    }

    String dateStr = json['created_at'] ?? json['dateReservation'] ?? '';
    DateTime parsedDate;

    if (dateStr.isEmpty) {
      parsedDate = DateTime.now();
    } else {
      if (!dateStr.endsWith('Z') && !dateStr.contains('T')) {
        dateStr += 'Z';
      }
      parsedDate = DateTime.parse(dateStr).toLocal();
    }

    final reservationId = json['idReservation']?.toString() ?? json['id']?.toString() ?? '';
    final qrCode = json['qr_code']?.toString() ?? '';

    return Reservation(
      id: reservationId,
      qrCode: qrCode,
      userId: json['idUtilisateur']?.toString() ?? json['user_id']?.toString() ?? '',
      pharmacyId: json['idPharmacie']?.toString() ?? json['pharmacy_id']?.toString() ?? '',
      stockId: json['idStock']?.toString() ?? json['stock_id']?.toString() ?? '',

      pharmacyName: (json['pharmacy_name'] ??
              json['pharmacie_nom'] ??
              json['nom_pharmacie'] ??
              readNestedName(pharmacyObj) ??
              json['nom'])
          ?.toString() ??
          'Pharmacie',
      pharmacyAddress: (json['pharmacy_address'] ??
              json['adresse_pharmacie'] ??
              (pharmacyObj is Map ? pharmacyObj['adresse'] : null))
          ?.toString() ??
          '',
      pharmacyPhone: (json['pharmacy_phone'] ??
              json['telephone_pharmacie'] ??
              (pharmacyObj is Map ? pharmacyObj['telephone'] : null))
          ?.toString() ??
          '',

      medicationName: (json['medication_name'] ??
              json['medicationName'] ??
              json['real_med_name'] ??
              json['medicament_nom'] ??
              json['nom_medicament'] ??
              readNestedName(medicamentObj))
          ?.toString() ??
          'Médicament',

      patientName: userObj?['nomComplet'] ?? userObj?['name'] ?? json['nom_patient'] ?? 'Client Inconnu',
      patientPhone: userObj?['telephone'] ?? userObj?['phone'] ?? json['telephone'] ?? 'Numéro non disponible',

      quantity: int.tryParse(
            (json['quantiteDemande'] ?? json['quantite'] ?? json['quantity'] ?? '1').toString(),
          ) ??
          1,

      status: _mapStatus(json['statut'] ?? json['status'] ?? 'pending'),

      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUtilisateur': int.tryParse(userId) ?? 0,
      'idStock': int.tryParse(stockId) ?? 0,
      'idPharmacie': int.tryParse(pharmacyId) ?? 0,
      'quantite': quantity,
      'nom_patient': patientName,
      'telephone': patientPhone,
      'statut': 'en_attente',
    };
  }

  Reservation copyWith({
    String? status,
    String? qrCode,
  }) {
    return Reservation(
      id: id,
      qrCode: qrCode ?? this.qrCode,
      userId: userId,
      pharmacyId: pharmacyId,
      stockId: stockId,
      pharmacyName: pharmacyName,
      pharmacyAddress: pharmacyAddress,
      pharmacyPhone: pharmacyPhone,
      medicationName: medicationName,
      quantity: quantity,
      status: status ?? this.status,
      createdAt: createdAt,
      patientName: patientName,
      patientPhone: patientPhone,
    );
  }
}