import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/animations/aurora_background.dart';
import '../../core/animations/slide_up_reveal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final n = ref.read(authProvider.notifier);
    if (_isLogin) {
      n.signIn(_emailCtrl.text.trim(), _pwCtrl.text);
    } else {
      n.register(_emailCtrl.text.trim(), _pwCtrl.text, _nameCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.success) {
        if (next.role == UserRole.manager) {
          context.go('/dashboard');
        } else if (next.role == UserRole.staff) {
          context.go('/staff-home');
        } else {
          context.go('/guest-home');
        }
      }
    });

    return Scaffold(
      body: AuroraBackground(
        blobColors: [
          AppColors.commandBlue.withOpacity(0.09),
          AppColors.intelViolet.withOpacity(0.07),
          AppColors.statusTeal.withOpacity(0.05),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  // Logo row
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 40),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.crisisRed.withOpacity(0.6),
                              width: 1.5),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            size: 22, color: AppColors.crisisRed),
                      ),
                      const SizedBox(width: 12),
                      const Text('VIGIL',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 5)),
                    ]),
                  ),
                  const SizedBox(height: 52),
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      _isLogin ? 'Welcome\nback.' : 'Create your\naccount.',
                      style: AppTypography.h1.copyWith(
                          fontSize: 36, height: 1.15, letterSpacing: -1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 160),
                    child: Text(
                      _isLogin
                          ? 'Sign in to your command centre.'
                          : 'Set up your hotel\'s crisis command.',
                      style: AppTypography.body,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Form card
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 220),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (!_isLogin) ...[
                            _field(
                                ctrl: _nameCtrl,
                                label: 'Full Name',
                                hint: 'James Harrington',
                                icon: Icons.person_outline),
                            const SizedBox(height: 14),
                          ],
                          _field(
                              ctrl: _emailCtrl,
                              label: 'Email',
                              hint: 'manager@hotel.com',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (v) =>
                                  (v == null || !v.contains('@'))
                                      ? 'Enter a valid email'
                                      : null),
                          const SizedBox(height: 14),
                          _field(
                              ctrl: _pwCtrl,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hint chip
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 280),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.intelViolet.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.intelViolet.withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.auto_awesome,
                            size: 14, color: AppColors.intelViolet),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Presets:\n1. manager@vigil.com / manager123\n2. staff@vigil.com / staff123\n3. guest@vigil.com / guest123',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.intelViolet),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // CTA
                  SlideUpReveal(
                    delay: const Duration(milliseconds: 340),
                    child: GestureDetector(
                      onTap: auth.status == AuthStatus.loading ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.crisisRed,
                            const Color(0xFFE02828),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.crisisRed.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: auth.status == AuthStatus.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white))
                              : Text(
                                  _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? "No account?  Create one →"
                            : "Already registered?  Sign in →",
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    Widget? suffix,
  }) =>
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
          suffixIcon: suffix,
        ),
      );
}
