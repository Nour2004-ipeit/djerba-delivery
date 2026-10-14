import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';

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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignupPressed() async {
    final email = _emailController.text.trim();
    final success = await ref.read(authProvider.notifier).signUp(
      _nameController.text,
      email,
      _passwordController.text,
      _phoneController.text,
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

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
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
                    "Nouvel Administrateur",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: DjerbaTheme.textPrimary, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Créez votre compte pour gérer la plateforme.",
                    style: TextStyle(fontSize: 16, color: DjerbaTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(controller: _nameController, hintText: "Nom complet", prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _emailController, hintText: "Adresse e-mail", prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _phoneController, hintText: "Numéro de téléphone", prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _passwordController, hintText: "Mot de passe", prefixIcon: Icons.lock_outline, isPassword: true),
                  
                  const SizedBox(height: 32),
                  PrimaryButton(text: authState.isLoading ? "Patientez..." : "S'inscrire", onPressed: authState.isLoading ? () {} : _onSignupPressed),
                  const SizedBox(height: 32),
                  
                  const Center(child: Text("ou s'inscrire avec", style: TextStyle(color: DjerbaTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildSocialButton(LineIcons.googleLogo, Colors.red), const SizedBox(width: 24), _buildSocialButton(LineIcons.apple, Colors.black), const SizedBox(width: 24), _buildSocialButton(LineIcons.facebookF, Colors.blue)]),
                  const SizedBox(height: 40),
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
