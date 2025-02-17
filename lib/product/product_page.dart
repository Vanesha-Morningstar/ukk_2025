import 'package:flutter/material.dart';
import 'package:ukk_2025/product/product_service.dart'; // Service produk
import 'package:ukk_2025/product/product_card.dart'; // Tampilan kartu produk
import 'package:ukk_2025/product/editprodukpage.dart'; // Halaman edit produk
import 'package:ukk_2025/product/add_product_page.dart'; // Halaman tambah produk

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<dynamic> produkList = [];
  List<dynamic> filteredProduk = [];
  final ProductService _productService = ProductService();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  // Mengambil data produk dari server
  _loadProduk() async {
    try {
      var produkData = await _productService.fetchProducts();
      setState(() {
        produkList = produkData;
        filteredProduk = produkData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal mengambil data produk')));
    }
  }

  // Fungsi pencarian produk
  void _searchProduk(String query) {
    List<dynamic> hasilPencarian = produkList
        .where((produk) => produk['nama_produk']
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredProduk = hasilPencarian;
    });
  }

  // Konfirmasi sebelum menghapus produk
  void _confirmDelete(int productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduct(productId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus produk
  _deleteProduct(int productId) async {
    bool success = await _productService.deleteProduct(productId);
    if (success) {
      setState(() {
        produkList.removeWhere((item) => item['produk_id'] == productId);
        filteredProduk.removeWhere((item) => item['produk_id'] == productId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal menghapus produk')));
    }
  }

  // Fungsi untuk mengedit produk
  _editProduct(dynamic produk) async {
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProdukPage(produk: produk),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        final index = produkList
            .indexWhere((item) => item['produk_id'] == updatedProduct['produk_id']);
        if (index != -1) {
          produkList[index] = updatedProduct;
          _searchProduk(searchController.text);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductPage(),
                ),
              );

              if (result != null && result == true) {
                _loadProduk();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Kotak Pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchProduk,
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Daftar Produk
          Expanded(
            child: filteredProduk.isEmpty
                ? const Center(child: Text("Produk tidak ditemukan"))
                : ListView.builder(
                    itemCount: filteredProduk.length,
                    itemBuilder: (context, index) {
                      var produk = filteredProduk[index];
                      return ProductCard(
                        productName: produk['nama_produk'],
                        priceText: 'Rp ${produk['harga'].toStringAsFixed(0)}',
                        productStock: produk['stok'],
                        onTap: () {
                          // Bisa ditambahkan aksi untuk menampilkan detail
                        },
                        onDelete: () => _confirmDelete(produk['produk_id']), // Panggil konfirmasi hapus
                        onEdit: () => _editProduct(produk),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
