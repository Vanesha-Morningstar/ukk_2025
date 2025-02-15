import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String priceText; // Menampilkan harga produk
  final int productStock;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Menambahkan fungsi untuk hapus produk
  final VoidCallback onEdit; // Menambahkan fungsi untuk edit produk

  // Parameter yang benar
  ProductCard({
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
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.fastfood, size: 50, color: Colors.blueAccent),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    priceText, // Menampilkan harga dengan format yang benar
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Stok: $productStock',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit, // Memanggil fungsi untuk mengedit produk
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete, // Memanggil fungsi untuk menghapus produk
              ),
            ],
          ),
        ),
      ),
    );
  }
}
