import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/otp_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/primary_button.dart';
import 'auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  bool _isComplete = false;
  String _otpCode = "";
  int _secondsLeft = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsLeft = 59);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    if (_secondsLeft > 0) return;
    final success = await ref.read(authProvider.notifier).sendEmailOTP(widget.email);
    if (success && mounted) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nouveau code envoyé !'), backgroundColor: Colors.green));
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Erreur lors de l\'envoi';
      final cleanError = error.startsWith('Exception: ') ? error.substring(11) : error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cleanError), backgroundColor: Colors.red));
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete) return;
    final success = await ref.read(authProvider.notifier).verifyOTP(widget.email, _otpCode);
    if (success) {
      if (mounted) context.go('/client_dashboard');
    } else {
      final error = ref.read(authProvider).error ?? 'Invalid code';
      final cleanError = error.startsWith('Exception: ') ? error.substring(11) : error;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cleanError), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: DjerbaTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, size: 16, color: DjerbaTheme.primaryColor),
                    ),
                  ),
                  Container(width: 32, height: 2, color: DjerbaTheme.primaryColor),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: DjerbaTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                  Container(width: 32, height: 2, color: Colors.grey[200]),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("3", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DjerbaTheme.primaryLight, Color(0xFFB3E8F3)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.mobile_friendly, color: DjerbaTheme.primaryColor, size: 32),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "Code de vérification",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Code envoyé à l'adresse\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: DjerbaTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 32),
              // OTP Inputs
              OtpInput(
                length: 4,
                onCompleted: (value) {
                  setState(() {
                    _otpCode = value;
                    _isComplete = true;
                  });
                  // Trigger verification automatically!
                  _verifyOtp();
                },
              ),
              const SizedBox(height: 24),
              // Timer
              if (_secondsLeft > 0)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: DjerbaTheme.textTertiary),
                        const SizedBox(width: 8),
                        const Text("Expire dans ", style: TextStyle(fontSize: 14, color: DjerbaTheme.textSecondary)),
                        Text(
                          "00:${_secondsLeft.toString().padLeft(2, '0')}", 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: DjerbaTheme.primaryColor)
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: Text("Le code a expiré", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authProvider);
                  return PrimaryButton(
                    text: authState.isLoading ? "Vérification..." : "Vérifier",
                    onPressed: _isComplete && !authState.isLoading ? _verifyOtp : () {}, 
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous n'avez pas reçu le code? ", style: TextStyle(color: DjerbaTheme.textTertiary)),
                  GestureDetector(
                    onTap: _secondsLeft == 0 ? _resendCode : null,
                    child: Text(
                      "Renvoyer", 
                      style: TextStyle(
                        color: _secondsLeft == 0 ? DjerbaTheme.primaryColor : Colors.grey,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
