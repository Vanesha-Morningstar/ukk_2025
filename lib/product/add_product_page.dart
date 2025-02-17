import 'package:flutter/material.dart';
import 'package:ukk_2025/product/product_service.dart';
import 'package:flutter/services.dart';  // Untuk TextInputFormatter

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  String? _productName;
  double? _price;
  int? _stock;

  // Fungsi untuk menambah produk
  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final success = await _productService.addProduct(
        _productName!,
        _price!,
        _stock!,
        null,  // Tidak ada gambar yang dikirim
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        Navigator.pop(context, true); // Kembali ke halaman produk dengan status true
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan produk')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Masukkan Nama Produk',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Harga (Angka saja)',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Membatasi hanya angka
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Stok (Angka saja)',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Membatasi hanya angka
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Masukkan stok yang valid';
                  }
                  return null;
                },
                onSaved: (value) {
                  _stock = int.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('Tambah Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
