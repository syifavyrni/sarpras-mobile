import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengembalian.dart';
import '../models/peminjaman.dart';

class PengembalianService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Get all pengembalian
  static Future<List<Pengembalian>> getAllPengembalian() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengembalian'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> pengembalianData;
        if (data is Map && data.containsKey('data')) {
          pengembalianData = data['data'];
        } else if (data is List) {
          pengembalianData = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return List<Pengembalian>.from(
            pengembalianData.map((item) => Pengembalian.fromJson(item)));
      } else {
        throw Exception('Failed to load pengembalian: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pengembalian: $e');
    }
  }

  // Get pengembalian by ID
  static Future<Pengembalian> getPengembalianById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengembalian/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Map<String, dynamic> pengembalianData;
        if (data is Map && data.containsKey('data')) {
          pengembalianData = Map<String, dynamic>.from(data['data']);
        } else if (data is Map) {
          pengembalianData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return Pengembalian.fromJson(pengembalianData);
      } else {
        throw Exception('Failed to load pengembalian: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pengembalian: $e');
    }
  }

  // Create new pengembalian
  static Future<Pengembalian> createPengembalian({
    required int peminjamanId,
    required String tglDikembalikan,
    required String kondisi,
    String? catatan,
  }) async {
    try {
      final requestBody = {
        'peminjaman_id': peminjamanId,
        'tgl_dikembalikan': tglDikembalikan,
        'kondisi': kondisi,
        'catatan': catatan,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/pengembalian'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        Map<String, dynamic> pengembalianData;
        if (data is Map && data.containsKey('data')) {
          pengembalianData = Map<String, dynamic>.from(data['data']);
        } else if (data is Map) {
          pengembalianData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return Pengembalian.fromJson(pengembalianData);
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to create pengembalian';

        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is Map && errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error creating pengembalian: $e');
    }
  }

  // Get peminjaman yang siap dikembalikan (untuk dropdown)
  static Future<List<Peminjaman>> getPeminjamanBelumKembali() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman/siap-kembali'),
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

  // Update pengembalian status (untuk admin)
  static Future<Pengembalian> updatePengembalianStatus({
    required int id,
    required String status,
  }) async {
    try {
      final requestBody = {
        'status': status,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/pengembalian/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Map<String, dynamic> pengembalianData;
        if (data is Map && data.containsKey('data')) {
          pengembalianData = Map<String, dynamic>.from(data['data']);
        } else if (data is Map) {
          pengembalianData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Unexpected response format');
        }

        return Pengembalian.fromJson(pengembalianData);
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to update pengembalian status';

        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is Map && errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error updating pengembalian status: $e');
    }
  }
}
