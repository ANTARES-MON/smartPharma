import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pharmacy.dart';
import '../../models/medication.dart';
import '../../providers/pharmacy_provider.dart';
import './reservation_screen.dart';
import '../../l10n/app_localizations.dart';

class PharmacyDetailScreen extends ConsumerStatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyDetailScreen({super.key, required this.pharmacy});

  @override
  ConsumerState<PharmacyDetailScreen> createState() =>
      _PharmacyDetailScreenState();
}

class _PharmacyDetailScreenState extends ConsumerState<PharmacyDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Colors
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 Filter Logic
  List<Medication> _filterMedications(List<Medication> allMeds) {
    if (_searchQuery.trim().isEmpty) return allMeds;
    return allMeds
        .where(
          (med) => med.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // 📅 Date Helper
  String _getCurrentDay() {
    final localizations = AppLocalizations.of(context)!;
    List<String> days = [
      localizations.monday,
      localizations.tuesday,
      localizations.wednesday,
      localizations.thursday,
      localizations.friday,
      localizations.saturday,
      localizations.sunday,
    ];
    int todayIndex = DateTime.now().weekday - 1;
    return days[todayIndex];
  }

  // 📞 Phone Call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 🗺️ Maps
  Future<void> _launchMaps() async {
    final Uri googleMapsUrl = Uri.parse(
      "geo:${widget.pharmacy.lat},${widget.pharmacy.lng}?q=${widget.pharmacy.lat},${widget.pharmacy.lng}(${widget.pharmacy.name})",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      final Uri webUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.pharmacy.lat},${widget.pharmacy.lng}",
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir la carte")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.pharmacy.calculatedStatus;
    final stockAsync = ref.watch(pharmacyStockProvider(widget.pharmacy.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // HEADER
          _buildHeader(status),

          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 1. Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoSection(
                          LucideIcons.mapPin,
                          AppLocalizations.of(context)!.address,
                          widget.pharmacy.address,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildExpandableHours(widget.pharmacy.schedule),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _infoSection(
                          LucideIcons.phone,
                          AppLocalizations.of(context)!.phone,
                          widget.pharmacy.phone,
                          isPhone: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: AppLocalizations.of(context)!.call,
                          icon: LucideIcons.phone,
                          color: emerald600,
                          onTap: () => _makePhoneCall(widget.pharmacy.phone),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          label: AppLocalizations.of(context)!.directions,
                          icon: LucideIcons.navigation,
                          color: const Color(0xFF2563EB),
                          onTap: _launchMaps,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Stock Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.pill, color: emerald500, size: 22),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.medicationsAvailable,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searching,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.search,
                                color: Colors.grey,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List
                        stockAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: emerald500,
                              ),
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Erreur de chargement",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          data: (medicationsList) {
                            final filtered = _filterMedications(
                              medicationsList,
                            );
                            if (filtered.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    "Aucun médicament trouvé",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: filtered
                                  .map((med) => _medicationItem(med))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================
  Widget _buildHeader(String status) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.white70, size: 18),
                  SizedBox(width: 4),
                  Text(
                     AppLocalizations.of(context)!.back,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.pharmacy.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildStatusBadge(status),
        ],
      ),
    );
  }

  // ==========================================
  // STATUS BADGE
  // ==========================================
  Widget _buildStatusBadge(String status) {
    Color bg, text, iconColor;
    String label;
    IconData iconData;

    switch (status) {
      case 'open':
        bg = Colors.white;
        text = const Color(0xFF16A34A);
        iconColor = const Color(0xFF16A34A);
        label = AppLocalizations.of(context)!.openNow;
        iconData = LucideIcons.checkCircle;
        break;
      case 'closing-soon':
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFF854D0E);
        iconColor = const Color(0xFFCA8A04);
        label = "FERME BIENTÔT";
        iconData = LucideIcons.alertCircle;
        break;
      case 'on-call':
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFC2410C);
        iconColor = const Color(0xFFEA580C);
        label = "PHARMACIE DE GARDE";
        iconData = LucideIcons.shieldAlert;
        break;
      default: // closed
        bg = const Color(0xFFFEF2F2);
        text = const Color(0xFFB91C1C);
        iconColor = const Color(0xFFDC2626);
        label = AppLocalizations.of(context)!.closedCaps;
        iconData = LucideIcons.xCircle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS
  // ==========================================
  Widget _buildExpandableHours(Map<String, String> schedule) {
    String currentDay = _getCurrentDay();
    List<String> orderedDays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            LucideIcons.clock,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronDown,
          color: Colors.grey,
          size: 20,
        ),
        title: Text(
          AppLocalizations.of(context)!.openingHours,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        subtitle: Text(
          "${AppLocalizations.of(context)!.today}: ${schedule[currentDay] ?? 'Fermé'}",
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: orderedDays.map((day) {
          bool isToday = day == currentDay;
          String hours = schedule[day] ?? AppLocalizations.of(context)!.closed;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday ? emerald600 : Colors.black54,
                  ),
                ),
                Text(
                  hours,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: isToday ? emerald600 : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _infoSection(
    IconData icon,
    String label,
    String value, {
    Widget? extra,
    bool isPhone = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPhone ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isPhone ? emerald600 : Colors.grey.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isPhone ? emerald600 : const Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (extra != null) extra,
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _medicationItem(Medication med) {
    bool isOutOfStock = med.stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.pill,
                    color: emerald600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Using WRAP to fix the Overflow (Red/Yellow/Black screen)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8, // Gap between Price and Tag
                        runSpacing: 4, // Gap if tag drops to next line
                        children: [
                          Text(
                            "${med.price.toStringAsFixed(2)} DH",
                            style: const TextStyle(
                              color: emerald600,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (med.necessiteOrdonnance)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ), // Tighter padding
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.orange.shade100,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.fileText,
                                    size: 10,
                                    color: Colors.orange.shade800,
                                  ), // Tiny Icon
                                  const SizedBox(width: 3),
                                  Text(
                                    "Ordonnance", // Shortened Text
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Reservation Button
          ElevatedButton(
            onPressed: isOutOfStock
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationScreen(
                          pharmacy: widget.pharmacy,
                          medication: med.name,
                          stockId: med.id,
                          price: med.price,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: emerald600,
              disabledBackgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              isOutOfStock ? AppLocalizations.of(context)!.outOfStock : AppLocalizations.of(context)!.reserve,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOutOfStock ? Colors.grey.shade400 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
