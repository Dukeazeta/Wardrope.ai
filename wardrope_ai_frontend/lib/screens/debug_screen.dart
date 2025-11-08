import 'package:flutter/material.dart';
import '../services/hybrid_ai_service.dart';
import '../config/app_config.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isTesting = false;
  String _result = '';
  String _baseUrl = '';

  @override
  void initState() {
    super.initState();
    _updateBaseUrl();
  }

  void _updateBaseUrl() {
    final baseUrl = HybridAIService.baseUrl;
    setState(() {
      _baseUrl = baseUrl;
    });
  }

  Future<void> _testConnection() async {
    if (!mounted) return;

    setState(() {
      _isTesting = true;
      _result = 'Testing connection...\n';
    });

    try {
      final result = await HybridAIService.checkStatus();

      if (!mounted) return;

      setState(() {
        _result += '✅ Connection successful!\n\n';
        _result += 'Status Code: ${result['success'] ? 'SUCCESS' : 'FAILED'}\n';
        _result += 'Base URL: $_baseUrl\n\n';
        _result += 'Response:\n${result.toString()}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result += '❌ Connection failed!\n\n';
        _result += 'Error: $e\n\n';
        _result += 'Base URL attempted: $_baseUrl\n\n';
        _result += '🔧 CONFIGURATION:\n';
        _result += 'Current Environment: ${AppConfig.isDevelopment ? "Development" : "Production"}\n';
        _result += 'Base URL: $_baseUrl\n\n';
        _result += '🔧 DEVELOPMENT SETUP:\n';
        _result += '1. Set _isDevelopment = true in lib/config/app_config.dart\n';
        _result += '2. Update _devSimplifiedAIBaseUrl with your local IP\n';
        _result += '3. Find your computer\'s IP:\n';
        _result += '   - Windows: "ipconfig" in Command Prompt\n';
        _result += '   - Mac/Linux: "ifconfig" or "ip addr" in Terminal\n';
        _result += '4. Make sure phone and computer are on same WiFi\n\n';
        _result += '🔥 Troubleshooting:\n';
        _result += '• Backend running? Check: http://localhost:3000/health\n';
        _result += '• Firewall blocking? Allow port 3000\n';
        _result += '• Production URL correct? Check Vercel deployment\n';
        _result += '• CORS configured? Backend allows all origins\n';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: const Text('Debug Connection'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Test',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Environment: ${AppConfig.isDevelopment ? 'Development' : 'Production'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppConfig.isDevelopment ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Base URL: $_baseUrl',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isTesting ? null : _testConnection,
                        child: _isTesting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Testing...'),
                                ],
                              )
                            : const Text('Test Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                color: theme.cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _result.isEmpty ? 'Press "Test Connection" to start debugging' : _result,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}