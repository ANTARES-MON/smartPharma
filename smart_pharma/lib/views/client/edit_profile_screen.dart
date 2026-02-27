import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_provider.dart';
import '../../core/colors.dart';
import '../../l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const EditProfileScreen({super.key, required this.onBack});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);

    _nameController = TextEditingController(text: user?.name ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _phoneController = TextEditingController(text: user?.phone ?? "");
    _cityController = TextEditingController(text: user?.city ?? "");
    _addressController = TextEditingController(text: user?.address ?? "");
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'ville': _cityController.text,
      };
      
      if (_addressController.text.trim().isNotEmpty) {
        data['address'] = _addressController.text;
        data['adresse'] = _addressController.text;
      }

      await ref.read(authProvider.notifier).updateProfile(data, null);

      if (mounted) {
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isPharmacist = user?.isPharmacist ?? false;

    final Color primaryColor = isPharmacist ? Colors.blue.shade700 : AppColors.emerald600;
    final Color secondaryColor = isPharmacist ? Colors.blue.shade800 : const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Standardized Deep Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 48),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                      onPressed: widget.onBack,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.editProfile, 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField(AppLocalizations.of(context)!.fullName, _nameController, primaryColor),
                  const SizedBox(height: 20),
                  _buildField("Email", _emailController, primaryColor, inputType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildField(AppLocalizations.of(context)!.phone, _phoneController, primaryColor, inputType: TextInputType.phone),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(child: _buildField(AppLocalizations.of(context)!.city, _cityController, primaryColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField(AppLocalizations.of(context)!.address, _addressController, primaryColor)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Standardized Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildField(String label, TextEditingController controller, Color focusColor, {TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: focusColor, width: 2)
            ),
          ),
        ),
      ],
    );
  }
}