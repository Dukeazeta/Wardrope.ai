import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import '../theme/app_theme.dart';
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final appBarColor = theme.appBarTheme.backgroundColor ?? backgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = theme.iconTheme.color ?? textColor;
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
          'Profile',
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
            fontSize: AppTheme.headlineSmallFontSize,
            fontWeight: FontWeight.w600,
=======
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
<<<<<<< HEAD
              Navigator.of(context).pushNamed('/settings');
            },
            icon: Icon(
              Icons.settings_outlined,
              color: iconColor,
=======
              // TODO: Open settings
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
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
              child: Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.account_circle,
                      size: 40,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      size: 40,
                      color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                    ),
                  ),
                  const SizedBox(width: 20),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
<<<<<<< HEAD
                        Text(
                          'Fashion Lover',
                          style: AppTheme.primaryFont.copyWith(
                            fontSize: AppTheme.titleMediumFontSize,
                            fontWeight: FontWeight.w600,
                            color: textColor,
=======
                        const Text(
                          'Fashion Lover',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'fashion.lover@example.com',
<<<<<<< HEAD
                          style: AppTheme.primaryFont.copyWith(
                            fontSize: AppTheme.bodySmallFontSize,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
<<<<<<< HEAD
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Premium Member',
                            style: AppTheme.primaryFont.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColor,
=======
                            color: Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium Member',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Statistics
<<<<<<< HEAD
            Text(
              'Your Wardrobe Stats',
              style: AppTheme.primaryFont.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
=======
            const Text(
              'Your Wardrobe Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.checkroom,
                    title: 'Items',
                    value: '0',
                    color: Colors.blue,
<<<<<<< HEAD
                    isDark: isDark,
                    textColor: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.style,
                    title: 'Outfits',
                    value: '0',
                    color: Colors.purple,
<<<<<<< HEAD
                    isDark: isDark,
                    textColor: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    value: '0',
                    color: Colors.red,
<<<<<<< HEAD
                    isDark: isDark,
                    textColor: textColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

<<<<<<< HEAD
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.primaryFont.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
=======
            // Menu Items
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
<<<<<<< HEAD
              icon: Icons.share_outlined,
              title: 'Share App',
              subtitle: 'Share Wardrope.ai with friends',
              onTap: () {},
              isDark: isDark,
              textColor: textColor,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.rate_review_outlined,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: () {},
              isDark: isDark,
              textColor: textColor,
              cardColor: cardColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve the app',
              onTap: () {},
              isDark: isDark,
              textColor: textColor,
              cardColor: cardColor,
              borderColor: borderColor,
=======
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your profile details',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Control your privacy settings',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
              icon: Icons.style_outlined,
              title: 'Style Preferences',
              subtitle: 'Set your fashion preferences',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.palette_outlined,
              title: 'Color Preferences',
              subtitle: 'Choose your favorite colors',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  _showSignOutDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                'Wardrope.ai v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
<<<<<<< HEAD
    required bool isDark,
    required Color textColor,
    required Color cardColor,
    required Color borderColor,
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: cardColor,
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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
<<<<<<< HEAD
            style: AppTheme.primaryFont.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
=======
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
<<<<<<< HEAD
            style: AppTheme.primaryFont.copyWith(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
<<<<<<< HEAD
    required bool isDark,
    required Color textColor,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
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
                        fontSize: 16,
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
<<<<<<< HEAD
                      style: AppTheme.primaryFont.copyWith(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
                      style: TextStyle(
                        fontSize: 13,
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
=======
                color: Colors.grey.shade400,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement sign out logic
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
}