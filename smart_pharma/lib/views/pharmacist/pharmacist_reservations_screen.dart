import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';
import '../../l10n/app_localizations.dart';

class PharmacistReservationsScreen extends ConsumerStatefulWidget {
  const PharmacistReservationsScreen({super.key});

  @override
  ConsumerState<PharmacistReservationsScreen> createState() => _PharmacistReservationsScreenState();
}

class _PharmacistReservationsScreenState extends ConsumerState<PharmacistReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Design System Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationProvider.notifier).loadReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ... (Logic for _handleStatusUpdate and _formatTime remains the same, just keeping it clean)
  Future<void> _handleStatusUpdate(String id, String newStatus) async {
    if (id.isEmpty) return;

    try {
      final success = await ref.read(reservationProvider.notifier).updateStatus(id, newStatus);
      
      if (!success) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la mise à jour"), backgroundColor: Colors.red));
        return;
      }
      
      await ref.read(reservationProvider.notifier).loadReservations();
      

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    }
  }

  String _formatTime(DateTime date) {
    final localizations = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "${localizations.agoTime} ${diff.inMinutes} ${localizations.minUnit}";
    if (diff.inHours < 24) return "${localizations.agoTime} ${diff.inHours}${localizations.hourUnit}";
    return "${date.day}/${date.month} à ${date.hour}h${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationProvider);
    final allReservations = reservationState.reservations;
    final pendingCount = allReservations.where((r) => r.status.toLowerCase() == 'pending' || r.status.toLowerCase() == 'en_attente').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // 1. DEEP HEADER WITH TABS INTEGRATED
          _buildHeader(pendingCount),

          // 2. TAB VIEW CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReservationList(allReservations, showPending: true),
                _buildReservationList(allReservations, showPending: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CUSTOM HEADER W/ TABS
  // ==========================================
  Widget _buildHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Title Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  AppLocalizations.of(context)!.reservations,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 40), // Balance spacing
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Custom Tab Bar inside Header
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.pending),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                        child: Text("$pendingCount", style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ]
                  ],
                ),
              ),
              Tab(text: AppLocalizations.of(context)!.history),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ==========================================
  // LIST CONTENT
  // ==========================================
  Widget _buildReservationList(List<Reservation> reservations, {required bool showPending}) {
    final filtered = reservations.where((r) {
      final statusLower = r.status.toLowerCase();
      final isPendingStatus = (statusLower == "pending" || statusLower == "en_attente");
      final matchesStatus = showPending ? isPendingStatus : !isPendingStatus;
      
      final medName = r.medicationName;
      final patName = r.patientName;
      final matchesSearch = medName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            patName.toLowerCase().contains(_searchQuery.toLowerCase());
                            
      return matchesStatus && matchesSearch;
    }).toList();

    // Sort: Newest First
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        // Sleek Search Bar (Floating below header)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPatientOrMedication,
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.calendarX, size: 50, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      showPending ? AppLocalizations.of(context)!.noPendingRequests : "Aucun historique",
                      style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildReservationCard(filtered[index]),
              ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD UI
  // ==========================================
  Widget _buildReservationCard(Reservation res) {
    final statusLower = res.status.toLowerCase(); 
    final isPending = statusLower == "pending" || statusLower == "en_attente";
    
    final displayName = res.patientName.isNotEmpty ? res.patientName : "Client Inconnu";
    final displayInitials = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (statusLower) {
      case 'accepted':
      case 'acceptee': 
        statusColor = Colors.green;
        statusText = AppLocalizations.of(context)!.confirmed;
        statusIcon = LucideIcons.checkCircle;
        break;
      case 'rejected':
      case 'refusee':
      case 'cancelled':
        statusColor = Colors.red;
        statusText = AppLocalizations.of(context)!.refused;
        statusIcon = LucideIcons.xCircle;
        break;
      default:
        statusColor = Colors.orange;
        statusText = AppLocalizations.of(context)!.pending;
        statusIcon = LucideIcons.clock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Use primaryBlue for pending border to highlight attention, else transparent
        border: Border.all(
          color: isPending ? primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
          width: 1
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar + Name + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Center(child: Text(displayInitials, style: GoogleFonts.poppins(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      if (res.patientPhone.isNotEmpty)
                        Text(res.patientPhone, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          
          // Medication Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.pill, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.medication, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w500)),
                    Text(res.medicationName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMiniTag(LucideIcons.box, "${AppLocalizations.of(context)!.qtyLabel} ${res.quantity}"),
                        const SizedBox(width: 8),
                        _buildMiniTag(LucideIcons.clock, _formatTime(res.createdAt)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Action Buttons (Only if Pending)
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleStatusUpdate(res.id, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade100),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.x, size: 16),
                    label: Text(AppLocalizations.of(context)!.refuse, style: const TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleStatusUpdate(res.id, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Green for success
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }
}