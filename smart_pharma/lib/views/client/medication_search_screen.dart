import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/pharmacy.dart';
import '../../providers/app_provider.dart';
import 'pharmacy_detail_screen.dart';
import 'medication_barcode_scanner.dart';
import '../../l10n/app_localizations.dart';

class MedicationSearchScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  const MedicationSearchScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<MedicationSearchScreen> createState() => _MedicationSearchScreenState();
}

class _MedicationSearchScreenState extends ConsumerState<MedicationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // State variables
  String _searchQuery = "";
  bool _isSearching = false;
  bool _hasSearched = false;
  List<Pharmacy> _searchResults = [];
  Position? _userPosition;

  // Colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  // Popular meds for quick access
  final List<String> _popularMedications = [
    'Doliprane', 'Efferalgan', 'Spasfon', 'Amoxicilline', 
    'Fervex', 'Ibuprofène', 'DoliRhume', 'Smecta'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 📍 Get User Location
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _userPosition = pos);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // 🔍 Perform Search
  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _searchQuery = query;
      _searchController.text = query; // Update text if clicked from chips
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.searchMedications(query);

      // Adjust parsing based on your actual API response structure
      if (response.statusCode == 200) {
        // Assuming response.data['data'] is the list of pharmacies
        final List<dynamic> data = response.data['data'] ?? [];
        final List<Pharmacy> results = data.map((json) => Pharmacy.fromJson(json)).toList();

        // Sort by distance if location is available
        if (_userPosition != null) {
          results.sort((a, b) {
            double distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.lat, a.lng);
            double distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.lat, b.lng);
            return distA.compareTo(distB);
          });
        }

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: ${e is DioException ? 'Connexion impossible' : e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // 🔍 Handle Barcode Search
  Future<void> _handleBarcodeSearch(String barcode) async {
    setState(() {
      _searchQuery = barcode;
      _searchController.text = barcode;
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.searchMedications(barcode);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<Pharmacy> results = data.map((json) => Pharmacy.fromJson(json)).toList();

        if (_userPosition != null) {
          results.sort((a, b) {
            double distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.lat, a.lng);
            double distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.lat, b.lng);
            return distA.compareTo(distB);
          });
        }

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.barcodeNotFound),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // HEADER
          _buildHeader(),

          // BODY
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: emerald500))
                : _hasSearched
                    ? _buildResultsList()
                    : _buildInitialView(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DEEP HEADER & SEARCH BAR
  // ==========================================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, widget.showBackButton ? 50 : 60, 20, 30),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button & Title
          if (widget.showBackButton)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                    SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.back, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
          
          Text(
            AppLocalizations.of(context)!.searchMedicine,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Search Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: "Ex: Doliprane 1000mg...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barcode Scanner Icon
                    IconButton(
                      icon: const Icon(LucideIcons.scan, color: emerald600),
                      onPressed: () async {
                        final barcode = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicationBarcodeScanner(),
                          ),
                        );
                        if (barcode != null && mounted) {
                          _handleBarcodeSearch(barcode);
                        }
                      },
                      tooltip: AppLocalizations.of(context)!.scanBarcode,
                    ),
                    // Clear Button (shown when text exists)
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(LucideIcons.xCircle, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasSearched = false;
                            _searchQuery = "";
                          });
                        },
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (val) {
                // Force rebuild to show/hide 'X' button
                setState(() {}); 
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INITIAL VIEW (Suggestions)
  // ==========================================
  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.popularSearches,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularMedications.map((med) => _buildChip(med)).toList(),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.pill, size: 64, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.searchMedicationAvailability,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade200),
      labelStyle: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () => _handleSearch(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // ==========================================
  // RESULTS LIST
  // ==========================================
  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.frown, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "${AppLocalizations.of(context)!.noResultsFor} \"$_searchQuery\"",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  "${_searchResults.length} ${AppLocalizations.of(context)!.pharmaciesFound}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
                const Spacer(),
                const Icon(LucideIcons.mapPin, size: 14, color: emerald600),
                const SizedBox(width: 4),
                Text(
                  _userPosition != null ? AppLocalizations.of(context)!.sortedByDistance : AppLocalizations.of(context)!.locationUnknown,
                  style: const TextStyle(fontSize: 12, color: emerald600),
                ),
              ],
            ),
          );
        }
        return _buildPharmacyCard(_searchResults[index - 1]);
      },
    );
  }

  Widget _buildPharmacyCard(Pharmacy p) {
    // Calculate Distance Display
    String distanceText = "-- km";
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
        MaterialPageRoute(builder: (context) => PharmacyDetailScreen(pharmacy: p))
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(p.address, style: TextStyle(color: Colors.grey[500], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                  child: Text(AppLocalizations.of(context)!.inStock, style: const TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(p.todayHours, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                  ],
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.navigation, size: 14, color: emerald500),
                    const SizedBox(width: 6),
                    Text(distanceText, style: const TextStyle(fontWeight: FontWeight.bold, color: emerald600)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}