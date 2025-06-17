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

  final TextEditingController _namaPeminjamController = TextEditingController();
  final TextEditingController _tglDipinjamController = TextEditingController();
  final TextEditingController _tglKembaliController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarangList();
  }

  Future<void> fetchBarangList() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/barangs'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _barangList = List<Barang>.from(data.map((item) => Barang.fromJson(item)));
      });
    } else {
      print('Gagal memuat barang');
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> submitPeminjaman() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/peminjaman');
    final body = json.encode({
      'peminjam': _namaPeminjamController.text,
      'barang_id': _selectedBarang?.id,
      'tgl_dipinjam': _tglDipinjamController.text,
      'tgl_kembali': _tglKembaliController.text,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil mengirim peminjaman')));
      Navigator.pop(context);
    } else {
      print('Gagal mengirim: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim peminjaman')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form Peminjaman")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaPeminjamController,
                decoration: InputDecoration(labelText: 'Nama Peminjam'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
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
                onChanged: (value) => setState(() => _selectedBarang = value),
                decoration: InputDecoration(labelText: 'Pilih Barang'),
                validator: (value) => value == null ? 'Pilih barang terlebih dahulu' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tglDipinjamController,
                readOnly: true,
                onTap: () => _selectDate(context, _tglDipinjamController),
                decoration: InputDecoration(
                  labelText: 'Tanggal Pinjam',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tglKembaliController,
                readOnly: true,
                onTap: () => _selectDate(context, _tglKembaliController),
                decoration: InputDecoration(
                  labelText: 'Tanggal Kembali',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitPeminjaman();
                  }
                },
                child: Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
