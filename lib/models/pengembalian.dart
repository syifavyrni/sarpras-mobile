import 'package:intl/intl.dart';
import 'peminjaman.dart';

class Pengembalian {
  final int id;
  final int peminjamanId;
  final DateTime tglDikembalikan;
  final String kondisi;
  final String? catatan;
  final String status;
  final Peminjaman? peminjaman;

  Pengembalian({
    required this.id,
    required this.peminjamanId,
    required this.tglDikembalikan,
    required this.kondisi,
    this.catatan,
    required this.status,
    this.peminjaman,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      peminjamanId: int.parse(json['peminjaman_id'].toString()),
      tglDikembalikan: DateTime.parse(json['tgl_dikembalikan']),
      kondisi: json['kondisi'] ?? 'baik',
      catatan: json['catatan'],
      status: json['status'] ?? 'Pending',
      peminjaman: json['peminjaman'] != null
          ? Peminjaman.fromJson(json['peminjaman'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'id': id,
      'peminjaman_id': peminjamanId,
      'tgl_dikembalikan': dateFormat.format(tglDikembalikan),
      'kondisi': kondisi,
      'catatan': catatan,
      'status': status,
    };
  }

  // Getter warna status
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0xFFFB8C00; // Orange terang
      case 'diterima':
        return 0xFF2E7D32; // Hijau gelap
      case 'ditolak':
        return 0xFFC62828; // Merah gelap
      default:
        return 0xFF757575; // Abu-abu
    }
  }

  // Getter teks status yang ramah pengguna
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Getter warna kondisi
  int get kondisiColor {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return 0xFF2E7D32; // Hijau gelap
      case 'rusak':
        return 0xFFC62828; // Merah gelap
      default:
        return 0xFF757575; // Abu-abu
    }
  }

  // Getter teks kondisi yang ramah pengguna
  String get kondisiText {
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return 'Baik';
      case 'rusak':
        return 'Rusak';
      default:
        return kondisi;
    }
  }
}
