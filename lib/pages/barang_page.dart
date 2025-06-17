import 'package:flutter/material.dart';
import '../models/barang.dart';
import '../service/barang_service.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  final BarangService _barangService = BarangService();
  late Future<List<Barang>> _barangFuture;

  @override
  void initState() {
    super.initState();
    _barangFuture = _barangService.fetchBarangs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Barang',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada barang ditemukan.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          final barangs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: barangs.length,
            itemBuilder: (context, index) {
              final barang = barangs[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: barang.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage('http://127.0.0.1:8000${barang.imageUrl!}'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: barang.imageUrl == null
                        ? Icon(
                            Icons.inventory,
                            size: 30,
                            color: Colors.indigo[400],
                          )
                        : null,
                  ),
                  title: Text(
                    barang.namaBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Kategori: ${barang.kategoriId}'),
                      Text('Stok: ${barang.stockBarang}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    // Tambahkan navigasi ke detail jika perlu
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
