import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import '../theme/app_theme.dart';

class AIStylistScreen extends StatefulWidget {
  const AIStylistScreen({super.key});

  @override
  State<AIStylistScreen> createState() => _AIStylistScreenState();
}

class _AIStylistScreenState extends State<AIStylistScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final appBarColor = theme.appBarTheme.backgroundColor ?? backgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'AI Stylist',
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
            fontSize: AppTheme.headlineLargeFontSize,
            fontWeight: FontWeight.w600,
=======

class AIStylistScreen extends StatelessWidget {
  const AIStylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'AI Stylist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
=======
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Personal AI Stylist',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.titleMediumFontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
=======
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Personal AI Stylist',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
<<<<<<< HEAD
                  Text(
                    'Get personalized outfit recommendations powered by AI',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodyMediumFontSize,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                  const Text(
                    'Get personalized outfit recommendations powered by AI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Feature Cards
<<<<<<< HEAD
            Text(
              'Features',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
=======
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildFeatureCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Outfit of the Day',
                    description: 'Get daily outfit suggestions based on weather and your style',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    icon: Icons.style_outlined,
                    title: 'Style Analysis',
                    description: 'Analyze your wardrobe and discover your style profile',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    icon: Icons.palette_outlined,
                    title: 'Color Coordination',
                    description: 'Find perfect color combinations for your outfits',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    icon: Icons.event_outlined,
                    title: 'Occasion Dressing',
                    description: 'Get outfit recommendations for specific events',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final containerColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
=======
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
=======
            color: Colors.black.withValues(alpha: 0.04),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: iconBgColor,
=======
                color: Colors.black.withValues(alpha: 0.06),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
<<<<<<< HEAD
                color: textColor,
=======
                color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
<<<<<<< HEAD
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.titleMediumFontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
=======
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
<<<<<<< HEAD
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodySmallFontSize,
                      color: subtitleColor,
=======
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
<<<<<<< HEAD
              color: subtitleColor,
=======
              color: Colors.grey.shade400,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
          ],
        ),
      ),
    );
  }
}