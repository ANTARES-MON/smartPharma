import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../models/medication.dart';
import '../../models/reservation.dart';
import '../../services/api_service.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/pharmacist_notification_provider.dart';

import 'pharmacist_reservations_screen.dart';
import 'pharmacist_notifications_screen.dart';
import 'pharmacist_profile_screen.dart';
import 'scanner_screen.dart';
import '../../l10n/app_localizations.dart';

class PharmacistDashboard extends ConsumerStatefulWidget {
  const PharmacistDashboard({super.key});

  @override
  ConsumerState<PharmacistDashboard> createState() =>
      _PharmacistDashboardState();
}

class _PharmacistDashboardState extends ConsumerState<PharmacistDashboard> {
  late ApiService _apiService;

  String _searchQuery = "";
  final List<String> _selectedCategories = [];

  final TextEditingController _searchController = TextEditingController();

  // Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600

  @override
  void initState() {
    super.initState();
    // Initialize API service from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = ref.read(apiServiceProvider);
    });
  }

  final List<String> _allCategories = [
    "Antidouleur",
    "Antibiotique",
    "Respiratoire",
    "Cardiovasculaire",
    "Digestif",
    "Complément alimentaire",
    "Dermatologie",
  ];

  void _navigateToScanner() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (scannedCode == null || !mounted) return;

    // Clean the scanned code - remove RES- prefix if present
    String cleanCode = scannedCode.toString().replaceAll('RES-', '').trim();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call the backend scan endpoint
      final response = await _apiService.scanReservation(cleanCode);

      // Dismiss loading
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data['data'];

        // Convert to Reservation model
        final reservation = Reservation.fromJson(resData);
        _showReservationDialog(reservation);
      } else {
        // Show error
        if (mounted) {
          _showStockSearchDialog(scannedCode);
        }
      }
    } catch (e) {
      // Dismiss loading
      if (mounted) Navigator.pop(context);

      // Show appropriate error message
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(LucideIcons.alertCircle, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.reservationNotFound,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Text(
              e.toString().contains('404')
                  ? AppLocalizations.of(context)!.reservationNotAccepted
                  : "Erreur: $e",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showReservationDialog(Reservation res) {
    try {
      // Get current app locale
      final currentLocale = Localizations.localeOf(context).toString();
      
      // Initialize date formatting for current locale
      initializeDateFormatting(currentLocale, null);

      final String formattedDate = DateFormat(
        "dd MMM yyyy 'à' HH:mm",
        currentLocale,
      ).format(res.createdAt);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.checkCircle,
                    color: Colors.green.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.reservationFound,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.qrCode,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "ID: ${res.qrCode.isNotEmpty ? res.qrCode : res.id}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildDialogRow(LucideIcons.user, AppLocalizations.of(context)!.patient, res.patientName),
                const SizedBox(height: 12),
                _buildDialogRow(
                  LucideIcons.pill,
                  AppLocalizations.of(context)!.medication,
                  res.medicationName,
                ),
                const SizedBox(height: 12),
                _buildDialogRow(
                  LucideIcons.hash,
                  AppLocalizations.of(context)!.quantity,
                  "${res.quantity} ${AppLocalizations.of(context)!.boxUnit}",
                ),
                const SizedBox(height: 12),
                _buildDialogRow(LucideIcons.calendar, AppLocalizations.of(context)!.date, formattedDate),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (res.status == 'pending') {
                      _validateReservationAction(res);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showStockSearchDialog("RES-${res.qrCode}");
    }
  }

  void _validateReservationAction(Reservation res) {}

  void _showStockSearchDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.search, color: Colors.blue),
            const SizedBox(width: 10),
            const Text("Recherche Stock"),
          ],
        ),
        content: Text(
          "Le code $code ne correspond à aucune réservation.\n\nRecherche effectuée dans le stock.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMedicationDialog({Medication? medication}) {
    final isEditing = medication != null;
    final nameController = TextEditingController(
      text: isEditing ? medication.name : "",
    );
    final stockController = TextEditingController(
      text: isEditing ? medication.stock.toString() : "",
    );
    final priceController = TextEditingController(
      text: isEditing ? medication.price.toString() : "",
    );
    final barcodeController = TextEditingController(
      text: isEditing ? (medication.barcode ?? "") : "",
    );

    String selectedCategory =
        (isEditing && _allCategories.contains(medication.category))
        ? medication.category
        : _allCategories.first;

    bool requiresPrescription = isEditing
        ? medication.requiresPrescription
        : false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isEditing ? AppLocalizations.of(context)!.modify : AppLocalizations.of(context)!.newMedication,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.medicationNamePlaceholder,
                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.stock,
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: GoogleFonts.poppins(),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.pricePlaceholder,
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedCategory,
                      items: _allCategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: GoogleFonts.poppins()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedCategory = val);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.category,
                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)!.prescriptionRequired,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: requiresPrescription,
                        activeThumbColor: primaryBlue,
                        onChanged: (val) => setStateDialog(() => requiresPrescription = val),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Barcode Field (Optional)
                    TextField(
                      controller: barcodeController,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        labelText: "${AppLocalizations.of(context)!.barcode} (${AppLocalizations.of(context)!.barcodeOptional})",
                        labelStyle: GoogleFonts.poppins(color: Colors.grey),
                        hintText: "Ex: 3400936041059",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ... (Your existing save logic here, keeping it concise for the UI fix) ...
                  if (nameController.text.trim().isEmpty ||
                      stockController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty) {
                    return;
                  }

                  final user = ref.read(authProvider);
                  final pharmacyId = user?.pharmacyId;
                  if (pharmacyId == null) return;

                  Navigator.pop(ctx);

                  final Map<String, dynamic> bodyData = {
                    'name': nameController.text.trim(),
                    'category': selectedCategory,
                    'requiresPrescription': requiresPrescription,
                    'stock': int.tryParse(stockController.text.trim()) ?? 0,
                    'price':
                        double.tryParse(priceController.text.trim()) ?? 0.0,
                    'barcode': barcodeController.text.trim().isEmpty ? null : barcodeController.text.trim(),
                    'is_available': true,
                  };

                  try {
                    if (isEditing) {
                      await _apiService.updateMedication(
                        medication.id,
                        bodyData,
                      );
                    } else {
                      await _apiService.addMedication(
                        pharmacyId.toString(),
                        bodyData,
                      );
                    }
                    ref.invalidate(pharmacyStockProvider);
                  } catch (e) {
                    // Error handling
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue, // CHANGED TO PRIMARY BLUE
                  foregroundColor: Colors.white,
                  elevation: 0, // REMOVED ELEVATION (No "Cadre"/Shadow)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToNotifications() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PharmacistNotificationsScreen()),
  );
  void _navigateToReservationsPage() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PharmacistReservationsScreen()),
  );
  void _navigateToProfile() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PharmacistProfileScreen()),
  );

  void _deleteMedication(String medId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Supprimer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer ce médicament ?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Non", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Oui, Supprimer",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _apiService.deleteMedication(medId);
      ref.invalidate(pharmacyStockProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Supprimé avec succès"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.filterByCategory,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: primaryBlue.withValues(alpha: 0.1),
                        backgroundColor: Colors.grey.shade50,
                        checkmarkColor: primaryBlue,
                        side: BorderSide(
                          color: isSelected
                              ? primaryBlue
                              : Colors.grey.shade200,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? primaryBlue : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (bool selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.applyFilter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationProvider);
    final int pendingCount = reservationState.reservations
        .where((r) => r.status == "pending")
        .length;

    final int unreadNotifs = ref.watch(pharmacistUnreadCountProvider);
    final user = ref.watch(authProvider);
    final pharmacyId = user?.pharmacyId;

    if (pharmacyId == null) {
      return const Scaffold(
        body: Center(child: Text("Erreur: Pas de pharmacie associée.")),
      );
    }

    final stockAsync = ref.watch(pharmacyStockProvider(pharmacyId.toString()));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: stockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur: $err")),
        data: (allMedications) {
          final int lowStockCount = allMedications
              .where((m) => m.stock < 10)
              .length;

          return Column(
            children: [
              // 1. Stack for Header & Overlapping Stats
              // Fixed height area for Header + Stats
              // This structure ensures NO "old shadow" behind
              SizedBox(
                height: 280,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // A. The Deep Rounded Header
                    _buildHeader(pendingCount, unreadNotifs),

                    // B. The Floating Stats Card
                    Positioned(
                      bottom: 10,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              LucideIcons.package,
                              allMedications.length.toString(),
                              AppLocalizations.of(context)!.total,
                              primaryBlue,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            _buildStatItem(
                              LucideIcons.bell,
                              pendingCount.toString(),
                              AppLocalizations.of(context)!.reservationsCount,
                              Colors.orange,
                              onTap: _navigateToReservationsPage,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            _buildStatItem(
                              LucideIcons.alertTriangle,
                              lowStockCount.toString(),
                              AppLocalizations.of(context)!.lowStock,
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Inventory List & Search (Takes remaining space)
              Expanded(child: _buildInventoryContent(allMedications)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMedicationDialog(),
        backgroundColor: primaryBlue,
        elevation: 4,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.add,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==========================================
  // ROUNDED HEADER
  // ==========================================
  Widget _buildHeader(int pendingCount, int unreadNotifs) {
    final user = ref.watch(authProvider);
    return Container(
      height: 220, // Taller to allow overlap
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue,
            Color(0xFF1E40AF),
          ], // primaryBlue to Darker Blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.dashboard,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.pharmacy?['nom'] ?? "Ma Pharmacie",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderIconBtn(
                LucideIcons.bell,
                unreadNotifs,
                Colors.red,
                _navigateToNotifications,
              ),
              const SizedBox(width: 12),
              _buildHeaderIconBtn(
                LucideIcons.user,
                0,
                Colors.transparent,
                _navigateToProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STATS ITEM
  // ==========================================
  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INVENTORY CONTENT (Search + List)
  // ==========================================
  Widget _buildInventoryContent(List<Medication> medications) {
    // Filter Logic
    final filtered = medications.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.any(
            (cat) => cat.toLowerCase() == m.category.trim().toLowerCase(),
          );
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        // 1. Sleek Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Container(
            height: 48, // Reduced height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController, // Using the existing controller
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchMedicationCaps,
                // FIXED: Smaller hint text size
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _navigateToScanner,
                      icon: const Icon(
                        LucideIcons.qrCode,
                        color: primaryBlue,
                        size: 20,
                      ),
                      tooltip: "Scanner",
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    IconButton(
                      onPressed: _showFilterModal,
                      icon: Icon(
                        LucideIcons.slidersHorizontal,
                        color: _selectedCategories.isNotEmpty
                            ? primaryBlue
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      tooltip: "Filtrer",
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Active Filters
        if (_selectedCategories.isNotEmpty)
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _selectedCategories
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        backgroundColor: primaryBlue.withValues(alpha: 0.05),
                        deleteIcon: const Icon(
                          LucideIcons.x,
                          size: 12,
                          color: primaryBlue,
                        ),
                        onDeleted: () =>
                            setState(() => _selectedCategories.remove(c)),
                        labelStyle: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        // 3. List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMedicationFound,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildMedicationCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // CLEAN MEDICATION CARD
  // ==========================================
  Widget _buildMedicationCard(Medication med) {
    final isLowStock = med.stock < 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLowStock ? Colors.red.shade100 : Colors.transparent,
        ),
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
                    Text(
                      med.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${med.price} DH",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stock Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (med.stock / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowStock ? Colors.red : Colors.green,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildTag(
                isLowStock ? "Critique: ${med.stock}" : "Stock: ${med.stock}",
                isLowStock ? Colors.red : Colors.grey,
                isLowStock ? LucideIcons.alertTriangle : LucideIcons.box,
              ),
              if (med.requiresPrescription) ...[
                const SizedBox(width: 8),
                _buildTag("Ordonnance", Colors.purple, LucideIcons.fileText),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => _showMedicationDialog(medication: med),
                icon: const Icon(
                  LucideIcons.edit2,
                  size: 18,
                  color: Colors.grey,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => _deleteMedication(med.id),
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: Colors.red,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Header Icon Helper
  Widget _buildHeaderIconBtn(
    IconData icon,
    int badgeCount,
    Color badgeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
