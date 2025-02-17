import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ukk_2025/product/product_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PembayaranPage extends StatefulWidget {
  final List<String> keranjang;

  const PembayaranPage({super.key, required this.keranjang});

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  int totalHarga = 0;
  List<dynamic> produkList = [];
  List<dynamic> filteredProdukList = [];
  Map<int, int> keranjang = {}; // ID produk dan jumlah
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  bool _produkTidakDitemukan = false;

  // Data pelanggan
  List<Map<String, dynamic>> _pelangganList = [];
  Map<String, dynamic>? _selectedPelanggan;

  @override
  void initState() {
    super.initState();
    _loadProduk();
    _loadPelanggan();
    _searchController.addListener(_cariProduk);
  }

  void _showPembayaranBerhasilDialog(String namaPelanggan, String tanggal, int diskon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Toko: Jul'),
              Text('Tanggal: $tanggal'),
              Text('Pelanggan: $namaPelanggan'),
              if (diskon > 0)
                Text('Diskon (3%): -${formatRupiah(diskon)}',
                    style: const TextStyle(color: Colors.green)),
              Text('Total: ${formatRupiah(totalHarga)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Menutup halaman pembayaran
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> simpanTransaksi(String tanggalPenjualan, double totalHarga, int pelangganId) async {
    try {
      final response = await Supabase.instance.client
          .from('penjualan')  // Nama tabel
          .upsert({
            'tanggal_penjualan': tanggalPenjualan,
            'totalharga': totalHarga,
            'pelangganid': pelangganId,
          }).execute();

      if (response.error != null) {
        throw response.error!;
      }

      // Tampilkan pesan jika berhasil
      print("Transaksi berhasil disimpan");

    } catch (e) {
      print("Error: $e");
      // Tampilkan error jika gagal menyimpan
    }
  }

  // Mengambil data produk
  Future<void> _loadProduk() async {
    try {
      var produkData = await _productService.fetchProducts();
      setState(() {
        produkList = produkData;
        filteredProdukList = produkList; // Awalnya tampilkan semua produk
      });
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data produk')),
      );
    }
  }

  // Mengambil data pelanggan
  Future<void> _loadPelanggan() async {
    try {
      var pelangganData = await _productService.fetchPelanggan();
      setState(() {
        _pelangganList = (pelangganData).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data pelanggan')),
      );
    }
  }

  // Fungsi untuk mencari produk
  void _cariProduk() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((produk) =>
              produk['nama_produk'].toString().toLowerCase().contains(query))
          .toList();
      _produkTidakDitemukan = query.isNotEmpty && filteredProdukList.isEmpty;
    });
  }

  // Fungsi untuk menghitung total harga
  void hitungTotalHarga() {
    int total = 0;
    keranjang.forEach((id, jumlah) {
      var produk = produkList.firstWhere((item) => item['produk_id'] == id);
      total += (produk['harga'] as num).toInt() * jumlah;
    });

    setState(() {
      totalHarga = total;
    });
  }

  // Format harga ke dalam format Rupiah
  String formatRupiah(int harga) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(harga);
  }

  // Fungsi untuk menambahkan produk ke keranjang
  void tambahKeKeranjang(int produkId) {
    setState(() {
      keranjang[produkId] = (keranjang[produkId] ?? 0) + 1;
      hitungTotalHarga();
    });
  }

  // Fungsi untuk mengurangi produk dari keranjang
  void kurangiDariKeranjang(int produkId) {
    if (keranjang[produkId] != null && keranjang[produkId]! > 0) {
      setState(() {
        keranjang[produkId] = keranjang[produkId]! - 1;
        if (keranjang[produkId] == 0) keranjang.remove(produkId);
        hitungTotalHarga();
      });
    }
  }


  // Menampilkan dialog detail transaksi
  void _showDetailTransaksi() {
    String namaPelanggan = _selectedPelanggan?['namapelanggan'] ?? 'Pelanggan';
    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());  // Ubah format tanggal

    // Hitung total tanpa diskon
    int totalTanpaDiskon = 0;
    keranjang.forEach((id, jumlah) {
      var produk = produkList.firstWhere((item) => item['produk_id'] == id);
      totalTanpaDiskon += (produk['harga'] as num).toInt() * jumlah;
    });
    int bulatkanKeRibuan(int harga) {
      return (harga / 1000).round() * 1000;
    }
    // Bulatkan total tanpa diskon ke kelipatan 1000
    totalTanpaDiskon = bulatkanKeRibuan(totalTanpaDiskon);


    // Hitung potongan diskon 3% (karena semua pelanggan adalah member)
    int diskon = (totalTanpaDiskon * 3) ~/ 100;
    int totalSetelahDiskon = totalTanpaDiskon - diskon;

    // Bulatkan total setelah diskon ke kelipatan 1000
    totalSetelahDiskon = bulatkanKeRibuan(totalSetelahDiskon);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detail Transaksi'),
              const Text('Nama Toko: Jul', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('Tanggal: $tanggal', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text('Pelanggan: $namaPelanggan', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...keranjang.entries.map((entry) {
                var produk = produkList.firstWhere((item) => item['produk_id'] == entry.key);
                int jumlah = entry.value;
                int subtotal = (produk['harga'] as num).toInt() * jumlah;

                // Bulatkan subtotal ke kelipatan 1000
                subtotal = bulatkanKeRibuan(subtotal);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${produk['nama_produk']} x$jumlah',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatRupiah(subtotal)),
                          const Text(
                            'Bulatkan ke 1000',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatRupiah(totalTanpaDiskon)),
                      const Text(
                        'Bulatkan ke 1000',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              if (diskon > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diskon (3%):', style: TextStyle(color: Colors.green)),
                    Text('-${formatRupiah(diskon)}', style: const TextStyle(color: Colors.green)),
                  ],
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(totalSetelahDiskon),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Bulatkan ke 1000',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _konfirmasiPembayaran(namaPelanggan, tanggal, diskon);
              },
              child: const Text('Konfirmasi Pembayaran'),
            ),
          ],
        );
      },
    );
  }

  // Konfirmasi pembayaran
