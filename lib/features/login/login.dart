import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../provider/auth_firebase.dart';

// ─────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────
abstract final class _AppColors {
  static const bgLight = Color(0xFFF2F1ED);
  static const gradientStart = Color(0xFFEC93B8);
  static const gradientEnd = Color(0xFFF47B3C);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const linkColor = Color(0xFFD4621A);
  static const surface = Colors.white;
}

enum _AuthMethod { apple, google }

// ─────────────────────────────────────────────
// Login Page
// ─────────────────────────────────────────────
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  _AuthMethod? _activeMethod;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleAppleSignIn() {
    if (_activeMethod != null) return;
    setState(() => _activeMethod = _AuthMethod.apple);
    ref.read(authServiceProvider.notifier).loginWithApple();
  }

  void _handleGoogleSignIn() {
    if (_activeMethod != null) return;
    setState(() => _activeMethod = _AuthMethod.google);
    ref.read(authServiceProvider.notifier).loginWithGoogle();
  }

  void _handleSignInHere() {
    // TODO: navigate to dedicated sign-in page when available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in page coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);
    final size = MediaQuery.sizeOf(context);

    // Clear active method when auth finishes (success or error)
    ref.listen<AuthState>(authServiceProvider, (previous, next) {
      if (!next.isLoading && mounted) {
        setState(() => _activeMethod = null);
      }
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authServiceProvider.notifier).resetStatus();
      }
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Split background ──
          _Background(screenHeight: size.height),

          // ── 2. White arch decoration ──
          _BottomArch(screenWidth: size.width),

          // ── 3. Content (SafeArea + fade) ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildContent(size, isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size, bool isLoading) {
    final isSmall = size.height < 680;
    final isLarge = size.height > 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.09),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top spacer ──
              SizedBox(
                height: isSmall
                    ? size.height * 0.09
                    : isLarge
                        ? size.height * 0.16
                        : size.height * 0.13,
              ),

              // ── Philosopher / thinker icon ──
              Semantics(
                label: 'App logo – philosopher figure',
                child: SvgPicture.asset(
                  'assets/icons/philosopher-bust.svg',
                  width: isSmall ? 44 : 56,
                  height: isSmall ? 44 : 56,
                  colorFilter: const ColorFilter.mode(
                    _AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              SizedBox(height: isSmall ? 20 : 28),

              // ── Heading ──
              Text(
                'Create a\nnew mind.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isSmall ? 42 : 52,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.textPrimary,
                  height: 1.16,
                ),
              ),

              SizedBox(height: isSmall ? 38 : 56),

              // ── Sign up with Apple ──
              _SocialButton(
                onPressed: isLoading ? null : _handleAppleSignIn,
                isLoading:
                    isLoading && _activeMethod == _AuthMethod.apple,
                icon: const Icon(
                  Icons.apple,
                  size: 22,
                  color: _AppColors.textPrimary,
                ),
                label: 'Sign up with Apple',
              ),

              const SizedBox(height: 14),

              // ── Sign up with Google ──
              _SocialButton(
                onPressed: isLoading ? null : _handleGoogleSignIn,
                isLoading:
                    isLoading && _activeMethod == _AuthMethod.google,
                icon: const _GoogleIcon(size: 20),
                label: 'Sign up with Google',
              ),

              const SizedBox(height: 32),

              // ── Already have an account? ──
              Text(
                'Already have an account?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _handleSignInHere,
                behavior: HitTestBehavior.opaque,
                child: Semantics(
                  button: true,
                  label: 'Sign in here',
                  child: Text(
                    'Sign in here',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _AppColors.linkColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: _AppColors.linkColor,
                    ),
                  ),
                ),
              ),

              // ── Bottom spacer (clears arch) ──
              SizedBox(height: size.height * 0.20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Background: top warm-gray / bottom gradient
// ─────────────────────────────────────────────
class _Background extends StatelessWidget {
  final double screenHeight;

  const _Background({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top ~60% — warm off-white
        SizedBox(
          height: screenHeight * 0.60,
          child: const ColoredBox(color: _AppColors.bgLight),
        ),
        // Bottom ~40% — pink → orange gradient
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _AppColors.gradientStart,
                  _AppColors.gradientEnd,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Bottom white arch decoration
// ─────────────────────────────────────────────
class _BottomArch extends StatelessWidget {
  final double screenWidth;

  const _BottomArch({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final archWidth = screenWidth * 0.78;
    final archHeight = archWidth * 0.52;
    return Positioned(
      bottom: 0,
      left: (screenWidth - archWidth) / 2,
      child: Container(
        width: archWidth,
        height: archHeight,
        decoration: const BoxDecoration(
          color: _AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(9999),
            topRight: Radius.circular(9999),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Social auth button (pill shape, white, shadow)
// ─────────────────────────────────────────────
class _SocialButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.label,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF8F8F8) : _AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.13 : 0.08),
              blurRadius: _hovered ? 18 : 10,
              offset: Offset(0, _hovered ? 6 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(32),
            splashColor: Colors.grey.withValues(alpha: 0.12),
            highlightColor: Colors.grey.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: widget.isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _AppColors.textPrimary,
                            ),
                          )
                        : widget.icon,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _AppColors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Colorful Google G icon (inline SVG, no package)
// ─────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  final double size;

  const _GoogleIcon({required this.size});

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#4285F4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84
    c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11C42.72 36.64 45.12 31 45.12 24.5z"/>
  <path fill="#34A853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52
    c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7
    C7.96 41.07 15.4 46 24 46z"/>
  <path fill="#FBBC05" d="M11.69 28.18C11.25 26.86 11 25.45 11 24
    s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24c0 3.55.85 6.91 2.34 9.88
    l7.35-5.7z"/>
  <path fill="#EA4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31
    C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7
    c1.73-5.2 6.58-9.07 12.31-9.07z"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: size, height: size);
  }
}
