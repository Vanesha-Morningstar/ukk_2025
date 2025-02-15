import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _transaksiList = [];
  List<Map<String, dynamic>> _detailTransaksiList = [];

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  // Fungsi untuk memuat transaksi dari tabel 'penjualan'
  Future<void> _loadTransaksi() async {
    try {
      final response = await _client
          .from('penjualan')
          .select('*')
          .order('tanggal_penjualan', ascending: false)
          .execute();

      if (response.error != null) {
        throw response.error!;
      }

      setState(() {
        _transaksiList = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      print('Error loading transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data transaksi')),
      );
    }
  }

  // Fungsi untuk memuat detail transaksi berdasarkan penjualanid
  Future<void> _loadDetailTransaksi(int penjualanId) async {
    try {
      final response = await _client
          .from('detailpenjualan')
          .select('jumlahproduk, subtotal, produk(nama_produk)')
          .eq('penjualanid', penjualanId)
          .execute();

      if (response.error != null) {
        throw response.error!;
      }

      setState(() {
        _detailTransaksiList = List<Map<String, dynamic>>.from(response.data);
      });

      _showDetailDialog(penjualanId);
    } catch (e) {
      print('Error loading detail transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil detail transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _transaksiList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _transaksiList.length,
                      itemBuilder: (context, index) {
                        var transaksi = _transaksiList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Transaksi #${transaksi['penjualanid']}'),
                            subtitle: Text('Tanggal: ${transaksi['tanggal_penjualan']}'),
                            trailing: Text('Total: Rp ${transaksi['totalharga']}'),
                            onTap: () => _loadDetailTransaksi(transaksi['penjualanid']),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Menampilkan dialog detail transaksi
  void _showDetailDialog(int penjualanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Transaksi #$penjualanId'),
          content: _detailTransaksiList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _detailTransaksiList.map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${detail['produk']['nama_produk']} x${detail['jumlahproduk']}'),
                            Text('Subtotal: Rp ${detail['subtotal']}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
