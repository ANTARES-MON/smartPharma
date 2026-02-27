import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/api_service.dart';
import '../../providers/app_provider.dart';
import 'map_picker_screen.dart';
import '../../l10n/app_localizations.dart';

class PharmacyInfoScreen extends ConsumerStatefulWidget {
  const PharmacyInfoScreen({super.key});

  @override
  ConsumerState<PharmacyInfoScreen> createState() => _PharmacyInfoScreenState();
}

class _PharmacyInfoScreenState extends ConsumerState<PharmacyInfoScreen> {
  late ApiService _apiService;

  late TextEditingController _pharmacistNameController;
  late TextEditingController _pharmacyNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  
  double _latitude = 33.5731;
  double _longitude = -7.5898;

  final Map<String, String> _schedule = {
    'Lundi': 'Fermé', 'Mardi': 'Fermé', 'Mercredi': 'Fermé',
    'Jeudi': 'Fermé', 'Vendredi': 'Fermé', 'Samedi': 'Fermé', 'Dimanche': 'Fermé',
  };

  bool _isLoading = false;

  // PHARMACIST DESIGN SYSTEM
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  @override
  void initState() {
    super.initState();
    _pharmacistNameController = TextEditingController();
    _pharmacyNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = ref.read(apiServiceProvider);
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(authProvider);
    if (user == null || user.pharmacyId == null) return;

    _pharmacistNameController.text = user.name;
    
    setState(() {
      _pharmacyNameController.text = user.pharmacy?['nom']?.toString() ?? ""; 
      _addressController.text = user.pharmacy?['adresse']?.toString() ?? "";
      _phoneController.text = user.pharmacy?['telephone']?.toString() ?? "";
      _latitude = double.tryParse(user.pharmacy?['latitude']?.toString() ?? "33.5731") ?? 33.5731;
      _longitude = double.tryParse(user.pharmacy?['longitude']?.toString() ?? "-7.5898") ?? -7.5898;
    });

    try {
      final response = await _apiService.getPharmacySchedules(user.pharmacyId.toString());
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          for (var item in data) {
            String day = item['jourSemaine'];
            String? open = item['heureOuverture'];
            String? close = item['heureFermeture'];

            if (open != null && close != null) {
              String formatOpen = open.length >= 5 ? open.substring(0, 5) : open;
              String formatClose = close.length >= 5 ? close.substring(0, 5) : close;
              _schedule[day] = "$formatOpen - $formatClose";
            } else {
              _schedule[day] = "Fermé";
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching schedules: $e");
    }
  }

  @override
  void dispose() {
    _pharmacistNameController.dispose();
    _pharmacyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseTimeRange(String day, String rawString) {
    Map<String, dynamic> result = {
      'jourSemaine': day,
      'heureOuverture': null,
      'heureFermeture': null,
      'deGarde': false,
    };

    if (rawString.toLowerCase().contains("fermé") || rawString.trim().isEmpty) {
      return result;
    }

    if (rawString.contains("-")) {
      List<String> parts = rawString.split("-");
      if (parts.length == 2) {
        result['heureOuverture'] = parts[0].trim();
        result['heureFermeture'] = parts[1].trim();
      }
    }
    return result;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authProvider);
      if (user?.pharmacyId == null) throw Exception('Pharmacy ID not found');

      // 1. Update basic profile info
      await _apiService.updatePharmacistProfile({
        'nomComplet': _pharmacistNameController.text.trim(),
        'telephone': _phoneController.text.trim(),
      });

      // 2. Update pharmacy details
      await _apiService.updatePharmacyDetails(user!.pharmacyId.toString(), {
        'nom': _pharmacyNameController.text.trim(),
        'adresse': _addressController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
      });

      // 3. Update schedules
      List<Map<String, dynamic>> schedulePayload = [];
      _schedule.forEach((day, value) {
        schedulePayload.add(_parseTimeRange(day, value));
      });
      await _apiService.updatePharmacySchedules(user.pharmacyId.toString(), schedulePayload);

      // 4. REFRESH LOCAL USER STATE (CRITICAL FIX)
      await ref.read(authProvider.notifier).checkLoginStatus();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String err = e is DioException ? (e.response?.data['message'] ?? e.message) : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $err"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialLat: _latitude, initialLng: _longitude),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.confirmPosition), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _openScheduleEditor() {
    Map<String, TextEditingController> tempControllers = {};
    _schedule.forEach((day, hours) {
      tempControllers[day] = TextEditingController(text: hours);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.openingHours, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _schedule.keys.map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      child: TextField(
                        controller: tempControllers[day],
                        decoration: InputDecoration(
                          hintText: "ex: 09:00 - 19:00",
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tempControllers.forEach((day, controller) {
                  _schedule[day] = controller.text;
                });
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: Text(AppLocalizations.of(context)!.validate, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ==========================================
          // STANDARDIZED HEADER
          // ==========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        AppLocalizations.of(context)!.pharmacyInfo,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(LucideIcons.save, color: Colors.white),
                        tooltip: "Enregistrer",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Gérez vos informations d'officine",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                )
              ],
            ),
          ),

          // ==========================================
          // BODY
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   _buildModernInput(AppLocalizations.of(context)!.pharmacistName, _pharmacistNameController, LucideIcons.user),
                   const SizedBox(height: 16),
                   _buildModernInput(AppLocalizations.of(context)!.pharmacyName, _pharmacyNameController, LucideIcons.store),
                   const SizedBox(height: 16),
                   _buildModernInput(AppLocalizations.of(context)!.pharmacyAddress, _addressController, LucideIcons.mapPin, maxLines: 2),
                   const SizedBox(height: 16),
                   
                   _buildMapCard(),
                   
                   const SizedBox(height: 16),
                   _buildModernInput(AppLocalizations.of(context)!.pharmacyPhone, _phoneController, LucideIcons.phone, keyboardType: TextInputType.phone),
                   const SizedBox(height: 24),

                   _buildScheduleCard(),
                   const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInput(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFFEFF6FF), 
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(LucideIcons.mapPin, color: primaryBlue.withValues(alpha: 0.5), size: 48),
                ),
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: const Text("Aperçu", style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Localisation",
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Text(
                      "Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _pickLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue.withValues(alpha: 0.1),
                    foregroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(LucideIcons.crosshair, size: 18),
                  label: Text(AppLocalizations.of(context)!.edit, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                    child: Icon(LucideIcons.clock, color: Colors.orange.shade600, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context)!.openingHours, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              IconButton(
                onPressed: _openScheduleEditor,
                icon: const Icon(LucideIcons.edit, color: primaryBlue, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          ..._schedule.entries.map((entry) {
            int todayIndex = DateTime.now().weekday - 1;
            List<String> days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
            bool isToday = (todayIndex >= 0 && todayIndex < days.length) ? days[todayIndex] == entry.key : false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? primaryBlue : Colors.grey.shade700)),
                  Text(entry.value, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? primaryBlue : Colors.black87, fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}