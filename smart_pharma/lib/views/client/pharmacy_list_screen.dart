import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/pharmacy.dart';
import '../../providers/pharmacy_provider.dart'; // Assumes favoritesProvider is here or exported
import 'pharmacy_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class PharmacyListScreen extends ConsumerStatefulWidget {
  const PharmacyListScreen({super.key});

  @override
  ConsumerState<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends ConsumerState<PharmacyListScreen> {
  String _filter = 'all'; // 'all', 'open', 'on-call'
  Position? _userPosition;

  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      
      if (mounted) {
        setState(() {
          _userPosition = pos;
        });
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  List<Pharmacy> _applyFilters(List<Pharmacy> allPharmacies) {
    List<Pharmacy> filtered;

    // 1. Filter by Status using calculatedStatus string
    if (_filter == 'all') {
      filtered = List.from(allPharmacies);
    } else if (_filter == 'open') {
      // Check against status strings: 'open', 'closing-soon', or 'on-call'
      filtered = allPharmacies.where((p) {
        final s = p.calculatedStatus;
        return s == 'open' || s == 'closing-soon' || s == 'on-call';
      }).toList();
    } else {
      // Strictly on-call
      filtered = allPharmacies.where((p) => p.calculatedStatus == 'on-call').toList();
    }

    // 2. Sort by Distance (if location exists)
    if (_userPosition != null) {
      filtered.sort((a, b) {
        double distA = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, a.lat, a.lng);
        double distB = Geolocator.distanceBetween(
            _userPosition!.latitude, _userPosition!.longitude, b.lat, b.lng);
        return distA.compareTo(distB);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyAsync = ref.watch(pharmacyListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // HEADER
          _buildHeader(context),
          
          // FILTERS
          _buildFilterRow(),

          // LIST
          Expanded(
            child: pharmacyAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: emerald500),
              ),
              error: (err, stack) => Center(child: Text("Erreur: $err")),
              data: (pharmacies) {
                final displayedPharmacies = _applyFilters(pharmacies);

                if (displayedPharmacies.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: displayedPharmacies.length,
                  itemBuilder: (context, index) {
                    return _buildPharmacyCard(displayedPharmacies[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [emerald500, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                AppLocalizations.of(context)!.pharmacies,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40), 
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Trouvez les pharmacies à proximité",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FILTER CHIPS
  // ==========================================
  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _filterChip("Toutes", 'all'),
          const SizedBox(width: 10),
          _filterChip("Ouvertes", 'open'),
          const SizedBox(width: 10),
          _filterChip("De garde", 'on-call'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final bool isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? emerald600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: emerald600.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PHARMACY CARD
  // ==========================================
  Widget _buildPharmacyCard(Pharmacy p) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(p.id);

    // Calculate Distance String
    String distanceText = "-- ${AppLocalizations.of(context)!.km}";
    if (_userPosition != null) {
      double distMeters = Geolocator.distanceBetween(
        _userPosition!.latitude, 
        _userPosition!.longitude, 
        p.lat, 
        p.lng
      );
      if (distMeters < 1000) {
        distanceText = "${distMeters.toInt()} m";
      } else {
        distanceText = "${(distMeters / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}";
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PharmacyDetailScreen(pharmacy: p)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Name + Favorite Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(p.id),
                  child: Icon(
                    LucideIcons.heart,
                    color: isFavorite ? const Color(0xFFEC4899) : Colors.grey[300],
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address Row
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Row: Status Badge + Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusBadge(p.calculatedStatus),
                Row(
                  children: [
                    const Icon(LucideIcons.navigation, size: 14, color: emerald500),
                    const SizedBox(width: 4),
                    Text(
                      distanceText,
                      style: const TextStyle(
                        color: emerald600,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  Widget _statusBadge(String status) {
    Color bg;
    Color text;
    String label;

    if (status == 'on-call') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      label = "DE GARDE";
    } else if (status == 'closing-soon') {
      bg = const Color(0xFFFEF9C3);
      text = const Color(0xFF854D0E);
      label = "FERME BIENTÔT";
    } else if (status == 'open') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
      label = "OUVERTE";
    } else {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
      label = AppLocalizations.of(context)!.closedCaps;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucune pharmacie trouvée",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}