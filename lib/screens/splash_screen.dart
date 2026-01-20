import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

// Tambahkan definisi warna jika belum ada di main.dart atau file tema
const Color primaryColor = Color(0xFF6366F1);
const Color textSecondaryDark = Color(0xFF9CA3AF);
const Color bgSecondaryDark = Color(0xFF1F2937);
const Color borderColor = Color(0xFF374151);
const Color bgPrimaryDark = Color(0xFF111827);
const Color textPrimaryDark = Color(0xFFE5E7EB);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Timer navigasi
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimaryDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.storefront, size: 100, color: primaryColor);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}