import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _obscureText = true;

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
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'email est requis"), backgroundColor: Colors.red),
      );
      return;
    }
    
    final success = await ref.read(authProvider.notifier).signUp(
      _nameController.text.trim(),
      email,
      _passwordController.text,
      _phoneController.text.trim()
    );
    
    if (success) {
      context.push('/otp', extra: email);
    } else {
      final error = ref.read(authProvider).error ?? 'Erreur';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.7, // Crops out the bottom text
                    child: Image.asset('assets/images/djerba_logo.png', height: 160),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Bienvenue !",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Créez votre compte pour commencer",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Inputs
              _buildTextField(
                controller: _nameController,
                hintText: "Nom complet",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                hintText: "Téléphone",
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hintText: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              
              const SizedBox(height: 8),
              
              // Password requirements
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRequirement("8 caractères min"),
                  const SizedBox(width: 8),
                  _buildRequirement("1 majuscule"),
                  const SizedBox(width: 8),
                  _buildRequirement("1 chiffre"),
                ],
              ),
              
              const SizedBox(height: 32),

              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authProvider);
                  return ElevatedButton(
                    onPressed: authState.isLoading ? () {} : _onSignupPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DjerbaTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(authState.isLoading ? "Chargement..." : "S'inscrire", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("ou continuer avec", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Social Logins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('assets/images/google.png', Icons.g_mobiledata, Colors.red, 'Google'),
                  const SizedBox(width: 16),
                  _buildSocialButton('assets/images/apple.png', Icons.apple, Colors.black, 'Apple'),
                  const SizedBox(width: 16),
                  _buildSocialButton('assets/images/facebook.png', Icons.facebook, Colors.blue, 'Facebook'),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: Text("Se connecter", style: TextStyle(color: DjerbaTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 4, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _onSocialLogin(String provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connexion avec $provider..."), duration: const Duration(seconds: 1)),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.go('/client_dashboard');
  }

  Widget _buildSocialButton(String asset, IconData icon, Color color, String providerName) {
    return GestureDetector(
      onTap: () => _onSocialLogin(providerName),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }

}
