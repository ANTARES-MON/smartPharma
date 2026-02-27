import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/colors.dart';
import '../../widgets/custom_input.dart';
import '../../services/api_service.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../client/home_screen.dart';
import 'terms_webview_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final bool startAsClient;

  const RegisterScreen({
    super.key, 
    this.startAsClient = true
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late bool isClient;
  bool showPassword = false;         
  bool showConfirmPassword = false;  
  bool acceptTerms = false;
  bool _isLoading = false;
  File? _licencePhoto;
  final ImagePicker _picker = ImagePicker();
  
  // Error messages for inline display
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _pharmacyNameError;
  String? _addressError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  // NEW BLUE DESIGN SYSTEM
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pharmacyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    isClient = widget.startAsClient;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pharmacyNameController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Clear previous errors
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _pharmacyNameError = null;
      _addressError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
    });
    
    if (!_formKey.currentState!.validate()) return;

    if (!acceptTerms) {
      setState(() {
        _termsError = "Veuillez accepter les conditions d'utilisation";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = AppLocalizations.of(context)!.passwordMismatch;
      });
      return;
    }

    if (!isClient && _licencePhoto == null) {
      _showSnackBar(AppLocalizations.of(context)!.uploadLicense, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> registrationData = {
        'nomComplet': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'motDePasse': _passwordController.text,
        'motDePasse_confirmation': _confirmPasswordController.text,
        'role': isClient ? 'client' : 'pharmacien',
      };

      if (!isClient) {
        registrationData['pharmacyName'] = _pharmacyNameController.text.trim();
        registrationData['pharmacyAddress'] = _addressController.text.trim();
      }

      final response = await _apiService.register(
        registrationData,
        photoLicencePath: !isClient ? _licencePhoto?.path : null,
      );

      if (!mounted) return;

      final data = response.data;
      final userData = data['user'];
      dynamic rawToken = data['token'];

      setState(() => _isLoading = false);

      if (!isClient) {
        // Show comprehensive dialog for pharmacist registration
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.clock,
                          size: 40,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        'Compte en cours de vérification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Message
                      Text(
                        'Votre demande d\'inscription a été soumise avec succès.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.mail, size: 20, color: primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Un email de confirmation a été envoyé à ${_emailController.text.trim()}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(LucideIcons.checkCircle, size: 20, color: primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Vous recevrez une notification par email dès que votre licence sera approuvée (24-48h)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // OK Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Return to login screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Compris',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return;
      }

      String tokenString = (rawToken is Map) ? rawToken['token'].toString() : rawToken.toString();

      await ref.read(authProvider.notifier).saveUserSession(userData, tokenString);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }

    } on DioException catch (e) {
      setState(() => _isLoading = false);
      
      // Parse validation errors from backend
      if (e.response?.statusCode == 422 && e.response?.data is Map) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          setState(() {
            if (errors['nomComplet'] != null) {
              _nameError = (errors['nomComplet'] is List) 
                ? errors['nomComplet'][0] 
                : errors['nomComplet'].toString();
            }
            if (errors['email'] != null) {
              _emailError = (errors['email'] is List) 
                ? errors['email'][0] 
                : errors['email'].toString();
            }
            if (errors['telephone'] != null) {
              _phoneError = (errors['telephone'] is List) 
                ? errors['telephone'][0] 
                : errors['telephone'].toString();
            }
            if (errors['pharmacyName'] != null) {
              _pharmacyNameError = (errors['pharmacyName'] is List) 
                ? errors['pharmacyName'][0] 
                : errors['pharmacyName'].toString();
            }
            if (errors['pharmacyAddress'] != null) {
              _addressError = (errors['pharmacyAddress'] is List) 
                ? errors['pharmacyAddress'][0] 
                : errors['pharmacyAddress'].toString();
            }
            if (errors['motDePasse'] != null) {
              _passwordError = (errors['motDePasse'] is List) 
                ? errors['motDePasse'].join('\n') 
                : errors['motDePasse'].toString();
            }
            if (errors['motDePasse_confirmation'] != null) {
              _confirmPasswordError = (errors['motDePasse_confirmation'] is List) 
                ? errors['motDePasse_confirmation'][0] 
                : errors['motDePasse_confirmation'].toString();
            }
          });
        } else {
          String errorMessage = e.response?.data['message'] ?? "Erreur lors de l'inscription";
          _showSnackBar(errorMessage, Colors.redAccent);
        }
      } else {
        String errorMessage = e.response?.data is Map ? e.response?.data['message'] : "Erreur lors de l'inscription";
        _showSnackBar(errorMessage, Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erreur lors de l'inscription", Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC UI COLORS
    final Color activeColor = isClient ? AppColors.emerald600 : primaryBlue;
    final List<Color> headerGradient = isClient 
        ? [AppColors.emerald500, AppColors.teal500] 
        : [primaryBlue, darkBlue];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
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
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                      ),
                      child: Icon(LucideIcons.pill, color: activeColor, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.createAccount, 
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                    ),
                    Text(
                      AppLocalizations.of(context)!.joinSmartPharmaToday, 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildToggle(AppLocalizations.of(context)!.client, isClient, () => setState(() => isClient = true)),
                        const SizedBox(width: 12),
                        _buildToggle(AppLocalizations.of(context)!.pharmacist, !isClient, () => setState(() => isClient = false)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    CustomInput(
                      controller: _nameController, 
                      label: AppLocalizations.of(context)!.fullName, 
                      hint: AppLocalizations.of(context)!.yourNameAndSurname, 
                      icon: LucideIcons.user,
                      validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.nameRequired : null,
                      focusedBorderColor: activeColor,
                      errorText: _nameError,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: _emailController, 
                      label: AppLocalizations.of(context)!.email, 
                      hint: "exemple@email.com", 
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains("@") ? AppLocalizations.of(context)!.invalidEmail : null,
                      focusedBorderColor: activeColor,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: _phoneController, 
                      label: AppLocalizations.of(context)!.phone, 
                      hint: "+212 6XX XXX XXX", 
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.phoneRequired : null,
                      focusedBorderColor: activeColor,
                      errorText: _phoneError,
                    ),
                    const SizedBox(height: 16),

                    if (!isClient) ...[
                      CustomInput(
                        controller: _pharmacyNameController, 
                        label: AppLocalizations.of(context)!.pharmacyName, 
                        hint: "Pharmacie Centrale", 
                        icon: LucideIcons.store,
                        validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.pharmacyNameRequired : null,
                        focusedBorderColor: activeColor,
                        errorText: _pharmacyNameError,
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: _addressController, 
                        label: AppLocalizations.of(context)!.address, 
                        hint: "Adresse complète de l'officine", 
                        icon: LucideIcons.mapPin,
                         validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.addressRequired : null,
                        focusedBorderColor: activeColor,
                        errorText: _addressError,
                      ),
                      const SizedBox(height: 16),
                      
                      // UPLOAD SECTION WITH NEW BLUE
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.fileBadge, size: 20, color: activeColor),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.licensePhoto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_licencePhoto != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.checkCircle, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_licencePhoto!.path.split('/').last, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => setState(() => _licencePhoto = null)),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) setState(() => _licencePhoto = File(pickedFile.path));
                                  },
                                  icon: const Icon(LucideIcons.upload, size: 18),
                                  label: Text(AppLocalizations.of(context)!.uploadPhoto),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: activeColor), 
                                    foregroundColor: activeColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomInput(
                      controller: _passwordController,
                      label: AppLocalizations.of(context)!.password, 
                      hint: "••••••••", 
                      icon: LucideIcons.lock,
                      isPassword: true, 
                      showPassword: showPassword,
                      onTogglePassword: () => setState(() => showPassword = !showPassword),
                      validator: (v) => v!.length < 8 ? "Minimum 8 caractères" : null,
                      focusedBorderColor: activeColor,
                      errorText: _passwordError,
                    ),
                    const SizedBox(height: 16),

                    CustomInput(
                      controller: _confirmPasswordController, 
                      label: AppLocalizations.of(context)!.confirmPassword, 
                      hint: "••••••••", 
                      icon: LucideIcons.lock, 
                      isPassword: true,
                      showPassword: showConfirmPassword, 
                      onTogglePassword: () => setState(() => showConfirmPassword = !showConfirmPassword),
                      validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.confirmationRequired : null,
                      focusedBorderColor: activeColor,
                      errorText: _confirmPasswordError,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 24, width: 24,
                          child: Checkbox(
                            value: acceptTerms,
                            activeColor: activeColor, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: (val) => setState(() {
                              acceptTerms = val ?? false;
                              if (acceptTerms) _termsError = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                              children: [
                                TextSpan(text: AppLocalizations.of(context)!.iAcceptThe),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.termsAndConditions,
                                  style: TextStyle(
                                    color: activeColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: activeColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const TermsWebViewScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _termsError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(AppLocalizations.of(context)!.signUp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                          children: [
                            TextSpan(text: AppLocalizations.of(context)!.alreadyHaveAccount),
                            TextSpan(
                              text: AppLocalizations.of(context)!.signIn, 
                              style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool active, VoidCallback onTap) {
    // DYNAMIC TOGGLE COLOR
    final Color activeBg = isClient ? AppColors.emerald600 : primaryBlue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? activeBg : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF6B7280), 
                fontWeight: FontWeight.bold, 
                fontSize: 15
              ),
            ),
          ),
        ),
      ),
    );
  }
}