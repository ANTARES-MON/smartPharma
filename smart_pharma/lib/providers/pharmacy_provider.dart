import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pharmacy.dart';
import '../models/medication.dart';
import 'app_provider.dart';

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_pharmacies');
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (state.contains(id)) {
      state = [for (final pid in state) if (pid != id) pid];
    } else {
      state = [...state, id];
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_pharmacies', state);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

final pharmacyListProvider = FutureProvider<List<Pharmacy>>((ref) async {
  final api = ref.read(apiServiceProvider); 
  
  try {
    final response = await api.getPharmacies();
    
    final List<dynamic> data = (response.data is Map && response.data.containsKey('data')) 
        ? response.data['data'] 
        : response.data;

    return data.map((json) => Pharmacy.fromJson(json)).toList();

  } catch (e) {
    debugPrint("Error fetching pharmacies: $e");
    throw Exception("Impossible de charger les pharmacies.");
  }
});

final pharmacyStockProvider = FutureProvider.family<List<Medication>, String>((ref, pharmacyId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.getPharmacyStock(pharmacyId);
    
    final List<dynamic> data = (response.data is Map && response.data.containsKey('data')) 
        ? response.data['data'] 
        : response.data;

    return data.map((json) => Medication.fromJson(json)).toList();
  } catch (e) {
    debugPrint("Stock load error: $e");
    return [];
  }
});