import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'services/permission_service.dart';
import 'screens/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace these with your actual Supabase URL and anon key
  // You can also use environment variables or a config file
  const supabaseUrl = 'https://lkzsfvuojsbyzjyhcpjk.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrenNmdnVvanNieXpqeWhjcGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2NjgxNTEsImV4cCI6MjA4MzI0NDE1MX0.GNax-6ELwAXsGaHcsqsAs7WMnuwrQV5TxkJCnjOGqm0';

  await SupabaseService.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Note: Permissions are requested when the user actually needs them
  // This ensures they appear in iOS Settings after the first request
  // Requesting permissions in main() before UI is ready can fail silently on iOS

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Coach MVP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
