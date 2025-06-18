import 'package:flutter/material.dart';
import 'login_page.dart';
import '../service/auth_service.dart';
import '../widgets/bottom_navbar.dart';
import 'barang_page.dart';
import 'package:sarpras/pages/peminjaman_page.dart';
import 'pengembalian_page.dart';
import 'pengembalian_list_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _authService = AuthService();

  final List<Widget> _pages = [
    BarangPage(),
    FormPeminjaman(),
    FormPengembalian(),
    PengembalianListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Sarpras Mobile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 2,
        shadowColor: Colors.blue.withOpacity(0.3),
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
