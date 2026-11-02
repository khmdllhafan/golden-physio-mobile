import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lokasi_map_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<dynamic> _jadwalHariIni = [];
  bool _isLoading = true;

  final List<String> _sliderImages = [
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpg',
    'assets/images/6.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchJadwalFromTermux();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _sliderImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _fetchJadwalFromTermux() async {
    setState(() {
      _isLoading = true;
    });

    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final String url =
        'http://localhost/golden_api/get_jadwal.php?tanggal=$todayStr';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['status'] == 'success') {
            _jadwalHariIni = data['data'] ?? [];
          } else {
            _jadwalHariIni = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _jadwalHariIni = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _jadwalHariIni = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00bfff), Color(0xFF0083b0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.medical_services, color: Colors.white),
            ),
            const SizedBox(width: 6),
            const Text(
              'GOLDEN PHYSIO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
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
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            },
            child: const Text(
              'LOGIN/DAFTAR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF80D4FF),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    'Selamat Datang di\nGolden Physio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Layanan Profesional untuk Kesehatan & Mobilitas Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _sliderImages.length,
                            itemBuilder: (context, index) {
                              return Image.asset(
                                _sliderImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 50),
                                    ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (_currentPage > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (_currentPage < _sliderImages.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'JADWAL PEMESANAN HARI INI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wonopringgo, Kab. Pekalongan',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Jam Operasional: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Senin - Jumat (09:00 - 21:00) | Sabtu & Minggu Libur',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Golden Physio Saat Ini: Libur',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                      : _buildJadwalTable(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'CARA MELAKUKAN PEMESANAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00008B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPanduanItem(
                    1,
                    'Login ke akun Anda. Jika belum punya, silakan mendaftar terlebih dahulu.',
                  ),
                  _buildPanduanItem(2, 'Klik sidebar pemesanan fisioterapi.'),
                  _buildPanduanItem(
                    3,
                    'Mengisi form pemesanan, lalu klik tombol kirim pemesanan.',
                  ),
                  _buildPanduanItem(
                    4,
                    'Menunggu konfirmasi, bisa dicek di halaman jadwal fisioterapi.',
                  ),
                  _buildPanduanItem(
                    5,
                    'Setelah pemesanan disetujui, masuk ke ruangan terapis sesuai jam yang dipilih.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TENTANG KAMI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Golden Physio adalah pusat layanan fisioterapi terpercaya yang berlokasi di Kecamatan Wonopringgo, Kabupaten Pekalongan. Kami berdedikasi untuk memberikan layanan kesehatan profesional bagi Anda yang membutuhkan pemulihan mobilitas dan peningkatan kualitas hidup.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Visi Kami',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '"Menjadi pusat fisioterapi unggulan yang mengedepankan kualitas pelayanan dan kepuasan pasien."',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Misi Kami',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildBulletText(
                    'Memberikan layanan fisioterapi berbasis bukti (evidence-based).',
                  ),
                  _buildBulletText(
                    'Menyediakan lingkungan terapi yang nyaman dan ramah.',
                  ),
                  _buildBulletText(
                    'Meningkatkan edukasi kesehatan kepada masyarakat.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              color: Colors.blueGrey[900],
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    'HUBUNGI KAMI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Punya pertanyaan? Silakan hubungi kami melalui saluran berikut:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildFooterContactItem(
                    Icons.location_on,
                    'Alamat',
                    'Wonopringgo, Kab. Pekalongan',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LokasiMapPage(),
                        ),
                      );
                    },
                  ),
                  _buildFooterContactItem(
                    Icons.phone,
                    'WhatsApp',
                    '085327793811',
                    () => _launchURL('https://wa.me/6285327793811'),
                  ),
                  _buildFooterContactItem(
                    Icons.camera_alt,
                    'Instagram',
                    '@goldenphysio',
                    () => _launchURL(
                      'https://instagram.com/golden.physiopekalongan',
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  const Text(
                    '© 2026 Golden Physio. Semua Hak Dilindungi.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalTable() {
    if (_jadwalHariIni.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Belum ada data pemesanan hari ini.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
        columns: const [
          DataColumn(
            label: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Pasien',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Terapis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Jam', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: List.generate(_jadwalHariIni.length, (index) {
          final data = _jadwalHariIni[index];
          String status =
              (data['status'] ?? 'Pending').toString().toLowerCase();

          Color bgColor;
          Color textColor;

          if (status == 'disetujui' || status == 'selesai') {
            bgColor = const Color(0xFFE8F5E9);
            textColor = const Color.fromARGB(255, 0, 255, 0);
          } else if (status == 'pending') {
            bgColor = const Color(0xFFFFF3E0);
            textColor = Colors.orange;
          } else if (status == 'ditolak' || status == 'dibatalkan') {
            bgColor = Colors.red;
            textColor = Colors.pink;
          } else if (status == 'diproses') {
            bgColor = const Color(0xFFE8F3F5);
            textColor = Colors.blue;
          } else {
            bgColor = Colors.grey.shade200;
            textColor = Colors.black87;
          }

          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(data['nama'] ?? '-')),
              DataCell(
                Text(
                  data['nama_terapis'] ?? data['id_terapis']?.toString() ?? '-',
                ),
              ),
              DataCell(Text(data['tanggal_terapi'] ?? '-')),
              DataCell(Text(data['jam_terapi'] ?? '-')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data['status'] ?? 'Pending',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPanduanItem(int nomor, String deskripsi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF0088CC),
            child: Text(
              '$nomor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deskripsi,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka $urlString');
    }
  }

  Widget _buildFooterContactItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              '$title: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
