import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../../models/pharmacy.dart';
import '../../providers/pharmacy_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/location_provider.dart'; 
import './notifications_screen.dart';
import './favorites_screen.dart';
import './profile_screen.dart';
import './medication_search_screen.dart';
import './pharmacy_detail_screen.dart';
import './order_history_screen.dart';
import './pharmacy_list_screen.dart';
import '../common/login_screen.dart';
import '../../providers/client_notification_provider.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showMap = false;
  int _currentIndex = 0;
  final TextEditingController _pharmacySearchController = TextEditingController();
  String _pharmacySearchQuery = '';

  final Completer<GoogleMapController> _mapController = Completer();

  // Casablanca default
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.5731, -7.5898),
    zoom: 13.0,
  );

  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  @override
  void dispose() {
    _pharmacySearchController.dispose();
    super.dispose();
  }

  BitmapDescriptor? _greenMarker;
  BitmapDescriptor? _orangeMarker;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null && user.isClient) {
        ref.read(reservationProvider.notifier).loadReservations();
        ref.read(clientNotificationProvider.notifier).fetchNotifications();
      }
    });
  }

  // Helper function to resize marker icons properly
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final data = await DefaultAssetBundle.of(context).load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(), 
      targetWidth: width,
    );
    final frameInfo = await codec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> _loadCustomMarkers() async {
    final greenBytes = await getBytesFromAsset(
      'assets/images/GREEN-PIN.png', 
      120,
    );
    final orangeBytes = await getBytesFromAsset(
      'assets/images/ORANGE-PIN.png', 
      120,
    );
    
    _greenMarker = BitmapDescriptor.fromBytes(greenBytes);
    _orangeMarker = BitmapDescriptor.fromBytes(orangeBytes);
    setState(() {});
  }

  Future<void> _onRefresh() async {
    ref.invalidate(userLocationProvider);
    ref.read(clientNotificationProvider.notifier).fetchNotifications();
    return ref.refresh(pharmacyListProvider.future);
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng"
    );
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch maps");
    }
  }

  Future<void> _moveCameraToPosition(Position pos) async {
    if (showMap) {
      try {
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(pos.latitude, pos.longitude),
            15.0,
          ),
        );
      } catch (e) {
        // Handle map controller error
      }
    }
  }

  Set<Marker> _buildMarkers(List<Pharmacy> pharmacies) {
    // If markers haven't loaded yet, return empty set
    if (_greenMarker == null || _orangeMarker == null) {
      return {};
    }

    return pharmacies.map((p) {
      BitmapDescriptor markerIcon = p.isOnCall ? _orangeMarker! : _greenMarker!;

      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.lat, p.lng),
        icon: markerIcon,
        anchor: const Offset(0.5, 1.0), // Pin tip points to exact coordinate
        infoWindow: InfoWindow(
          title: p.name,
          snippet: p.todayHours,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PharmacyDetailScreen(pharmacy: p),
            ),
          ),
        ),
      );
    }).toSet();
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyAsync = ref.watch(pharmacyListProvider);
    final user = ref.watch(authProvider);
    
    // WATCH THE UNREAD COUNT (This updates the Red Dot)
    final int unreadCount = ref.watch(clientUnreadCountProvider);
    
    final userLocation = ref.watch(userLocationProvider);

    ref.listen(userLocationProvider, (previous, next) {
      if (next != null) {
        _moveCameraToPosition(next);
      }
    });

    final List<Widget> pages = [
      _buildHomeContent(user?.name, pharmacyAsync, unreadCount, userLocation),
      const MedicationSearchScreen(showBackButton: false),
      const FavoritesScreen(showBackButton: false),
      ProfileScreen(
        showBackButton: false,
        onBack: () {},
        onLogout: _handleLogout,
      ),
    ];

    // Wrap in GestureDetector to close keyboard when clicking outside
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: pages[_currentIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHomeContent(
    String? userName,
    AsyncValue<List<Pharmacy>> pharmacyAsync,
    int unreadCount,
    Position? userLocation,
  ) {
    return Column(
      children: [
        // Pass unread count to header
        _buildHeader(userName ?? "Invité", unreadCount),
        
        Container(
          color: const Color(0xFFF9FAFB),
          child: Column(
            children: [
              _buildQuickActions(), 
              _buildViewToggle()
            ]
          ),
        ),

        Expanded(
          child: pharmacyAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: emerald500),
            ),
            error: (err, stack) => Center(child: Text("Erreur: $err")),
            data: (pharmacies) {
              final q = _pharmacySearchQuery.trim().toLowerCase();
              final filtered = q.isEmpty
                  ? pharmacies
                  : pharmacies.where((p) =>
                        p.name.toLowerCase().contains(q) ||
                        (p.address.toLowerCase().contains(q))).toList();
              if (showMap) {
                return _buildMapView(filtered, userLocation);
              } else {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: emerald500,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // REMOVED THE ORANGE ON-CALL BANNER
                        _buildSectionHeader(),
                        _buildListView(filtered, userLocation),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(List<Pharmacy> pharmacies, Position? userLocation) {
    CameraPosition targetPosition = _initialPosition;
    
    if (userLocation != null) {
      targetPosition = CameraPosition(
        target: LatLng(userLocation.latitude, userLocation.longitude),
        zoom: 15.0,
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: targetPosition,
          markers: _buildMarkers(pharmacies),
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<Pharmacy> pharmacies, Position? userLocation) {
    if (userLocation != null) {
      pharmacies.sort((a, b) {
        double distA = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          a.lat,
          a.lng,
        );
        double distB = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    }

    final favorites = ref.watch(favoritesProvider);

    if (pharmacies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(AppLocalizations.of(context)!.noPharmacyFound),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final p = pharmacies[index];
        
        final String realDistance = p.getRealDistance(
          userLocation?.latitude,
          userLocation?.longitude,
        );

        final isFavorite = favorites.contains(p.id);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PharmacyDetailScreen(pharmacy: p),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          p.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${AppLocalizations.of(context)!.today}: ${p.todayHours}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _statusBadge(p),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(p.id);
                        },
                        child: Icon(
                          LucideIcons.heart,
                          color: isFavorite
                              ? const Color(0xFFEC4899)
                              : Colors.grey[300],
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 80,
                        ),
                        child: Text(
                          realDistance, 
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: emerald500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => _launchMaps(p.lat, p.lng),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.navigation,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String userName, int unreadCount) {
    return Container(
      // Increased padding for visual balance
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [emerald500, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // ROUNDED HEADER BOTTOM (Deep Curve)
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // MOVED NOTIFICATION ICON HERE & REMOVED PROFILE ICON
              _circleIconButton(
                LucideIcons.bell,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ),
                badge: unreadCount > 0 ? (unreadCount > 9 ? '9+' : unreadCount.toString()) : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // SEARCH BAR: ROUNDED PILL SHAPE
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Pill Shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _pharmacySearchController,
              onChanged: (val) => setState(() => _pharmacySearchQuery = val),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPharmacy,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(LucideIcons.search, color: Colors.grey[400], size: 20),
                ),
                filled: true,
                fillColor: Colors.transparent, // Color is in container
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionItem(
            AppLocalizations.of(context)!.home,
            LucideIcons.mapPin,
            emerald500,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PharmacyListScreen(),
              ),
            ),
          ),
          _actionItem(
            AppLocalizations.of(context)!.medications,
            LucideIcons.pill,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MedicationSearchScreen(showBackButton: true),
              ),
            ),
          ),
          _actionItem(
            AppLocalizations.of(context)!.myFavorites,
            LucideIcons.heart,
            Colors.pink,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const FavoritesScreen(showBackButton: true),
              ),
            ),
          ),
          _actionItem(
            AppLocalizations.of(context)!.history,
            LucideIcons.history,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ENHANCED TOGGLE SWITCH
  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Softer background
          borderRadius: BorderRadius.circular(30), // Fully rounded
        ),
        child: Row(
          children: [
            Expanded(
              child: _toggleBtn(
                AppLocalizations.of(context)!.list,
                !showMap,
                () => setState(() => showMap = false),
              ),
            ),
            Expanded(
              child: _toggleBtn(
                AppLocalizations.of(context)!.map,
                showMap,
                () => setState(() => showMap = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: active 
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? emerald600 : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.nearby,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PharmacyListScreen(),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.seeAll,
              style: const TextStyle(color: emerald600, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16), // Rounded
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(Pharmacy p) {
    String status = p.calculatedStatus;
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
      label = AppLocalizations.of(context)!.open;
    } else {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
      label = AppLocalizations.of(context)!.closedCaps;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {String? badge}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10), // Bigger tap area
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9, 
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ENHANCED BOTTOM NAVIGATION BAR
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: emerald600,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(LucideIcons.home),
            ),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(LucideIcons.search),
            ),
            label: AppLocalizations.of(context)!.search,
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(LucideIcons.heart),
            ),
            label: AppLocalizations.of(context)!.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(LucideIcons.user),
            ),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}