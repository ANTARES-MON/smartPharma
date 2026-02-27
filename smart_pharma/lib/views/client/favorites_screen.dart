import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/pharmacy.dart';
import '../../providers/pharmacy_provider.dart';
import '../../providers/location_provider.dart'; 
import 'pharmacy_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  final bool showBackButton;
  
  const FavoritesScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Data
    final favoriteIds = ref.watch(favoritesProvider);
    final pharmacyAsync = ref.watch(pharmacyListProvider);
    final userLocation = ref.watch(userLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // HEADER (Pink Gradient + Rounded Bottom)
          _buildHeader(context, favoriteIds.length),
          
          // LIST
          Expanded(
            child: pharmacyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFEC4899))),
              error: (e, s) => Center(child: Text("Erreur: $e")),
              data: (allPharmacies) {
                // Filter only favorites
                final favoritePharmacies = allPharmacies
                    .where((p) => favoriteIds.contains(p.id))
                    .toList();

                if (favoritePharmacies.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: favoritePharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = favoritePharmacies[index];
                    return _buildFavCard(context, ref, pharmacy, userLocation);
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
  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, showBackButton ? 50 : 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFE11D48)], // Pink/Rose Gradient
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
          // Top Row: Back + Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                )
              else
                const SizedBox(width: 20), // Spacer if no back button

              Text(
                AppLocalizations.of(context)!.myFavorites,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Count Badge (Visual Balance)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.savedPharmacies,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FAVORITE CARD
  // ==========================================
  Widget _buildFavCard(BuildContext context, WidgetRef ref, Pharmacy p, Position? userLocation) {
    
    // Calculate Distance
    String distanceText = "-- ${AppLocalizations.of(context)!.km}";
    if (userLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        p.lat,
        p.lng,
      );
      if (distanceInMeters < 1000) {
        distanceText = "${distanceInMeters.toInt()} m";
      } else {
        distanceText = "${(distanceInMeters / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}";
      }
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => PharmacyDetailScreen(pharmacy: p))
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
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statusBadge(p.calculatedStatus, context),
                          const SizedBox(width: 8),
                          Text(
                            distanceText,
                            style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Heart Button
                GestureDetector(
                  onTap: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${p.name} retiré des favoris"),
                        backgroundColor: Colors.grey[800],
                        duration: const Duration(milliseconds: 1500),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8), // Light pink bg
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.heart, color: Color(0xFFEC4899), size: 20),
                  ),
                ),
              ],
            ),
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            
            // Details
            _iconText(LucideIcons.mapPin, p.address),
            _iconText(LucideIcons.clock, "${AppLocalizations.of(context)!.today}: ${p.todayHours}"),
            _iconText(LucideIcons.phone, p.phone),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, BuildContext context) {
    Color bg; Color text; String label;
    if (status == 'on-call') {
      bg = const Color(0xFFFFEDD5); text = const Color(0xFFC2410C); label = "DE GARDE";
    } else if (status == 'open') {
      bg = const Color(0xFFDCFCE7); text = const Color(0xFF15803D); label = "OUVERTE";
    } else if (status == 'closing-soon') {
      bg = const Color(0xFFFEF9C3); text = const Color(0xFF854D0E); label = "FERME BIENTÔT";
    } else {
      bg = const Color(0xFFFEE2E2); text = const Color(0xFFB91C1C); label = AppLocalizations.of(context)!.closedCaps;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.heartOff, size: 40, color: Color(0xFFF472B6)),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noFavorites, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.addPharmaciesToList,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}