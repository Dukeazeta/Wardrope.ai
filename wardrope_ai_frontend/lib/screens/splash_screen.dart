import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

<<<<<<< HEAD
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start with a slight delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Start scale and fade animations together
    _scaleController.forward();
    _fadeController.forward();

    // Start shimmer animation after fade begins
    await Future.delayed(const Duration(milliseconds: 500));
    _shimmerController.repeat(reverse: true);

    // Complete and navigate after animations
    Future.delayed(const Duration(milliseconds: 2500), () {
=======
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simple delay without animation
    Future.delayed(const Duration(seconds: 2), () {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
<<<<<<< HEAD
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.black,
                    Colors.black,
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    Colors.white,
                  ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _scaleAnimation,
              _shimmerAnimation,
              _glowAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          textColor.withValues(alpha: 0.8),
                          textColor,
                          textColor.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                        end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                      ).createShader(bounds);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: textColor.withValues(alpha: _glowAnimation.value * 0.3),
                            blurRadius: 20 * _glowAnimation.value,
                            spreadRadius: 5 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: Text(
                        'Wardrobe.ai',
                        style: TextStyle(
                          fontFamily: 'Goodly',
                          fontSize: AppTheme.displayLargeFontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
=======
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Text(
            'Wardrope.ai',
            style: TextStyle(
              fontSize: AppTheme.displayLargeFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -1.2,
            ),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          ),
        ),
      ),
    );
  }
}