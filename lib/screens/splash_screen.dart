import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    final prefs =
    await SharedPreferences.getInstance();

    final seen =
        prefs.getBool('onboarding_seen') ?? false;
    final token = prefs.getString('auth_token');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (token != null && token.isNotEmpty) {
            return const HomeScreen();
          }

          return seen
              ? const LoginScreen()
              : const OnboardingScreen();
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.1,
              ).animate(_controller),
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF006E2F),
                  borderRadius:
                  BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "My SpiceMarket",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006E2F),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Fresh ingredients delivered",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
