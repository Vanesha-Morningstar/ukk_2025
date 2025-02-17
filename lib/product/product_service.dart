import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // Untuk File

class ProductService {
  final SupabaseClient client = Supabase.instance.client;

  // Fungsi untuk mengambil daftar produk dari Supabase
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await client.from('produk').select().execute();
      
      if (response.error != null) {
        throw response.error!;
      }

      return response.data;
    } catch (e) {
      print('Error fetching products: $e');
      rethrow; // Memastikan error diteruskan jika ada masalah
    }
  }

  // Fungsi untuk mengambil daftar pelanggan dari Supabase
  Future<List<dynamic>> fetchPelanggan() async {
    try {
      final response = await client.from('pelanggan').select().execute();

      if (response.error != null) {
        throw response.error!;
      }

      return response.data;
    } catch (e) {
      print('Error fetching pelanggan: $e');
      rethrow; // Memastikan error diteruskan jika ada masalah
    }
  }

  // Fungsi untuk meng-upload gambar produk ke Supabase Storage dan mendapatkan URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageResponse = await client.storage
          .from('produk-images') // Bucket yang Anda buat di Supabase Storage
          .upload(fileName, imageFile);

      if (storageResponse.error != null) {
        print('Error uploading image: ${storageResponse.error!.message}');
        return null;
      }

      // Mendapatkan URL gambar yang telah di-upload
      final imageUrl = client.storage
          .from('produk-images')
          .getPublicUrl(fileName);

      return imageUrl.data;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  // Fungsi untuk menambahkan produk ke Supabase
  Future<bool> addProduct(String name, double price, int stock, File? imageFile) async {
    String? imageUrl;

    // Jika ada gambar, upload gambar ke Supabase Storage
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) {
        print('Failed to upload image');
        return false;
      }
    }

    try {
      // Menambahkan produk ke Supabase
      final response = await client.from('produk').insert([
        {
          'nama_produk': name,
          'harga': price,
          'stok': stock,
          'gambar': imageUrl, // Menyimpan URL gambar jika ada
        }
      ]).execute();

      if (response.error != null) {
        print('Error adding product: ${response.error!.message}');
        return false; // Jika ada error saat menambah produk
      }

      return true; // Produk berhasil ditambahkan
    } catch (e) {
      print('Error adding product: $e');
      return false; // Mengembalikan false jika ada error
    }
  }

  // Fungsi untuk menghapus produk berdasarkan ID
  Future<bool> deleteProduct(int productId) async {
    try {
      final response = await client.from('produk').delete().eq('produk_id', productId).execute();

      if (response.error != null) {
        print('Error deleting product: ${response.error!.message}');
        return false;
      }

      return true; // Produk berhasil dihapus
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Fungsi untuk mengupdate produk berdasarkan ID
  Future<bool> updateProduct(int productId, String name, double price, int stock, File? imageFile) async {
    String? imageUrl;

    // Jika ada gambar baru, upload gambar
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) {
        print('Failed to upload image');
        return false;
      }
    }

    try {
      // Update produk di Supabase
      final response = await client.from('produk').update({
        'nama_produk': name,
        'harga': price,
        'stok': stock,
        if (imageFile != null) 'gambar': imageUrl, // Update gambar jika ada
      }).eq('produk_id', productId).execute();

      if (response.error != null) {
        print('Error updating product: ${response.error!.message}');
        return false;
      }

      return true; // Produk berhasil diupdate
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }
}
