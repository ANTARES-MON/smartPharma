import 'package:geolocator/geolocator.dart';

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String distanceFallback;
  final String phone;
  final List<String> medications;
  final bool isOnCall;
  final Map<String, String> schedule;
  final String? imageUrl;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceFallback,
    required this.phone,
    required this.medications,
    required this.isOnCall,
    required this.schedule,
    this.imageUrl,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'Pharmacie Inconnue',
      address: json['address'] ?? 'Adresse non disponible',

      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,

      distanceFallback: json['distance_fallback'] ?? '',
      phone: json['phone'] ?? '',

      medications: (json['medications'] is List)
          ? List<String>.from(json['medications'].map((x) => x.toString()))
          : [],

      isOnCall: json['is_on_call'] == 1 || json['is_on_call'] == true,

      schedule: (json['schedule'] is Map)
          ? Map<String, String>.from(json['schedule'])
          : {},

      imageUrl: json['image_url'] ?? json['photo'],
    );
  }

  String get calculatedStatus {
    if (isOnCall) return 'on-call';
    if (isClosingSoon) return 'closing-soon';
    if (_isOpenNow()) return 'open';
    return 'closed';
  }

  String get todayHours {
    if (schedule.isEmpty) return 'Horaires non disponibles';

    List<String> days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    int todayIndex = DateTime.now().weekday - 1;

    final dayName = days[todayIndex];
    return schedule[dayName] ?? 'Fermé';
  }

  bool _isOpenNow() {
    try {
      final hours = todayHours;
      if (hours.toLowerCase().contains('fermé')) return false;
      if (hours.contains('24h') || hours.contains('24/24')) return true;

      final cleanHours = hours.replaceAll('h', ':').replaceAll(' ', '');
      final parts = cleanHours.split('-');

      if (parts.length != 2) return false;

      int toMins(String t) {
        final timeParts = t.split(':');
        return int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
      }

      final startMins = toMins(parts[0]);
      final endMins = toMins(parts[1]);

      final now = DateTime.now();
      final nowMins = (now.hour * 60) + now.minute;

      if (endMins < startMins) {
        return nowMins >= startMins || nowMins < endMins;
      }

      return nowMins >= startMins && nowMins < endMins;
    } catch (e) {
      return false;
    }
  }

  bool get isClosingSoon {
    try {
      if (!calculatedStatus.contains('open')) return false;
      final hours = todayHours;
      if (hours.contains('24h')) return false;

      final cleanHours = hours.replaceAll('h', ':').replaceAll(' ', '');
      final closingString = cleanHours.split('-').last;
      final timeParts = closingString.split(':');

      final closingHour = int.parse(timeParts[0]);
      final closingMin = int.parse(timeParts[1]);

      final now = DateTime.now();
      final closingTime = DateTime(
        now.year,
        now.month,
        now.day,
        closingHour,
        closingMin,
      );

      final diff = closingTime.difference(now).inMinutes;
      return diff > 0 && diff <= 30;
    } catch (e) {
      return false;
    }
  }

  String getRealDistance(double? userLat, double? userLng) {
    if (userLat == null || userLng == null || (lat == 0 && lng == 0)) {
      return '-- km';
    }

    double dist = Geolocator.distanceBetween(userLat, userLng, lat, lng);

    if (dist < 1000) {
      return "${dist.round()} m";
    } else {
      return "${(dist / 1000).toStringAsFixed(1)} km";
    }
  }
}
