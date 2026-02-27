import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/colors.dart';
import '../../widgets/custom_input.dart';
import '../../l10n/app_localizations.dart';
import './register_screen.dart';
import '../client/home_screen.dart';
import './forgot_password_screen.dart';
import '../pharmacist/pharmacist_dashboard_screen.dart';
import '../../providers/app_provider.dart';

const String _googleServerClientId = '677030976188-u9slbv6niuhebthe39fck3k13slnbtl3.apps.googleusercontent.com';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isClient = true; 
  bool showPassword = false;
  bool rememberMe = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  
  // Error messages for inline display
  String? _emailError;
  String? _passwordError;
  String? _loginError;

  // New Blue Design System
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _googleServerClientId,
    scopes: ['email', 'profile'],
  );

  static const _keyRememberMe = 'login_remember_me';
  static const _keySavedEmail = 'login_saved_email';
  static const _keySavedPassword = 'login_saved_password';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRemember = prefs.getBool(_keyRememberMe) ?? false;
      final savedEmail = prefs.getString(_keySavedEmail);
      final savedPassword = prefs.getString(_keySavedPassword);
      if (mounted) {
        setState(() {
          rememberMe = savedRemember;
          if (savedEmail != null) _emailController.text = savedEmail;
          if (savedPassword != null) _passwordController.text = savedPassword;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setString(_keySavedEmail, email);
      await prefs.setString(_keySavedPassword, password);
    } catch (_) {}
  }

  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keySavedEmail);
      await prefs.remove(_keySavedPassword);
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _loginError = null;
    });
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = AppLocalizations.of(context)!.fillAllFields;
        if (password.isEmpty) _passwordError = AppLocalizations.of(context)!.fillAllFields;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bool success = await ref.read(authProvider.notifier).performLogin(email, password);

      if (!mounted) return;

      if (rememberMe && success) {
        await _saveCredentials(email, password);
      } else if (!rememberMe) {
        await _clearSavedCredentials();
      }
      
      if (!success) {
        setState(() {
          _isLoading = false;
          _loginError = AppLocalizations.of(context)!.incorrectCredentials;
        });
        return;
      }

      final user = ref.read(authProvider);
      final userRole = user?.role.toLowerCase() ?? '';

      try {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await ref.read(apiServiceProvider).updateDeviceToken(fcmToken); 
        }
      } catch (e) {
        debugPrint("Failed to update FCM token: $e");
      }

      final isPharmacistRole = userRole == 'pharmacist' || userRole == 'pharmacien';
      
      if (isClient && isPharmacistRole) {
        await _forceLogout("Utilisez l'interface pharmacien pour ce compte.");
        return;
      } else if (!isClient && !isPharmacistRole) {
        await _forceLogout("Utilisez l'interface client pour ce compte.");
        return;
      }
      
      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => isPharmacistRole ? const PharmacistDashboard() : const HomeScreen()
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loginError = "Erreur de connexion: ${e.toString()}";
      });
      debugPrint("Login error: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _forceLogout(String message) async {
    setState(() => _isLoading = false);
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (!isClient) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reservedForClients), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isGoogleLoading = true);

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ID token is null');
      }

      final bool success = await ref.read(authProvider.notifier).performGoogleLogin(idToken);

      if (!mounted) return;

      if (!success) {
        setState(() => _isGoogleLoading = false);
        _showError("Erreur de connexion Google");
        return;
      }

      try {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) await ref.read(apiServiceProvider).updateDeviceToken(fcmToken);
      } catch (e) {
        debugPrint("Failed to update FCM token: $e");
      }

      setState(() => _isGoogleLoading = false);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        debugPrint("Google Sign-In error: $e");
        _showError("Erreur Google: ${e.toString()}");
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    if (!isClient) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reservedForClients), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isFacebookLoading = true);

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        
        if (accessToken == null) {
          throw Exception('Access token is null');
        }

        final bool success = await ref.read(authProvider.notifier).performFacebookLogin(accessToken.token);

        if (!mounted) return;

        if (!success) {
          setState(() => _isFacebookLoading = false);
          _showError("Erreur de connexion Facebook");
          return;
        }

        try {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) await ref.read(apiServiceProvider).updateDeviceToken(fcmToken);
        } catch (e) {
          debugPrint("Failed to update FCM token: $e");
        }

        setState(() => _isFacebookLoading = false);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        if (mounted) setState(() => _isFacebookLoading = false);
      } else {
        throw Exception('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
        debugPrint("Facebook Sign-In error: $e");
        _showError("Erreur Facebook: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC COLORS BASED ON ROLE
    final Color activeColor = isClient ? AppColors.emerald600 : primaryBlue;
    final Color activeGradientStart = isClient ? AppColors.emerald500 : primaryBlue;
    final Color activeGradientEnd = isClient ? AppColors.teal500 : darkBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [activeGradientStart, activeGradientEnd],
                  begin: Alignment.topLeft, 
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48), 
                  bottomRight: Radius.circular(48)
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
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(22), 
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]
                    ),
                    child: Icon(LucideIcons.pill, color: activeColor, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.welcome, 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClient ? AppLocalizations.of(context)!.clientSpace : AppLocalizations.of(context)!.pharmacistSpace, 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500)
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
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.email, 
                    hint: "exemple@email.com", 
                    icon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    focusedBorderColor: activeColor,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    controller: _passwordController,
                    label: AppLocalizations.of(context)!.password, 
                    hint: "••••••••", 
                    icon: LucideIcons.lock,
                    isPassword: true, 
                    showPassword: showPassword,
                    onTogglePassword: () => setState(() => showPassword = !showPassword),
                    focusedBorderColor: activeColor,
                    errorText: _passwordError,
                  ),
                  if (_loginError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertCircle, color: Colors.red.shade700, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _loginError!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24, width: 24,
                            child: Checkbox(
                              value: rememberMe,
                              activeColor: activeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              onChanged: (val) => setState(() => rememberMe = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.rememberMe, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen(
                              onBack: () => Navigator.pop(context),
                              isPharmacist: !isClient,
                            ))
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.forgotPassword, 
                          style: TextStyle(color: activeColor, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!.signIn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),

                  if (isClient) ...[
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(AppLocalizations.of(context)!.or, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: _isGoogleLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.google.com/favicon.ico',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.googleSignIn,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Facebook Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isFacebookLoading ? null : _handleFacebookSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: _isFacebookLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.facebook, size: 24, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.facebookSignIn,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.noAccountYet, style: const TextStyle(color: Color(0xFF4B5563))),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(startAsClient: isClient)
                          )
                        ),
                        child: Text(AppLocalizations.of(context)!.register, 
                          style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool active, VoidCallback onTap) {
    // USES NEW BLUE FOR PHARMACIST BUTTON
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
                color: active ? Colors.white : const Color(0xFF4B5563), 
                fontWeight: FontWeight.bold,
                fontSize: 15
              )
            )
          ),
        ),
      ),
    );
  }
}