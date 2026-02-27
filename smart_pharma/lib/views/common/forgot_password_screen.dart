import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/colors.dart';

enum ForgotStep { email, code, password, success }

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  final bool isPharmacist;

  const ForgotPasswordScreen({
    super.key, 
    required this.onBack,
    this.isPharmacist = false,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ApiService _apiService = ApiService();
  
  ForgotStep _currentStep = ForgotStep.email;
  bool _isLoading = false;

  // NEW BLUE DESIGN SYSTEM
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Future<void> _handleSendCode() async {
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      _showError("Veuillez entrer une adresse email valide.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.sendPasswordResetCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _currentStep = ForgotStep.code);
    } catch (e) {
      _showError("Erreur: Email introuvable");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyCode() async {
    if (_codeController.text.length < 4) {
      _showError("Code invalide.");
      return;
    }
    setState(() => _currentStep = ForgotStep.password);
  }

  Future<void> _handleResetPassword() async {
    if (_newPassController.text.length < 6) {
      _showError("Minimum 6 caractères requis.");
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      _showError("Les mots de passe ne correspondent pas.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        password: _newPassController.text,
      );

      if (!mounted) return;
      setState(() => _currentStep = ForgotStep.success);
    } catch (e) {
      _showError("Erreur: Code expiré ou incorrect.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String get _title {
    switch (_currentStep) {
      case ForgotStep.email: return AppLocalizations.of(context)!.forgotPassword;
      case ForgotStep.code: return AppLocalizations.of(context)!.verificationStep;
      case ForgotStep.password: return AppLocalizations.of(context)!.newPasswordStep;
      case ForgotStep.success: return AppLocalizations.of(context)!.doneStep;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC COLORS
    final Color activeColor = widget.isPharmacist ? primaryBlue : AppColors.emerald600;
    final List<Color> headerGradient = widget.isPharmacist 
        ? [primaryBlue, darkBlue] 
        : [AppColors.emerald500, const Color(0xFF0D9488)];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                if (_currentStep != ForgotStep.success)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () {
                          if (_currentStep == ForgotStep.email) {
                            widget.onBack();
                          } else if (_currentStep == ForgotStep.code) {
                            setState(() => _currentStep = ForgotStep.email);
                          } else if (_currentStep == ForgotStep.password) {
                            setState(() => _currentStep = ForgotStep.code);
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  _title, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5
                  )
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(activeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(Color activeColor) {
    switch (_currentStep) {
      case ForgotStep.email: return _buildEmailStep(activeColor);
      case ForgotStep.code: return _buildCodeStep(activeColor);
      case ForgotStep.password: return _buildPasswordStep(activeColor);
      case ForgotStep.success: return _buildSuccessStep(activeColor);
    }
  }

  Widget _buildEmailStep(Color activeColor) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.enterEmailToReceive,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
        ),
        const SizedBox(height: 32),
        _buildInput(AppLocalizations.of(context)!.emailAddress, _emailController, LucideIcons.mail, activeColor, placeholder: "exemple@email.com"),
        const SizedBox(height: 32),
        _buildButton(AppLocalizations.of(context)!.sendCode, _handleSendCode, activeColor),
      ],
    );
  }

  Widget _buildCodeStep(Color activeColor) {
    return Column(
      children: [
        const Text(
          "Nous avons envoyé un code de vérification à votre adresse email.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _codeController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 32, letterSpacing: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "0000",
            hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 16),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), 
              borderSide: BorderSide(color: activeColor, width: 2)
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildButton("Vérifier le code", _handleVerifyCode, activeColor),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _handleSendCode,
          child: Text(
            "Renvoyer le code", 
            style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 15)
          ),
        )
      ],
    );
  }

  Widget _buildPasswordStep(Color activeColor) {
    return Column(
      children: [
        const Text(
          "Créez un nouveau mot de passe sécurisé pour votre compte.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
        ),
        const SizedBox(height: 32),
        _buildInput("Nouveau mot de passe", _newPassController, LucideIcons.lock, activeColor, isPassword: true),
        const SizedBox(height: 20),
        _buildInput("Confirmer le mot de passe", _confirmPassController, LucideIcons.lock, activeColor, isPassword: true),
        const SizedBox(height: 40),
        _buildButton("Changer le mot de passe", _handleResetPassword, activeColor),
      ],
    );
  }

  Widget _buildSuccessStep(Color activeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 64),
        ),
        const SizedBox(height: 32),
        const Text("Réussite !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          "Votre mot de passe a été réinitialisé avec succès.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
        ),
        const SizedBox(height: 48),
        _buildButton("Retour à la connexion", widget.onBack, activeColor),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, Color focusColor, {bool isPassword = false, String? placeholder}) {
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
          obscureText: isPassword,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
            hintText: placeholder ?? (isPassword ? "••••••••" : ""),
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

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
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
              text, 
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
      ),
    );
  }
}