import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';

class BarangService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/barangs';

  Future<List<Barang>> fetchBarangs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Barang.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data barang');
    }
  }
}
