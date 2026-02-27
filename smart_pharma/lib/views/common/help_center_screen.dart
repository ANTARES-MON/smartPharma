import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  final bool isPharmacist;

  const HelpCenterScreen({
    super.key, 
    this.isPharmacist = false
  });

  // 📧 CONFIGURATION
  final String supportEmail = "support@pharmaconnect.com";
  final String supportPhone = "+212600000000";

  // NEW BLUE DESIGN SYSTEM (Pharmacist)
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  Future<void> _sendEmail({String subject = "Demande d'aide", String body = ""}) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: supportPhone.replaceAll(' ', ''));
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC COLORS
    final Color activeColor = isPharmacist ? primaryBlue : AppColors.emerald600;
    final List<Color> headerGradient = isPharmacist 
        ? [primaryBlue, darkBlue] 
        : [AppColors.emerald500, const Color(0xFF0D9488)];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ==========================================
          // HEADER (DYNAMIC PHARMACIST/CLIENT)
          // ==========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CLEAN BACK BUTTON (Just the Arrow)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.helpCenterTitle, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  isPharmacist 
                    ? AppLocalizations.of(context)!.needHelpPharmacy
                    : AppLocalizations.of(context)!.howCanWeHelpYou, 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, height: 1.4)
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.contactUs, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))
                  ),
                  const SizedBox(height: 16),

                  // 1. Report Bug
                  _buildActionCard(
                    icon: LucideIcons.alertTriangle,
                    title: AppLocalizations.of(context)!.reportProblem,
                    subtitle: AppLocalizations.of(context)!.reportBugDescription,
                    color: Colors.orange,
                    onTap: () => _sendEmail(
                      subject: "Signalement [${isPharmacist ? 'Pharmacien' : 'Client'}]",
                      body: "Bonjour,\n\nJ'ai rencontré un problème technique..."
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Email Support
                  _buildActionCard(
                    icon: LucideIcons.mail,
                    title: AppLocalizations.of(context)!.sendEmail,
                    subtitle: AppLocalizations.of(context)!.emailSupportDescription,
                    color: activeColor, 
                    onTap: () => _sendEmail(
                      subject: "Demande d'assistance - SmartPharma",
                    ),
                  ),
                  const SizedBox(height: 12),

                   // 3. Phone Support
                  _buildActionCard(
                    icon: LucideIcons.phone,
                    title: AppLocalizations.of(context)!.callSupport,
                    subtitle: AppLocalizations.of(context)!.callSupportDescription,
                    color: isPharmacist ? darkBlue : Colors.blue.shade800, 
                    onTap: _makePhoneCall,
                  ),

                  
                  // 4. FAQ Section - HIDDEN FOR PHARMACISTS
                  if (!isPharmacist) ...[
                    const SizedBox(height: 32),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 32),

                    Text(
                      AppLocalizations.of(context)!.frequentQuestions, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))
                    ),
                    const SizedBox(height: 16),

                    _buildFaqTile(
                      AppLocalizations.of(context)!.howToCancelOrder, 
                      AppLocalizations.of(context)!.howToCancelOrderAnswer,
                      activeColor
                    ),
                    _buildFaqTile(
                      AppLocalizations.of(context)!.manageMyInfo, 
                      AppLocalizations.of(context)!.manageMyInfoAnswer,
                      activeColor
                    ),
                    _buildFaqTile(
                      AppLocalizations.of(context)!.accountSecurity, 
                      AppLocalizations.of(context)!.accountSecurityAnswer,
                      activeColor
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  // REMOVED "SmartPharma" TEXT
                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: activeColor,
          collapsedIconColor: Colors.grey.shade400,
          children: [
            Text(answer, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
          ],
        ),
      ),
    );
  }
}