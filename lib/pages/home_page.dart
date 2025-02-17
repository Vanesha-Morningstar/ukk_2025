import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:ukk_2025/product/product_page.dart';
import 'package:ukk_2025/product/pembayaran.dart';
import 'package:ukk_2025/pelanggan/pelanggan_page.dart';
import 'package:ukk_2025/pages/akun.dart';
import 'package:ukk_2025/pages/register_page.dart'; // Import halaman Register
import 'package:ukk_2025/pages/transaksi_page.dart'; // Import halaman Transaksi
import 'userpage.dart'; // Import UserPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = ''; // Username pengguna
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    Container(), // Halaman pertama (Home)
    const TransaksiPage(), // Halaman kedua (Transaksi)
    const ProdukPage(), // Halaman ketiga (Produk)
    const PelangganPage(), // Halaman keempat (Pelanggan)
    const UsersPage(), // Halaman kelima (User)
  ];

  // Mendapatkan username dari SharedPreferences
  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      print('Username pengguna: $_username');  // Debugging: Menampilkan username pengguna
    });

    // Menambahkan HomePageContent dengan username yang sesuai
    setState(() {
      _pages[0] = HomePageContent(username: _username);
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fungsi logout
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Fungsi untuk menangani perubahan halaman saat dipilih di bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Menetapkan halaman yang dipilih berdasarkan indeks
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_username),
              accountEmail: Text('$_username@example.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Akun'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AkunPage()), // Navigasi ke halaman Akun
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Pembayaran'),
              onTap: () {
                // Siapkan data keranjang
                List<String> keranjang = ['Produk 1', 'Produk 2', 'Produk 3'];

                // Navigasi ke halaman Pembayaran dan kirimkan data keranjang
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PembayaranPage(keranjang: keranjang), // Kirimkan keranjang
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Produk'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Mengarahkan ke halaman Produk
                });
                Navigator.pop(context); // Menutup Drawer setelah memilih
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Pelanggan'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Mengarahkan ke halaman Pelanggan
                });
                Navigator.pop(context); // Menutup Drawer setelah memilih
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4; // Mengarahkan ke halaman User
                });
                Navigator.pop(context); // Menutup Drawer setelah memilih
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registrasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()), // Navigasi ke halaman Registrasi
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Toko Jul',
          style: TextStyle(
            color: Colors.white, // Warna teks putih
            fontWeight: FontWeight.bold, // Teks tebal
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Warna ikon garis tiga menjadi putih
        ),
      ),
      body: _pages.isNotEmpty
          ? _pages[_selectedIndex] // Menampilkan halaman berdasarkan indeks yang dipilih
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long), // Mengganti logo menjadi ikon struk/tagihan
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String username;

  const HomePageContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $username',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text(
                        'Selamat bekerja 😊',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Total Pendapatan', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('\$25,202',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Siapkan data keranjang
                    List<String> keranjang = ['Produk 1', 'Produk 2', 'Produk 3'];

                    // Navigasi ke halaman Pembayaran dan kirimkan data keranjang
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PembayaranPage(keranjang: keranjang),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(160, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Pembayaran',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProdukPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(160, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Produk',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
