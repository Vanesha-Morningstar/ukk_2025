import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pages/welcome_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ghvldfultsnwbqnrpipd.supabase.co', // Ganti dengan URL Supabase kamu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdodmxkZnVsdHNud2JxbnJwaXBkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDg2NzYsImV4cCI6MjA1NDk4NDY3Nn0.o7N4BuZ1_QhZDzG_600Ez1x4Oopq0F3WrekpbcdrGVs', // Ganti dengan Anon Key Supabase kamu
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
