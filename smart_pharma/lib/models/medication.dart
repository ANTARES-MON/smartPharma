
class Medication {
  final String id;
  final String name;
  final int stock;
  final double price;
  final String category;
  final bool requiresPrescription;
  final String? imageUrl;
  final String? barcode;

  Medication({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.category,
    required this.requiresPrescription,
    this.imageUrl,
    this.barcode,
  });

  bool get necessiteOrdonnance => requiresPrescription;

  factory Medication.fromJson(Map<String, dynamic> json) {
    final medData = json['medicament'] ?? json['medication'] ?? json;

    return Medication(
      id: json['id']?.toString() ?? medData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      
      name: medData['name'] ?? medData['nom'] ?? 'Médicament Inconnu',
      
      stock: int.tryParse((json['stock'] ?? json['quantite'] ?? json['quantity'] ?? '0').toString()) ?? 0,
      
      price: double.tryParse((json['price'] ?? json['prix'] ?? medData['price'] ?? medData['prix'] ?? '0.0').toString()) ?? 0.0,
      
      category: medData['category'] ?? medData['categorie'] ?? 'Général',
      
      requiresPrescription: _parseBool(medData['necessite_ordonnance']) || 
                            _parseBool(medData['requires_prescription']) ||
                            _parseBool(medData['ordonnance_obligatoire']),
                            
      imageUrl: medData['image_url'] ?? medData['photo'] ?? medData['image'],
      barcode: medData['barcode'] ?? medData['code_barre'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'price': price,
      'category': category,
      'requires_prescription': requiresPrescription,
      'image_url': imageUrl,
      'barcode': barcode,
    };
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value == true || value == 1 || value == '1' || value == 'true') return true;
    return false;
  }
}