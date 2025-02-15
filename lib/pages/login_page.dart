import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';  // Hal utama set log

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisibility = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Periksa status login ketika halaman dimuat
  }

  // Memeriksa apakah pengguna sudah login
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Jika sudah login, arahkan ke halaman Home
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  // Fungsi login
  Future<void> login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    // Validasi input username dan password
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password cannot be empty')),
      );
      return;
    }

    // Query ke Supabase untuk verifikasi login
    final response = await Supabase.instance.client
        .from('users')  // Ganti dengan tabel yang sesuai di Supabase Anda
        .select()
        .eq('username', username)
        .single()
        ._execute();

    if (response.error == null) {
      var user = response.data;
      if (user != null && user['password'] == password) {
        // Menyimpan username, role, dan status login ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);  // Simpan username
        await prefs.setString('role', user['role']);  // Simpan role pengguna
        await prefs.setBool('isLoggedIn', true);      // Simpan status login

        // Arahkan ke halaman utama setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } else {
      // Menampilkan error dari Supabase jika login gagal
      print('Error: ${response.error!.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${response.error!.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();  // Menyembunyikan keyboard saat tapping di luar
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D47A1),  // Warna latar belakang halaman login lebih gelap
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Masuk', 
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,  // Warna teks judul menjadi putih
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form login
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),  // Warna kotak form login lebih cerah
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan Username',
                          filled: true,
                          fillColor: const Color(0xFFF1F8E9),  // Ganti warna background inputan
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      TextField(
                        controller: passwordController,
                        obscureText: !passwordVisibility,  // Mengatur visibilitas password
                        decoration: InputDecoration(
                          hintText: 'Masukkan Password',
                          filled: true,
                          fillColor: const Color(0xFFF1F8E9),  // Ganti warna background inputan
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;  // Toggle visibilitas password
                              });
                            },
                            child: Icon(
                              passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: login,  // Panggil fungsi login saat tombol diklik
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03346E),  // Ganti dengan warna #03346E
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Masuk', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on PostgrestTransformBuilder<PostgrestMap> {
  _execute() {}
}

// nanti ku hapus