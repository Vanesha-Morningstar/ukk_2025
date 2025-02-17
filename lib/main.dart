import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/welcome_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dbrcntrcnniqbpqpevcl.supabase.co', // Ganti dengan URL Supabase kamu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmNudHJjbm5pcWJwcXBldmNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MDI5NzIsImV4cCI6MjA1NTE3ODk3Mn0.kTJr-Z5Llsf0oXpbCNfpMyLT30bNzn4iIUtm1p1H2LQ', // Ganti dengan Anon Key Supabase kamu
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login App',
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
