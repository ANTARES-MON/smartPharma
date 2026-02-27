import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../providers/app_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import './edit_profile_screen.dart';
import '../common/change_password_screen.dart';
import '../common/help_center_screen.dart';
import '../common/privacy_policy_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    required this.onBack,
    required this.onLogout,
    this.showBackButton = true,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _autoUpdateCity();
  }

  Future<void> _autoUpdateCity() async {
    try {
      final user = ref.read(authProvider);
      if (user == null) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final currentCity = place.locality ?? place.subAdministrativeArea ?? "Inconnu";

        if (currentCity.toLowerCase() != (user.city ?? "").toLowerCase()) {
          Map<String, String> data = {
            'name': user.name,
            'email': user.email,
            'phone': user.phone ?? '',
            'city': currentCity,
            'ville': currentCity,
            'address': user.address ?? '',
            'adresse': user.address ?? '',
          };
          await ref.read(authProvider.notifier).updateProfile(data, null);
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isPharmacist = user?.isPharmacist ?? false;

    final Color primaryColor = isPharmacist ? Colors.blue.shade700 : const Color(0xFF059669);
    final Color secondaryColor = isPharmacist ? Colors.blue.shade800 : const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Standardized Deep Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Column(
                children: [
                  // Header Navigation Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button (Left)
                        if (widget.showBackButton)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                            onPressed: widget.onBack,
                          )
                        else
                          const SizedBox(width: 40), // Spacer to balance layout if no back button

                        // Logout Button (Right - "The Great Symbol")
                        IconButton(
                          onPressed: widget.onLogout,
                          icon: const Icon(LucideIcons.logOut, color: Colors.white, size: 24),
                          tooltip: "Se déconnecter",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 0),
                  
                  // Profile Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: const Icon(LucideIcons.user, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Info
                  Text(
                    user?.name ?? "Utilisateur",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Section
                  _buildSectionTitle(AppLocalizations.of(context)!.personalInformation),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(AppLocalizations.of(context)!.phone, user?.phone ?? "Non renseigné"),
                        const Divider(height: 32),
                        _buildInfoRow(AppLocalizations.of(context)!.city, user?.city ?? "Localisation..."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Menu Section
                  _buildSectionTitle(AppLocalizations.of(context)!.settings),
                  _buildMenuItem(LucideIcons.settings, AppLocalizations.of(context)!.editProfile, primaryColor, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(onBack: () => Navigator.pop(context))));
                  }),
                  _buildMenuItem(LucideIcons.lock, AppLocalizations.of(context)!.security, primaryColor, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen(onBack: () => Navigator.pop(context))));
                  }),
                  _buildMenuItem(
                    LucideIcons.languages,
                    AppLocalizations.of(context)!.language,
                    primaryColor,
                    onTap: () => _showLanguagePicker(context, ref),
                  ),


                  const SizedBox(height: 24),

                  _buildSectionTitle(AppLocalizations.of(context)!.support),
                  _buildMenuItem(LucideIcons.helpCircle, AppLocalizations.of(context)!.helpCenter, primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()))),
                  _buildMenuItem(LucideIcons.shield, AppLocalizations.of(context)!.privacy, primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()))),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
        Text(value, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color iconColor, {VoidCallback? onTap, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // Fixed height padding to ensure all items are exactly the same size
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              ),
              // If trailing is null, show arrow, otherwise show the widget (Switch)
              trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(context, ref, 'English', 'en', currentLocale.languageCode == 'en'),
              _buildLanguageOption(context, ref, 'Français', 'fr', currentLocale.languageCode == 'fr'),
              _buildLanguageOption(context, ref, 'العربية', 'ar', currentLocale.languageCode == 'ar'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String language, String code, bool isSelected) {
    return ListTile(
      title: Text(language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF10B981)) : null,
      onTap: () async {
        await ref.read(localeProvider.notifier).setLocale(code);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}