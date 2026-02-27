import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../providers/app_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pharmacy_provider.dart';
import '../common/login_screen.dart';
import 'pharmacy_info_screen.dart';
import '../common/help_center_screen.dart';
import '../common/privacy_policy_screen.dart';
import '../common/change_password_screen.dart';

final onCallProvider = StateProvider<bool>((ref) => false);

class PharmacistProfileScreen extends ConsumerStatefulWidget {
  const PharmacistProfileScreen({super.key});

  @override
  ConsumerState<PharmacistProfileScreen> createState() => _PharmacistProfileScreenState();
}

class _PharmacistProfileScreenState extends ConsumerState<PharmacistProfileScreen> {
  bool _initialOnCallLoaded = false;

  // PHARMACIST DESIGN SYSTEM COLORS
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  Future<void> _loadInitialOnCallStatus() async {
    if (_initialOnCallLoaded) return;
    final user = ref.read(authProvider);
    if (user?.pharmacyId == null) return;
    _initialOnCallLoaded = true;
    try {
      final res = await ref.read(apiServiceProvider).getPharmacySchedules(user!.pharmacyId.toString());
      if (res.statusCode == 200 &&
          res.data != null &&
          res.data['data'] is List &&
          (res.data['data'] as List).isNotEmpty) {
        final data = res.data['data'] as List;
        final anyDeGarde = data.any((h) =>
            h['deGarde'] == true || h['deGarde'] == 1 ||
            h['de_garde'] == true || h['de_garde'] == 1);
        if (mounted) ref.read(onCallProvider.notifier).state = anyDeGarde;
      }
    } catch (_) {}
  }

  Future<void> _toggleOnCall(bool value) async {
    ref.read(onCallProvider.notifier).state = value;
    try {
      final user = ref.read(authProvider);
      if (user?.pharmacyId != null) {
        await ref.read(apiServiceProvider).updateDeGardeStatus(
          user!.pharmacyId.toString(), 
          value
        );
        ref.invalidate(pharmacyListProvider);
      }
    } catch (e) {
      ref.read(onCallProvider.notifier).state = !value; 
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final name = user?.name ?? "Pharmacien";
    final email = user?.email ?? "email@pharmacie.com"; 

    final isOnCall = ref.watch(onCallProvider);

    if (user?.pharmacyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialOnCallStatus());
    }
    
    const licenseNumber = "PH-12345-MA"; 

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // STANDARDIZED DEEP GRADIENT HEADER
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
                  // Navigation Row
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
                          AppLocalizations.of(context)!.myProfile,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _handleLogout,
                          icon: const Icon(LucideIcons.logOut, color: Colors.white, size: 24),
                          tooltip: "Se déconnecter",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Profile Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(LucideIcons.stethoscope, color: Colors.white, size: 40),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Identity
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // License Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${AppLocalizations.of(context)!.license} $licenseNumber",
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // SETTINGS CONTENT
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(AppLocalizations.of(context)!.pharmacySettings),

                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.siren,
                    iconColor: isOnCall ? Colors.orange : Colors.grey,
                    title: AppLocalizations.of(context)!.onCallMode,
                    subtitle: isOnCall ? "${AppLocalizations.of(context)!.active} (Ouvert 24h/24)" : AppLocalizations.of(context)!.inactive,
                    onTap: () => _toggleOnCall(!isOnCall),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isOnCall,
                        activeThumbColor: Colors.orange,
                        onChanged: _toggleOnCall,
                      ),
                    ),
                  ),

                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.store,
                    title: AppLocalizations.of(context)!.pharmacyInformation,
                    subtitle: "${AppLocalizations.of(context)!.addressLabel}, ${AppLocalizations.of(context)!.hoursLabel}, ${AppLocalizations.of(context)!.locationLabel}",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PharmacyInfoScreen()),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(AppLocalizations.of(context)!.preferences),

                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.lock,
                    title: AppLocalizations.of(context)!.security,
                    subtitle: AppLocalizations.of(context)!.changePassword,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(
                          onBack: () => Navigator.pop(context),
                          isPharmacist: true,
                        ),
                      ),
                    ),
                  ),

                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.languages,
                    title: AppLocalizations.of(context)!.language,
                    subtitle: AppLocalizations.of(context)!.chooseLanguage,
                    onTap: () => _showLanguagePicker(context, ref),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(AppLocalizations.of(context)!.support),

                  // FIX HERE: Added isPharmacist: true
                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.helpCircle,
                    title: AppLocalizations.of(context)!.helpCenter,
                    subtitle: Localizations.localeOf(context).languageCode == 'ar' ? 'المساعدة والدعم' : AppLocalizations.of(context)!.faqAndSupport,
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const HelpCenterScreen(isPharmacist: true))
                    ),
                  ),

                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.shield,
                    title: AppLocalizations.of(context)!.privacy,
                    subtitle: Localizations.localeOf(context).languageCode == 'ar' ? 'الشروط والأحكام' : AppLocalizations.of(context)!.privacyPolicy,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),

                  const SizedBox(height: 30),
                  
                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    String? title,
    Widget? titleWidget,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? primaryBlue).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? primaryBlue, size: 22),
        ),
        title: titleWidget ?? Text(
          title ?? '',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: trailing ?? Icon(
          Directionality.of(context) == TextDirection.rtl 
            ? LucideIcons.chevronLeft 
            : LucideIcons.chevronRight, 
          size: 18, 
          color: Colors.black87
        ),
        onTap: onTap,
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
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
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
      title: Text(language, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
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