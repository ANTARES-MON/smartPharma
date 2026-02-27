class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? city;
  final String? address;
  final String? photo;
  final Map<String, dynamic>? pharmacy;
  final int? pharmacyId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.city,
    this.address,
    this.photo,
    this.pharmacy,
    this.pharmacyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['idUtilisateur'] ?? json['id'] ?? 0,
      name: json['nomComplet'] ?? json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['telephone'] ?? json['phone'],
      role: json['role'] ?? 'client',
      city: json['ville'] ?? json['city'],
      address: json['adresse'] ?? json['address'],
      photo: json['photo'],
      pharmacy: json['pharmacy'] as Map<String, dynamic>?,
      pharmacyId: json['pharmacyId'] ?? json['pharmacy']?['idPharmacie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'city': city,
      'address': address,
      'photo': photo,
      'pharmacy': pharmacy,
      'pharmacyId': pharmacyId,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? city,
    String? address,
    String? photo,
    Map<String, dynamic>? pharmacy,
    int? pharmacyId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      city: city ?? this.city,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      pharmacy: pharmacy ?? this.pharmacy,
      pharmacyId: pharmacyId ?? this.pharmacyId,
    );
  }

  bool get isPharmacist => role == 'pharmacist' || role == 'pharmacien';
  bool get isClient => role == 'client';
}