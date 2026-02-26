import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'services/supabase_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate configuration
  try {
    AppConfig.validateConfig();
  } catch (e) {
    runApp(ConfigErrorApp(error: e.toString()));
    return;
  }

  // Initialize Supabase (skip in demo mode)
  if (!AppConfig.demoMode) {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      runApp(ConfigErrorApp(error: 'Erreur Supabase: $e'));
      return;
    }
  }

  runApp(
    const ProviderScope(
      child: StudiOffApp(),
    ),
  );
}

/// Error app shown when configuration is invalid
class ConfigErrorApp extends StatelessWidget {
  final String error;
  
  const ConfigErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudiOff - Configuration',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
      ),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, size: 64, color: Color(0xFF6366F1)),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuration requise',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '🚀 Mode Démo (tester l\'UI)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SelectableText(
                      'flutter run -d chrome --dart-define=DEMO_MODE=true',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '⚡ Mode Production (avec Supabase)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SelectableText(
                      '1. Copiez .env.example vers .env\n'
                      '2. Remplissez vos clés Supabase\n'
                      '3. Exécutez: .\\run_dev.ps1',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
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