void _konfirmasiPembayaran(String namaPelanggan, String tanggal, int diskon) async {
  try {
    // 1. Menambahkan data transaksi ke tabel `penjualan`
    final responsePenjualan = await Supabase.instance.client
        .from('penjualan')
        .upsert({
          'tanggal_penjualan': tanggal,
          'totalharga': totalHarga - diskon,  // Harga setelah diskon
          'pelangganid': _selectedPelanggan?['pelangganid'],
        }).execute();

    if (responsePenjualan.error != null) {
      throw responsePenjualan.error!;
    }

    // Mendapatkan penjualanid yang baru saja dimasukkan
    final penjualanId = responsePenjualan.data[0]['penjualanid'];
    

    // 2. Menambahkan detail transaksi ke tabel `detailpenjualan` untuk setiap produk yang dibeli
    for (var entry in keranjang.entries) {
      var produk = produkList.firstWhere((item) => item['produk_id'] == entry.key);
      int jumlah = entry.value;
      int subtotal = (produk['harga'] as num).toInt() * jumlah;

      // Insert detailpenjualan
      final responseDetailPenjualan = await Supabase.instance.client
          .from('detailpenjualan')
          .upsert({
            'penjualanid': penjualanId,  // Menggunakan penjualanid dari tabel penjualan
            'produkid': produk['produk_id'],
            'jumlahproduk': jumlah,
            'subtotal': subtotal,
          }).execute();

      if (responseDetailPenjualan.error != null) {
        throw responseDetailPenjualan.error!;
      }

      // 3. Mengurangi stok produk setelah pembayaran
      final newStok = produk['stok'] - jumlah;

      final responseUpdateStok = await Supabase.instance.client
          .from('produk')  // Nama tabel produk
          .update({
            'stok': newStok,
          })
          .eq('produk_id', produk['produk_id'])  // Mencari produk berdasarkan produk_id
          .execute();

      if (responseUpdateStok.error != null) {
        throw responseUpdateStok.error!;
      }
    }
    

    // Menampilkan dialog konfirmasi pembayaran berhasil
    _showPembayaranBerhasilDialog(namaPelanggan, tanggal, diskon);
  } catch (e) {
    print('Error during payment confirmation: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran gagal, coba lagi')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Pembayaran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              hint: const Text('Pilih Pelanggan'),
              value: _selectedPelanggan,
              items: _pelangganList.map((pelanggan) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: pelanggan,
                  child: Text(pelanggan['namapelanggan']),
                );
              }).toList(),
              onChanged: (pelanggan) {
                setState(() {
                  _selectedPelanggan = pelanggan;
                });
                hitungTotalHarga();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            if (_produkTidakDitemukan)
              const Center(
                child: Text('Produk tidak ditemukan',
                    style: TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: filteredProdukList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredProdukList.length,
                      itemBuilder: (context, index) {
                        var produk = filteredProdukList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(produk['nama_produk'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      'Rp ${produk['harga'].toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                    Text('Stok: ${produk['stok']}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => kurangiDariKeranjang(
                                          produk['produk_id']),
                                      icon: const Icon(Icons.remove,
                                          color: Colors.red),
                                    ),
                                    Text('${keranjang[produk['produk_id']] ?? 0}'),
                                    IconButton(
                                      onPressed: () => tambahKeKeranjang(
                                          produk['produk_id']),
                                      icon: const Icon(Icons.add,
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Text('Total Belanja: ${formatRupiah(totalHarga)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_selectedPelanggan == null) {
                  // Jika pelanggan belum dipilih, tampilkan pesan peringatan
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pilih Pelanggan'),
                        content: const Text('Silakan pilih pelanggan terlebih dahulu sebelum melanjutkan.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (totalHarga > 0) {
                  // Jika pelanggan sudah dipilih dan total harga > 0, lanjutkan ke detail transaksi
                  _showDetailTransaksi();
                } else {
                  // Jika total harga 0, tampilkan peringatan untuk memilih produk terlebih dahulu
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Tidak Ada Produk'),
                        content: const Text('Silakan pilih produk terlebih dahulu!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Proses Pembayaran', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
