import 'package:flutter/material.dart';
import '../../utils/location_permission.dart';
import '../auth/auth_choice_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isGranting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _grantPermission() async {
    setState(() => _isGranting = true);

    final granted = await LocationPermissionUtil.requestPermission();

    if (!mounted) return;

    if (granted) {
      await LocationPermissionUtil.getCurrentPosition();
    }

    if (!mounted) return;
    _navigateToAuthChoice();
  }

  void _navigateToAuthChoice() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthChoiceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -8 * _animationController.value,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006E2F).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 56,
                        color: Color(0xFF006E2F),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              const Text(
                "Location Access",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121C2A),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "We need your location to show nearby stores, calculate delivery fees, and provide accurate delivery estimates.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isGranting ? null : _grantPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006E2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isGranting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Grant Permission",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: _navigateToAuthChoice,
                child: const Text(
                  "Skip for now",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
