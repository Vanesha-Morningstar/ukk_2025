import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _pelanggan = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPelanggan = [];

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
    _searchController.addListener(_filterPelanggan);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPelanggan() async {
    final response = await _supabase.from('pelanggan').select('*').execute();
    if (response.error == null) {
      setState(() {
        _pelanggan = List<Map<String, dynamic>>.from(response.data);
        _filteredPelanggan = List.from(_pelanggan);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data pelanggan')),
      );
    }
  }

  void _filterPelanggan() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPelanggan = _pelanggan.where((pelanggan) =>
          pelanggan['namapelanggan']!.toLowerCase().contains(query) ||
          pelanggan['nomortelepon']!.contains(query) ||
          (pelanggan['alamat'] != null &&
              pelanggan['alamat']!.toLowerCase().contains(query))).toList();
    });
  }

  Future<void> _deletePelanggan(int pelangganId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      final response = await _supabase
          .from('pelanggan')
          .delete()
          .eq('pelangganid', pelangganId)
          .execute();
      if (response.error == null) {
        _fetchPelanggan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus pelanggan')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _addPelangganDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                _addPelanggan(nameController.text, phoneController.text, addressController.text);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> _addPelanggan(String name, String phone, String address) async {
    final response = await _supabase.from('pelanggan').insert({
      'namapelanggan': name,
      'nomortelepon': phone,
      'alamat': address,
    }).execute();

    if (response.error == null) {
      _fetchPelanggan();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambah pelanggan')),
      );
    }
  }

  Future<void> _editPelangganDialog(Map<String, dynamic> pelanggan) async {
    TextEditingController nameController = TextEditingController(text: pelanggan['namapelanggan']);
    TextEditingController phoneController = TextEditingController(text: pelanggan['nomortelepon']);
    TextEditingController addressController = TextEditingController(text: pelanggan['alamat']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _updatePelanggan(pelanggan['pelangganid'], nameController.text, phoneController.text, addressController.text);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePelanggan(int pelangganId, String name, String phone, String address) async {
    final response = await _supabase.from('pelanggan')
        .update({'namapelanggan': name, 'nomortelepon': phone, 'alamat': address})
        .eq('pelangganid', pelangganId)
        .execute();

    if (response.error == null) {
      _fetchPelanggan();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui pelanggan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Pelanggan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPelanggan.length,
              itemBuilder: (context, index) {
                final pelanggan = _filteredPelanggan[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(pelanggan['namapelanggan'][0])),
                  title: Text(pelanggan['namapelanggan']),
                  subtitle: Text('${pelanggan['nomortelepon']} • ${pelanggan['alamat']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editPelangganDialog(pelanggan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePelanggan(pelanggan['pelangganid']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPelangganDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
