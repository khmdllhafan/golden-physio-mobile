import 'package:flutter/material.dart';
import 'jadwal_fisioterapi_page.dart';
import 'pemesanan_fisioterapi_page.dart';
import 'riwayat_terapi.dart';
import 'profil_saya_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return HomePasienPage(username: username);
  }
}

class HomePasienPage extends StatefulWidget {
  final String username;
  final int initialIndex;

  const HomePasienPage({
    super.key,
    required this.username,
    this.initialIndex = 0,
  });

  @override
  State<HomePasienPage> createState() => _HomePasienPageState();
}

class _HomePasienPageState extends State<HomePasienPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) {
      return 'Selamat Pagi';
    } else if (hour >= 10 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    String namaUser = widget.username;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A8E8), Color(0xFF006699)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.healing, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'GOLDEN PHYSIO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: Drawer(
        child: Container(
          color: const Color(0xFFE2F1F8),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFF00A8E8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GOLDEN PHYSIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pekalongan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.home,
                      text: 'Home',
                      index: 0,
                      destination: HomePasienPage(
                        username: widget.username,
                        initialIndex: 0,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_today,
                      text: 'Jadwal Fisioterapi',
                      index: 1,
                      destination: JadwalFisioterapiPage(
                        username: widget.username,
                        initialIndex: 1,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.bookmark_add,
                      text: 'Pemesanan Fisioterapi',
                      index: 2,
                      destination: PemesananFisioterapiPage(
                        username: widget.username,
                        initialIndex: 2,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.history,
                      text: 'Riwayat Terapi',
                      index: 3,
                      destination: RiwayatTerapiPage(
                        username: widget.username,
                        initialIndex: 3,
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      text: 'Profil Saya',
                      index: 4,
                      destination: ProfilSayaPage(
                        username: widget.username,
                        initialIndex: 4,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const LoginPage(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A8E8), Color(0xFF006699)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, $namaUser!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selamat Datang di Golden Physio Pekalongan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Terima kasih telah mempercayakan kesehatan Anda kepada kami. Golden Physio hadir sebagai solusi terpercaya untuk layanan fisioterapi yang nyaman, aman, dan profesional. Kami siap mendampingi Anda dalam setiap langkah pemulihan dan perawatan tubuh.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sehat itu prioritas. Mulailah bersama Golden Physio Pekalongan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildStatCard(
              icon: Icons.calendar_month,
              title: 'Pesan Terapi',
              description:
                  'Atur jadwal kunjungan fisioterapi Anda dengan mudah.',
              actionText: 'Buat Janji →',
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            PemesananFisioterapiPage(username: widget.username),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildStatCard(
              icon: Icons.history,
              title: 'Riwayat',
              description:
                  'Lihat catatan perkembangan terapi yang telah dilakukan.',
              actionText: 'Lihat Detail →',
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            RiwayatTerapiPage(username: widget.username),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildStatCard(
              icon: Icons.person_outline,
              title: 'Profil Saya',
              description: 'Perbarui informasi kontak dan keamanan akun Anda.',
              actionText: 'Kelola Akun →',
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            ProfilSayaPage(username: widget.username),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB3E5FC)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: Color(0xFF00bfff)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tips Hari Ini: Jangan lupa melakukan peregangan ringan setiap 2 jam saat bekerja untuk menjaga kelenturan otot.',
                      style: TextStyle(color: Color(0xFF00bfff), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
    required Widget destination,
  }) {
    bool isSelected = _selectedIndex == index;
    return Container(
      color: isSelected ? const Color(0xFF00A8E8) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.blueGrey),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); 

          if (!isSelected) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => destination,
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00bfff), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFF00bfff),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
