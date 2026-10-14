import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../menu/data/menu_api.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  
  String? _selectedImageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _restaurantNameController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploadingImage = true);
      final bytes = result.files.single.bytes!;
      final filename = result.files.single.name;
      final imageUrl = await MenuApi().uploadImage(bytes, filename);
      setState(() => _isUploadingImage = false);
      if (imageUrl != null) {
        setState(() => _selectedImageUrl = imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploadée avec succès!'), backgroundColor: Colors.green));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du téléchargement de l\'image'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _onSignupPressed() async {
    final email = _emailController.text.trim();
    final success = await ref.read(authProvider.notifier).signUp(
      _nameController.text,
      email,
      _passwordController.text,
      _phoneController.text,
      restaurantName: _restaurantNameController.text,
      restaurantImageUrl: _selectedImageUrl,
    );
    
    if (success && ref.read(authProvider).otpSent) {
      if (mounted) context.push('/otp', extra: email);
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error ?? 'Erreur inconnue';
        final cleanError = error.startsWith('Exception: ') ? error.substring(11) : error;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cleanError), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Color(0xFFFDF7E3), shape: BoxShape.circle))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: DjerbaTheme.textPrimary), onPressed: () => context.pop())),
                  const SizedBox(height: 10),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Nouveau Restaurant",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Inscrivez votre établissement sur Djerba Delivery.", style: TextStyle(fontSize: 16, color: DjerbaTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(controller: _nameController, hintText: "Votre Nom complet", prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _emailController, hintText: "Adresse e-mail", prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _phoneController, hintText: "Numéro de téléphone", prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _passwordController, hintText: "Mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _restaurantNameController, hintText: "Nom du Restaurant", prefixIcon: Icons.restaurant_outlined),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _isUploadingImage ? null : _uploadImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _isUploadingImage 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.image_outlined, color: _selectedImageUrl != null ? DjerbaTheme.success : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImageUrl != null ? "Image sélectionnée" : "Logo du restaurant (Optionnel)",
                              style: TextStyle(color: _selectedImageUrl != null ? DjerbaTheme.success : DjerbaTheme.textSecondary),
                            ),
                          ),
                          if (_selectedImageUrl != null)
                            const Icon(Icons.check_circle, color: DjerbaTheme.success, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(text: authState.isLoading ? "Patientez..." : "S'inscrire", onPressed: authState.isLoading ? () {} : _onSignupPressed),
                  const SizedBox(height: 32),
                  Wrap(alignment: WrapAlignment.center, children: [const Text("Déjà un compte ? ", style: TextStyle(color: DjerbaTheme.textSecondary, fontWeight: FontWeight.w500)), GestureDetector(onTap: () => context.pop(), child: const Text("Se connecter", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
