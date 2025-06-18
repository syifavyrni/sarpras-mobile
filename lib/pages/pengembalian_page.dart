import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/peminjaman.dart';
import '../service/pengembalian_service.dart';

class FormPengembalian extends StatefulWidget {
  @override
  _FormPengembalianState createState() => _FormPengembalianState();
}

class _FormPengembalianState extends State<FormPengembalian> {
  final _formKey = GlobalKey<FormState>();
  List<Peminjaman> _peminjamanList = [];
  Peminjaman? _selectedPeminjaman;
  bool _isLoading = false;

  final TextEditingController _tglDikembalikanController =
      TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  String _selectedKondisi = 'baik';

  @override
  void initState() {
    super.initState();
    fetchPeminjamanBelumKembali();
    // Set tanggal hari ini sebagai default
    _tglDikembalikanController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _tglDikembalikanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> fetchPeminjamanBelumKembali() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final peminjamanList =
          await PengembalianService.getPeminjamanBelumKembali();

      setState(() {
        _peminjamanList = peminjamanList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching peminjaman: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat daftar peminjaman: $e')));
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate:
          DateTime.now().add(Duration(days: 30)), // Maksimal 30 hari ke depan
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> submitPengembalian() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await PengembalianService.createPengembalian(
        peminjamanId: _selectedPeminjaman!.id,
        tglDikembalikan: _tglDikembalikanController.text,
        kondisi: _selectedKondisi,
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Show success alert dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Berhasil!'),
                ],
              ),
              content: Text(
                  'Pengembalian berhasil diajukan. Data pengembalian telah tersimpan dan menunggu konfirmasi admin.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).popUntil(
                        (route) => route.isFirst); // Navigate to home page
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error submitting pengembalian: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Pengembalian"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading && _peminjamanList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<Peminjaman>(
                              value: _selectedPeminjaman,
                              items: _peminjamanList.map((peminjaman) {
                                return DropdownMenuItem<Peminjaman>(
                                  value: peminjaman,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${peminjaman.peminjam} - ${peminjaman.barang?.namaBarang ?? 'Unknown'}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Dipinjam: ${DateFormat('dd/MM/yyyy').format(peminjaman.tglDipinjam)}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedPeminjaman = value),
                              decoration: InputDecoration(
                                labelText: 'Pilih Peminjaman',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assignment),
                              ),
                              validator: (value) => value == null
                                  ? 'Pilih peminjaman terlebih dahulu'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _tglDikembalikanController,
                              readOnly: true,
                              onTap: () => _selectDate(
                                  context, _tglDikembalikanController),
                              decoration: InputDecoration(
                                labelText: 'Tanggal Dikembalikan',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal pengembalian wajib diisi';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedKondisi,
                              items: [
                                DropdownMenuItem(
                                    value: 'baik', child: Text('Baik')),
                                DropdownMenuItem(
                                    value: 'rusak', child: Text('Rusak')),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedKondisi = value!),
                              decoration: InputDecoration(
                                labelText: 'Kondisi Barang',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.assessment),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _catatanController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Catatan (Opsional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                                hintText:
                                    'Tambahkan catatan jika diperlukan...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : submitPengembalian,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Mengirim...'),
                                ],
                              )
                            : Text('Kirim Pengembalian',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
