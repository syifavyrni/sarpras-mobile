import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman.dart';

class PeminjamanService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Get all peminjaman
  static Future<List<Peminjaman>> getAllPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> peminjamanData;
        if (data is Map && data.containsKey('data')) {
          peminjamanData = data['data'];
        } else if (data is List) {
          peminjamanData = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return List<Peminjaman>.from(
            peminjamanData.map((item) => Peminjaman.fromJson(item)));
      } else {
        throw Exception('Failed to load peminjaman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching peminjaman: $e');
    }
  }

  // Get peminjaman by ID
  static Future<Peminjaman> getPeminjamanById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Map<String, dynamic> peminjamanData;
        if (data is Map && data.containsKey('data')) {
          peminjamanData = Map<String, dynamic>.from(data['data']);
        } else if (data is Map) {
          peminjamanData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return Peminjaman.fromJson(peminjamanData);
      } else {
        throw Exception('Failed to load peminjaman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching peminjaman: $e');
    }
  }

  // Create new peminjaman
  static Future<Peminjaman> createPeminjaman({
    required String peminjam,
    required int barangId,
    required int jumlahPinjam,
    required String tglDipinjam,
    required String tglKembali,
  }) async {
    try {
      final requestBody = {
        'peminjam': peminjam,
        'barang_id': barangId,
        'jumlah_pinjam': jumlahPinjam,
        'tgl_dipinjam': tglDipinjam,
        'tgl_kembali': tglKembali,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/peminjaman'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        Map<String, dynamic> peminjamanData;
        if (data is Map && data.containsKey('data')) {
          peminjamanData = Map<String, dynamic>.from(data['data']);
        } else if (data is Map) {
          peminjamanData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return Peminjaman.fromJson(peminjamanData);
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to create peminjaman';

        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is Map && errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating peminjaman: $e');
    }
  }

  // Get peminjaman yang belum dikembalikan
  static Future<List<Peminjaman>> getPeminjamanBelumKembali() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman/belum-kembali'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> peminjamanData;
        if (data is Map && data.containsKey('data')) {
          peminjamanData = data['data'];
        } else if (data is List) {
          peminjamanData = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return List<Peminjaman>.from(
            peminjamanData.map((item) => Peminjaman.fromJson(item)));
      } else {
        throw Exception('Failed to load peminjaman: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching peminjaman: $e');
    }
  }
}
