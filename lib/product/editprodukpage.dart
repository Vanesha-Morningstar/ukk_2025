import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:ukk_2025/product/product_service.dart';
import 'dart:io';

class EditProdukPage extends StatefulWidget {
  final dynamic produk;

  const EditProdukPage({super.key, required this.produk});

  @override
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data produk yang ada
    _nameController.text = widget.produk['nama_produk'];
    _priceController.text = widget.produk['harga'].toString();
    _stockController.text = widget.produk['stok'].toString();
  }

  // Fungsi untuk memilih gambar
  _pickImage() async {
    // Logika untuk memilih gambar (gunakan image_picker atau file picker)
    // Jika berhasil memilih gambar, set gambar ke _imageFile
  }

  // Fungsi untuk menyimpan perubahan produk
  _saveChanges() async {
    final String name = _nameController.text;
    final double? price = double.tryParse(_priceController.text);
    final int? stock = int.tryParse(_stockController.text);

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga dan stok harus berupa angka yang valid')),
      );
      return;
    }

    // Memperbarui produk dengan data baru
    bool success = await _productService.updateProduct(
      widget.produk['produk_id'], // ID produk yang ingin diperbarui
      name,
      price,
      stock,
      _imageFile, // Jika ada gambar baru
    );

    if (success) {
      Navigator.pop(context, {
        'produk_id': widget.produk['produk_id'],
        'nama_produk': name,
        'harga': price,
        'stok': stock,
        'gambar': widget.produk['gambar'], // Jika gambar tidak berubah
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stok'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
