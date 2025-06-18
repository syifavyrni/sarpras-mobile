import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pengembalian.dart';
import '../service/pengembalian_service.dart';

class PengembalianListPage extends StatefulWidget {
  @override
  _PengembalianListPageState createState() => _PengembalianListPageState();
}

class _PengembalianListPageState extends State<PengembalianListPage> {
  List<Pengembalian> _pengembalianList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPengembalianList();
  }

  Future<void> fetchPengembalianList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pengembalianList = await PengembalianService.getAllPengembalian();

      setState(() {
        _pengembalianList = pengembalianList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching pengembalian: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat daftar pengembalian: $e')));
      }
    }
  }

  Future<void> _refreshData() async {
    await fetchPengembalianList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Pengembalian"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pengembalianList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_return,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada data pengembalian',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _pengembalianList.length,
                    itemBuilder: (context, index) {
                      final pengembalian = _pengembalianList[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pengembalian.peminjaman?.peminjam ??
                                          'Unknown',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(pengembalian.statusColor),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      pengembalian.statusText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.inventory,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pengembalian
                                              .peminjaman?.barang?.namaBarang ??
                                          'Unknown',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.date_range,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Dikembalikan: ${DateFormat('dd/MM/yyyy').format(pengembalian.tglDikembalikan)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.assessment,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kondisi: ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(pengembalian.kondisiColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      pengembalian.kondisiText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (pengembalian.catatan != null &&
                                  pengembalian.catatan!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Catatan:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        pengembalian.catatan!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (pengembalian.peminjaman != null) ...[
                                SizedBox(height: 8),
                                Divider(),
                                Text(
                                  'Detail Peminjaman:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Dipinjam: ${DateFormat('dd/MM/yyyy').format(pengembalian.peminjaman!.tglDipinjam)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Target: ${DateFormat('dd/MM/yyyy').format(pengembalian.peminjaman!.tglKembali)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Jumlah: ${pengembalian.peminjaman!.jumlahPinjam} unit',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
