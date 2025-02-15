import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String _username = '';
  String _role = '';
  String _profileImage = 'assets/images/avatar.png';  // Default profile image

  @override
  void initState() {
    super.initState();
    _getUsernameAndRole(); // Mengambil username dan role saat halaman dimuat
  }

  // Fungsi untuk mendapatkan username dan role dari Supabase
  _getUsernameAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });

    final response = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('username', _username)
        .single()
        .execute();

    if (response.error == null) {
      String role = response.data['role'];  // Mengambil role dari Supabase
      setState(() {
        _role = role;
        // Mengatur gambar profil berdasarkan role
        _profileImage = role == 'administrator'
            ? 'assets/images/admin.png'  // Gambar untuk admin
            : 'assets/images/avatar.png'; // Gambar default
      });
    } else {
      print('Error: ${response.error!.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header untuk menampilkan gambar profil dan informasi pengguna
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(_profileImage),  // Gambar berdasarkan role
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: $_username',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Role: $_role',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Tombol untuk logout
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk logout dan menghapus data di SharedPreferences
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus data login

    // Navigasi kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),  // Halaman Login
    );
  }
}
