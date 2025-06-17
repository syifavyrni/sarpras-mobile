import 'package:intl/intl.dart';
import 'barang.dart';

class Peminjaman {
  final int id;
  final String peminjam;
  final int barangId;
  final DateTime tglDipinjam;
  final DateTime tglKembali;
  final String status;
  final Barang? barang; // Optional, jika relasi dipakai

  Peminjaman({
    required this.id,
    required this.peminjam,
    required this.barangId,
    required this.tglDipinjam,
    required this.tglKembali,
    required this.status,
    this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      peminjam: json['peminjam'],
      barangId: int.parse(json['barang_id'].toString()),
      tglDipinjam: DateTime.parse(json['tgl_dipinjam']),
      tglKembali: DateTime.parse(json['tgl_kembali']),
      status: json['status'] ?? 'Pending',
      barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'id': id,
      'peminjam': peminjam,
      'barang_id': barangId,
      'tgl_dipinjam': dateFormat.format(tglDipinjam),
      'tgl_kembali': dateFormat.format(tglKembali),
      'status': status,
    };
  }

  // Getter warna status
int get statusColor {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0xFFFB8C00; // Orange terang
    case 'selesai':
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
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
