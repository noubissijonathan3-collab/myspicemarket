import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../home/home_screen.dart';


// Icons.shopping_basket,

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    animationController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.login(email: email, password: password);
      if (!mounted) return;

      // Load all user-specific data in parallel
      await Future.wait([
        context.read<ProfileProvider>().loadProfile(),
        context.read<FavoriteProvider>().loadFavorites(),
        context.read<CartProvider>().loadCart(),
        context.read<OrderProvider>().loadOrders(),
        context.read<NotificationProvider>().loadNotifications(),
      ]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 +
                        (animationController.value * 40),
                    right: -80,
                    child: _blob(
                      const Color(0xFF22C55E),
                    ),
                  ),
                  Positioned(
                    bottom: -120 +
                        (animationController.value * 30),
                    left: -100,
                    child: _blob(
                      const Color(0xFF99F899),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // LOGO
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.shopping_basket,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "My SpiceMarket",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006E2F),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // LOGIN CARD
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 20,
                              color: Colors.black12,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Order fresh ingredients and groceries delivered to your doorstep.",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "Email Address",
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextField(
                              controller:
                              emailController,
                              keyboardType:
                              TextInputType
                                  .emailAddress,
                              textInputAction:
                              TextInputAction.next,
                              decoration:
                              InputDecoration(
                                hintText:
                                "name@email.com",
                                prefixIcon:
                                const Icon(
                                  Icons.mail_outline,
                                ),
                                border:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                const Text(
                                  "Password",
                                  style:
                                  TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child:
                                  const Text(
                                    "Forgot Password?",
                                  ),
                                ),
                              ],
                            ),

                            TextField(
                              controller:
                              passwordController,
                              obscureText:
                              obscurePassword,
                              textInputAction:
                              TextInputAction.done,
                              onSubmitted:
                                  (_) => _performLogin(),
                              decoration:
                              InputDecoration(
                                prefixIcon:
                                const Icon(
                                  Icons
                                      .lock_outline,
                                ),
                                suffixIcon:
                                IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons
                                        .visibility
                                        : Icons
                                        .visibility_off,
                                  ),
                                  onPressed:
                                      () {
                                    setState(() {
                                      obscurePassword =
                                      !obscurePassword;
                                    });
                                  },
                                ),
                                border:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width:
                              double.infinity,
                              height: 55,
                              child:
                              ElevatedButton(
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  const Color(
                                    0xFF006E2F,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                                  onPressed: () => _performLogin(),
                                child:
                                isLoading
                                    ? const SizedBox(
                                  height:
                                  22,
                                  width:
                                  22,
                                  child:
                                  CircularProgressIndicator(
                                    color:
                                    Colors.white,
                                    strokeWidth:
                                    2,
                                  ),
                                )
                                    : const Text(
                                  "Login",
                                  style:
                                  TextStyle(
                                    fontSize:
                                    16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Row(
                              children: [
                                Expanded(
                                  child:
                                  Container(
                                    height: 1,
                                    color: Colors
                                        .grey
                                        .shade300,
                                  ),
                                ),
                                const Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal:
                                    10,
                                  ),
                                  child:
                                  Text("OR"),
                                ),
                                Expanded(
                                  child:
                                  Container(
                                    height: 1,
                                    color: Colors
                                        .grey
                                        .shade300,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            SizedBox(
                              width:
                              double.infinity,
                              height: 55,
                              child:
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon:
                                const Icon(
                                  Icons
                                      .g_mobiledata,
                                  size: 32,
                                ),
                                label:
                                const Text(
                                  "Continue with Google",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
    );
  }
}