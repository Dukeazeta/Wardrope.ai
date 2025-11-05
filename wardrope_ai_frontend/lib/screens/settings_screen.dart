import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeService themeService;

  const SettingsScreen({
    super.key,
    required this.themeService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSyncEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Listen to theme service changes
    widget.themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _darkModeEnabled = widget.themeService.isDarkMode;
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = widget.themeService.isDarkMode;
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
      _selectedCurrency = prefs.getString('selected_currency') ?? 'USD';
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final scaffoldColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: textColor,
            size: 20,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTheme.primaryFont.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            Text(
              'Account',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive notifications about your wardrobe',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSetting('notifications_enabled', value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or Face ID to unlock',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  _saveSetting('biometric_enabled', value);
                },
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // Appearance
            Text(
              'Appearance',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Use dark theme across the app',
                value: _darkModeEnabled,
                onChanged: (value) {
                  widget.themeService.setDarkMode(value);
                },
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // Preferences
            Text(
              'Preferences',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildLanguageTile(),
              _buildCurrencyTile(),
              _buildSwitchTile(
                icon: Icons.sync_outlined,
                title: 'Auto Sync',
                subtitle: 'Automatically sync wardrobe data',
                value: _autoSyncEnabled,
                onChanged: (value) {
                  setState(() => _autoSyncEnabled = value);
                  _saveSetting('auto_sync_enabled', value);
                },
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // Storage & Data
            Text(
              'Storage & Data',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildMenuTile(
                icon: Icons.storage_outlined,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () => _showClearCacheDialog(),
              ),
              _buildMenuTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                subtitle: 'Download all your wardrobe data',
                onTap: () => _showExportDataDialog(),
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // Support
            Text(
              'Support',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildMenuTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(),
              ),
            ]),

            SizedBox(height: AppTheme.spacingXXL),

            // Account Management
            Text(
              'Account Management',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildMenuTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Update your profile details',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.style_outlined,
                title: 'Style Preferences',
                subtitle: 'Set your fashion preferences',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.palette_outlined,
                title: 'Color Preferences',
                subtitle: 'Choose your favorite colors',
                onTap: () {},
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // Danger Zone
            Text(
              'Danger Zone',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.headlineSmallFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            _buildSettingsCard([
              _buildMenuTile(
                icon: Icons.logout_outlined,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: () => _showSignOutDialog(),
                isDangerous: true,
              ),
              _buildMenuTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                onTap: () => _showDeleteAccountDialog(),
                isDangerous: true,
              ),
            ]),

            SizedBox(height: AppTheme.spacingL),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Wardrobe.ai v1.0.0',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodySmallFontSize,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Made with ❤️ for fashion lovers',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodySmallFontSize,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.04);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final switchColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              size: 24,
              color: textColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.titleMediumFontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.bodySmallFontSize,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: switchColor.withValues(alpha: 0.3),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? switchColor : null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconBgColor = isDangerous
        ? Colors.red.withValues(alpha: 0.1)
        : (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.06));
    final iconColor = isDangerous ? Colors.red : textColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.titleMediumFontSize,
                      fontWeight: FontWeight.w600,
                      color: isDangerous ? Colors.red : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodySmallFontSize,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final dropdownBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              Icons.language_outlined,
              size: 24,
              color: textColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.titleMediumFontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your preferred language',
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.bodySmallFontSize,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: _selectedLanguage,
            onSelected: (String value) {
              setState(() => _selectedLanguage = value);
              _saveSetting('selected_language', value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: dropdownBgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLanguage,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodyMediumFontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: subtitleColor,
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) {
              return ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese']
                  .map<PopupMenuEntry<String>>((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodyMediumFontSize,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final dropdownBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              Icons.attach_money_outlined,
              size: 24,
              color: textColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currency',
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.titleMediumFontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your preferred currency',
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: AppTheme.bodySmallFontSize,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: _selectedCurrency,
            onSelected: (String value) {
              setState(() => _selectedCurrency = value);
              _saveSetting('selected_currency', value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: dropdownBgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCurrency,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodyMediumFontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: subtitleColor,
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) {
              return ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'CAD', 'AUD']
                  .map<PopupMenuEntry<String>>((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: AppTheme.bodyMediumFontSize,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached images and data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('We\'ll prepare all your wardrobe data for download. You\'ll receive an email when it\'s ready.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export request submitted. You\'ll receive an email shortly.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Wardrobe.ai',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.checkroom,
        size: 48,
        color: Colors.black,
      ),
      children: [
        const Text('Your AI-powered wardrobe assistant.'),
        const SizedBox(height: 16),
        const Text('Made with ❤️ for fashion lovers.'),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data including wardrobe items, outfits, and preferences will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted. You\'ll receive a confirmation email.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
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
              // TODO: Implement proper sign out logic
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (Route<dynamic> route) => false,
              );
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
}