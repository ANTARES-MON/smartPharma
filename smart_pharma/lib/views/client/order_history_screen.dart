import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../models/pharmacy.dart';
import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/app_provider.dart';
import 'pharmacy_detail_screen.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _selectedFilter = 'all';

  // Colors
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color indigo600 = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationProvider.notifier).loadReservations();
    });
  }

  // 🔄 Refresh Action
  Future<void> _refreshList() async {
    await ref.read(reservationProvider.notifier).loadReservations();
  }

  // 🏥 Navigation helper
  void _navigateToPharmacy(Reservation order) {
    // Create a temporary pharmacy object to navigate
    final pharmacy = Pharmacy(
      id: order.pharmacyId,
      name: order.pharmacyName,
      address: order.pharmacyAddress,
      lat: 0.0,
      lng: 0.0,
      phone: order.pharmacyPhone,
      medications: [],
      isOnCall: false,
      schedule: {},
      distanceFallback: 'Distance inconnue',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PharmacyDetailScreen(pharmacy: pharmacy),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reservationState = ref.watch(reservationProvider);

    // 1. Filter by User
    final myOrders = reservationState.reservations.where((r) {
      if (user == null) return false;
      return r.userId.toString() == user.id.toString();
    }).toList();

    // 2. Filter by Status Tab
    List<Reservation> filteredList;
    if (_selectedFilter == 'all') {
      filteredList = myOrders;
    } else {
      filteredList = myOrders.where((r) {
        final status = r.status.toLowerCase();
        if (_selectedFilter == 'completed') {
          return ['completed', 'accepted', 'acceptee', 'pret'].contains(status);
        }
        if (_selectedFilter == 'pending') {
          return ['pending', 'en_attente'].contains(status);
        }
        if (_selectedFilter == 'cancelled') {
          return ['cancelled', 'rejected', 'refusee'].contains(status);
        }
        return false;
      }).toList();
    }

    // 3. Sort by Date (Newest first)
    filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // HEADER
          _buildHeader(context, myOrders.length),

          // FILTERS
          _buildFilterRow(),

          // LIST
          Expanded(
            child: reservationState.status == ReservationStatus.loading && filteredList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: purple500))
                : RefreshIndicator(
                    onRefresh: _refreshList,
                    color: purple500,
                    child: filteredList.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) => _orderCard(filteredList[index]),
                          )
                        : _buildEmptyState(),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DEEP ROUNDED HEADER
  // ==========================================
  Widget _buildHeader(BuildContext context, int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [purple500, indigo600],
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
              ),
              Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20), // Spacer
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.history, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  "$totalCount ${AppLocalizations.of(context)!.ordersSent}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // FILTER ROW
  // ==========================================
  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _filterChip(AppLocalizations.of(context)!.all, 'all'),
          const SizedBox(width: 10),
          _filterChip(AppLocalizations.of(context)!.pending, 'pending'),
          const SizedBox(width: 10),
          _filterChip(AppLocalizations.of(context)!.completed, 'completed'),
          const SizedBox(width: 10),
          _filterChip(AppLocalizations.of(context)!.cancelled, 'cancelled'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? purple600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: purple600.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ORDER CARD
  // ==========================================
  Widget _orderCard(Reservation order) {
    String formattedDate = DateFormat('d MMMM yyyy', 'fr_FR').format(order.createdAt);
    String formattedTime = DateFormat('HH:mm').format(order.createdAt);
    final statusLower = order.status.toLowerCase();

    // Determine Status Badge logic
    Color badgeBg; Color badgeText; String badgeLabel;
    
    if (['completed', 'accepted', 'acceptee', 'pret'].contains(statusLower)) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF15803D);
      badgeLabel = AppLocalizations.of(context)!.readyPickedUp;
    } else if (['pending', 'en_attente'].contains(statusLower)) {
      badgeBg = const Color(0xFFFFEDD5);
      badgeText = const Color(0xFFC2410C);
      badgeLabel = AppLocalizations.of(context)!.pendingCaps;
    } else {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFB91C1C);
      badgeLabel = AppLocalizations.of(context)!.cancelledCaps;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Name + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.medicationName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text("${AppLocalizations.of(context)!.qtyLabel} ${order.quantity}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                child: Text(badgeLabel, style: TextStyle(color: badgeText, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

          // 2. Pharmacy Info
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.pharmacyName,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF4B5563)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "$formattedDate à $formattedTime",
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Actions (Soft Clear Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (['pending', 'en_attente'].contains(statusLower))
                TextButton(
                  onPressed: () async {
                    final success = await ref
                        .read(reservationProvider.notifier)
                        .updateStatus(order.id, 'cancelled');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success ? AppLocalizations.of(context)!.orderCancelled : AppLocalizations.of(context)!.cancellationError),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ));
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: Text(AppLocalizations.of(context)!.cancelRequest),
                ),

              if (['completed', 'accepted', 'acceptee', 'pret'].contains(statusLower))
                ElevatedButton.icon(
                  onPressed: () => _navigateToPharmacy(order),
                  icon: const Icon(LucideIcons.repeat, size: 14),
                  label: Text(AppLocalizations.of(context)!.orderAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3E8FF),
                    foregroundColor: purple600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.history, size: 40, color: purple500),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noOrders,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 8),
          Text(
            "Vos réservations passées apparaîtront ici.",
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (_selectedFilter != 'all') 
             Padding(
               padding: const EdgeInsets.only(top: 16.0),
               child: TextButton(
                 onPressed: () => setState(() => _selectedFilter = 'all'),
                 child: Text(AppLocalizations.of(context)!.clearFilters, style: const TextStyle(color: purple600)),
               ),
             )
        ],
      ),
    );
  }
}