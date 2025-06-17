import 'package:flutter/material.dart';
import '../models/barang.dart';

class BarangDetailPage extends StatelessWidget {
  final Barang barang;

  const BarangDetailPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: Colors.indigo[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: barang.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'http://127.0.0.1:8000${barang.imageUrl!}',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.inventory,
                      size: 100,
                      color: Colors.indigo[300],
                    ),
            ),
            const SizedBox(height: 20),

            Text('Nama Barang', style: _labelStyle()),
            Text(barang.namaBarang, style: _valueStyle()),

            const SizedBox(height: 12),
            Text('Kategori ID', style: _labelStyle()),
            Text(barang.kategoriId, style: _valueStyle()),

            const SizedBox(height: 12),
            Text('Stok Barang', style: _labelStyle()),
            Text('${barang.stockBarang}', style: _valueStyle()),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigasi atau aksi peminjaman
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur peminjaman belum diimplementasikan.')),
            );

            // TODO: Arahkan ke halaman form peminjaman / kirim request POST ke API
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.shopping_cart),
          label: const Text(
            'Pinjam Barang',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.indigo,
    );
  }

  TextStyle _valueStyle() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );
  }
}
