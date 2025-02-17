import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String priceText; // Menampilkan harga produk
  final int productStock;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Menambahkan fungsi untuk hapus produk
  final VoidCallback onEdit; // Menambahkan fungsi untuk edit produk

  // Parameter yang benar
  const ProductCard({super.key, 
    required this.productName,
    required this.priceText,
    required this.productStock,
    required this.onTap,
    required this.onDelete, // Menambahkan parameter onDelete
    required this.onEdit, // Menambahkan parameter onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.fastfood, size: 50, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceText, // Menampilkan harga dengan format yang benar
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stok: $productStock',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit, // Memanggil fungsi untuk mengedit produk
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete, // Memanggil fungsi untuk menghapus produk
              ),
            ],
          ),
        ),
      ),
    );
  }
}
