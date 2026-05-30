import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/config/theme_config.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Login failed'),
              backgroundColor: NearMeColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: NearMeColors.navyDeep,
      body: Stack(
        children: [
          // ── City-grid dot pattern background ──
          Positioned.fill(
            child: CustomPaint(painter: _CityGridPainter()),
          ),

          // ── Gold glow at top ──
          Positioned(
            top: -80,
            left: size.width * 0.5 - 150,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NearMeColors.gold.withAlpha(60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // ── NearMe Logo ──
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: NearMeColors.goldGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: NearMeColors.gold.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Near',
                                style: TextStyle(
                                  color: NearMeColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Me',
                                style: TextStyle(
                                  color: NearMeColors.gold,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Hero Headline ──
                    const Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        color: NearMeColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your community is waiting for you.',
                      style: TextStyle(
                        color: NearMeColors.textSecondary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Pitch Deck Feature Chips ──
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _FeatureChip(icon: Icons.location_on_rounded, label: 'Location-Anchored', color: NearMeColors.gold),
                        _FeatureChip(icon: Icons.lock_rounded, label: 'E2EE Privacy', color: NearMeColors.electricBlue),
                        _FeatureChip(icon: Icons.campaign_rounded, label: 'Hyperlocal', color: NearMeColors.success),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // ── Email ──
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // ── Password ──
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: NearMeColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Login Button ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => CustomButton(
                        text: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: auth.isLoading,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Register Link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New to NearMe? ",
                          style: TextStyle(color: NearMeColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/register'),
                          child: const Text(
                            'Join Your Street',
                            style: TextStyle(
                              color: NearMeColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ── Tagline footer ──
                    Center(
                      child: Text(
                        '"The Internet Was Built for the World.\nWe\'re Building It for Your Street."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: NearMeColors.textMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Chip ──────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── City Grid Background Painter ─────────────────────────
class _CityGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NearMeColors.navyBorder.withAlpha(60)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dot nodes at intersections
    final dotPaint = Paint()
      ..color = NearMeColors.navyBorder.withAlpha(100)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
