import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';

class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapPickerScreen({
    super.key, 
    this.initialLat = 33.5731,
    this.initialLng = -7.5898,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  late CameraPosition _initialPosition;

  // NEW BLUE DESIGN SYSTEM
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    _initialPosition = CameraPosition(
      target: _selectedLocation,
      zoom: 14.0,
    );
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _confirm() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the map to flow behind the rounded header
      extendBodyBehindAppBar: true, 
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 10), // Adjust for status bar
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryBlue, darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppLocalizations.of(context)!.chooseLocation,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // REMOVED CHECK BUTTON
              actions: [], 
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onTap: _onTap,
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: _selectedLocation,
                infoWindow: InfoWindow(title: AppLocalizations.of(context)!.yourPharmacy),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Hidden to avoid conflict with UI
            zoomControlsEnabled: false,
            // Add padding so map controls/logo don't get hidden behind header/button
            padding: const EdgeInsets.only(top: 100, bottom: 100),
          ),
          
          // ENHANCED BOTTOM BUTTON
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0, // Handled by Container for better glow
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.confirmPosition, 
                      style: GoogleFonts.poppins(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}