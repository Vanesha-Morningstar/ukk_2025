import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<dynamic>> fetchProducts() async {
    final response = await client
        .from('produk') // Nama tabel di Supabase Anda
        .select()
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return response.data;
  }
}
