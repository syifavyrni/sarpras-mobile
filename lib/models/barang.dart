class Barang {
  final int id;
  final String? imageUrl;
  final String namaBarang;
  final String kategoriId;
  final int stockBarang;

  Barang({
    required this.id,
    this.imageUrl,
    required this.namaBarang,
    required this.kategoriId,
    required this.stockBarang,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      imageUrl: json['image_url'],
      namaBarang: json['nama_barang'],
      kategoriId: json['kategori_id'],
      stockBarang: json['stock_barang'],
    );
  }
}
