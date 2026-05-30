import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/config/theme_config.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Registration failed'),
              backgroundColor: NearMeColors.error,
              duration: const Duration(seconds: 4),
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
          // ── City-grid dot pattern ──
          Positioned.fill(child: CustomPaint(painter: _CityGridPainter())),

          // ── Electric blue glow top-right ──
          Positioned(
            top: -60,
            right: -60,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NearMeColors.electricBlue.withAlpha(50),
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
                    const SizedBox(height: 32),

                    // ── Back button + NearMe Logo ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: NearMeColors.navyCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: NearMeColors.navyBorder),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: NearMeColors.textSecondary, size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: NearMeColors.goldGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Near',
                                style: TextStyle(
                                  color: NearMeColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: 'Me',
                                style: TextStyle(
                                  color: NearMeColors.gold,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Hero Headline ──
                    const Text(
                      'Join Your\nNeighbourhood 🚀',
                      style: TextStyle(
                        color: NearMeColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect with people within your actual radius.',
                      style: TextStyle(
                        color: NearMeColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Form Fields ──
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a strong password',
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
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (value) => Validators.validateConfirmPassword(
                          value, _passwordController.text),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: NearMeColors.textSecondary,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Register Button ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => CustomButton(
                        text: 'Create Account',
                        onPressed: _handleRegister,
                        isLoading: auth.isLoading,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Login Link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already on NearMe? ',
                          style: TextStyle(color: NearMeColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: NearMeColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Privacy note ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: NearMeColors.electricBlue.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: NearMeColors.electricBlue.withAlpha(50)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_rounded,
                              color: NearMeColors.electricBlue, size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All chats are End-to-End Encrypted. NearMe cannot read your messages.',
                              style: TextStyle(
                                  color: NearMeColors.electricBlue,
                                  fontSize: 11,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _CityGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NearMeColors.navyBorder.withAlpha(50)
      ..strokeWidth = 0.5;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dotPaint = Paint()
      ..color = NearMeColors.navyBorder.withAlpha(90)
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
