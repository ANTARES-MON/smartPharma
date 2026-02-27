import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './forgot_password_screen.dart';
import '../../services/api_service.dart'; 
import '../../core/colors.dart';
import '../../l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  final bool isPharmacist; 

  const ChangePasswordScreen({
    super.key, 
    required this.onBack, 
    this.isPharmacist = false 
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  // NEW BLUE DESIGN SYSTEM
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  Future<void> _savePassword() async {
    if (_newController.text.isEmpty || _currentController.text.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.fillAllFields, Colors.orange);
      return;
    }

    if (_newController.text != _confirmController.text) {
      _showSnackBar(AppLocalizations.of(context)!.passwordMismatch, Colors.red);
      return;
    }

    if (_newController.text.length < 6) {
      _showSnackBar("Le mot de passe doit contenir au moins 6 caractères", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService(); 
      await api.changePassword(
        _currentController.text,
        _newController.text,
        _confirmController.text,
      );

      if (mounted) {
        _showSnackBar(AppLocalizations.of(context)!.passwordUpdated, const Color(0xFF10B981));
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Erreur: Mot de passe actuel incorrect", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC ROLE COLORS
    final Color activeColor = widget.isPharmacist ? primaryBlue : AppColors.emerald600;
    final List<Color> headerGradient = widget.isPharmacist 
        ? [primaryBlue, darkBlue] 
        : [AppColors.emerald500, const Color(0xFF0D9488)];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==========================================
          // STANDARDIZED HEADER
          // ==========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 48),
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
                  color: activeColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: widget.onBack,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.security, 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5
                  )
                ),
                Text(
                  AppLocalizations.of(context)!.changePassword,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _buildInput(
                    AppLocalizations.of(context)!.currentPassword, 
                    _currentController, 
                    _showCurrent, 
                    () => setState(() => _showCurrent = !_showCurrent), 
                    activeColor
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    AppLocalizations.of(context)!.newPassword, 
                    _newController, 
                    _showNew, 
                    () => setState(() => _showNew = !_showNew), 
                    activeColor
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    AppLocalizations.of(context)!.confirmPassword, 
                    _confirmController, 
                    _showConfirm, 
                    () => setState(() => _showConfirm = !_showConfirm), 
                    activeColor
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen(
                          onBack: () => Navigator.pop(context),
                          isPharmacist: widget.isPharmacist,
                        )));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgotPasswordQuestion, 
                        style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ENREGISTRER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(
                            AppLocalizations.of(context)!.saveChanges, 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
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

  Widget _buildInput(String label, TextEditingController controller, bool isVisible, VoidCallback onToggle, Color focusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label, 
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.bold)
          ),
        ),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.lock, size: 20, color: Colors.grey.shade400),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.grey.shade400, size: 20),
              onPressed: onToggle,
            ),
            hintText: "••••••••",
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), 
              borderSide: BorderSide(color: focusColor, width: 2)
            ),
          ),
        ),
      ],
    );
  }
}