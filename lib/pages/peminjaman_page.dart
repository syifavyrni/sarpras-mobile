import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Barang {
  final int id;
  final String namaBarang;

  Barang({required this.id, required this.namaBarang});

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
    );
  }
}

class FormPeminjaman extends StatefulWidget {
  @override
  _FormPeminjamanState createState() => _FormPeminjamanState();
}

class _FormPeminjamanState extends State<FormPeminjaman> {
  final _formKey = GlobalKey<FormState>();
  List<Barang> _barangList = [];
  Barang? _selectedBarang;
  bool _isLoading = false;

  final TextEditingController _namaPeminjamController = TextEditingController();
  final TextEditingController _jumlahPinjamController =
      TextEditingController(text: '1');
  final TextEditingController _tglDipinjamController = TextEditingController();
  final TextEditingController _tglKembaliController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarangList();
  }

  @override
  void dispose() {
    _namaPeminjamController.dispose();
    _jumlahPinjamController.dispose();
    _tglDipinjamController.dispose();
    _tglKembaliController.dispose();
    super.dispose();
  }

  Future<void> fetchBarangList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/barangs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Fetch Barang Status: ${response.statusCode}');
      print('Fetch Barang Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response structures
        List<dynamic> barangData;
        if (data is Map && data.containsKey('data')) {
          barangData = data['data'];
        } else if (data is List) {
          barangData = data;
        } else {
          throw Exception('Unexpected response format');
        }

        setState(() {
          _barangList = List<Barang>.from(
              barangData.map((item) => Barang.fromJson(item)));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load barang: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching barang: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat daftar barang: $e')));
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/peminjaman');
      final requestBody = {
        'peminjam': _namaPeminjamController.text.trim(),
        'barang_id': _selectedBarang!.id,
        'jumlah_pinjam': int.parse(_jumlahPinjamController.text),
        'tgl_dipinjam': _tglDipinjamController.text,
        'tgl_kembali': _tglKembaliController.text,
      };

      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          // Show success alert dialog
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
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
                    'Peminjaman berhasil diajukan. Data peminjaman telah tersimpan.'),
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
      } else {
        // Try to parse error message from response
        String errorMessage = 'Gagal mengirim peminjaman';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage += ' (${response.statusCode})';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error submitting peminjaman: $e');
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
        title: Text("Form Peminjaman"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading && _barangList.isEmpty
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
                            TextFormField(
                              controller: _namaPeminjamController,
                              decoration: InputDecoration(
                                labelText: 'Nama Peminjam',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama peminjam wajib diisi';
                                }
                                if (value.trim().length < 2) {
                                  return 'Nama peminjam minimal 2 karakter';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<Barang>(
                              value: _selectedBarang,
                              items: _barangList.map((barang) {
                                return DropdownMenuItem<Barang>(
                                  value: barang,
                                  child: Text(barang.namaBarang),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedBarang = value),
                              decoration: InputDecoration(
                                labelText: 'Pilih Barang',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory),
                              ),
                              validator: (value) => value == null
                                  ? 'Pilih barang terlebih dahulu'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _jumlahPinjamController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Jumlah Pinjam',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.numbers),
                                suffixText: 'unit',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Jumlah pinjam wajib diisi';
                                }
                                final int? jumlah = int.tryParse(value.trim());
                                if (jumlah == null) {
                                  return 'Jumlah pinjam harus berupa angka';
                                }
                                if (jumlah <= 0) {
                                  return 'Jumlah pinjam harus lebih dari 0';
                                }
                                if (jumlah > 999) {
                                  return 'Jumlah pinjam maksimal 999';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _tglDipinjamController,
                              readOnly: true,
                              onTap: () =>
                                  _selectDate(context, _tglDipinjamController),
                              decoration: InputDecoration(
                                labelText: 'Tanggal Pinjam',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal pinjam wajib diisi';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _tglKembaliController,
                              readOnly: true,
                              onTap: () =>
                                  _selectDate(context, _tglKembaliController),
                              decoration: InputDecoration(
                                labelText: 'Tanggal Kembali',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal kembali wajib diisi';
                                }

                                // Validate that return date is after borrow date
                                if (_tglDipinjamController.text.isNotEmpty) {
                                  DateTime? borrowDate = DateTime.tryParse(
                                      _tglDipinjamController.text);
                                  DateTime? returnDate =
                                      DateTime.tryParse(value);

                                  if (borrowDate != null &&
                                      returnDate != null) {
                                    if (returnDate.isBefore(borrowDate) ||
                                        returnDate
                                            .isAtSameMomentAs(borrowDate)) {
                                      return 'Tanggal kembali harus setelah tanggal pinjam';
                                    }
                                  }
                                }
                                return null;
                              },
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
                        onPressed: _isLoading ? null : submitPeminjaman,
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
                            : Text('Kirim Peminjaman',
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
