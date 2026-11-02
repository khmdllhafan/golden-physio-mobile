import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'pemesanan_fisioterapi_page.dart';
import 'riwayat_terapi.dart';
import 'profil_saya_page.dart';
import 'login_page.dart';

class JadwalFisioterapiPage extends StatefulWidget {
  final String username;
  final int initialIndex;

  const JadwalFisioterapiPage({
    super.key,
    required this.username,
    this.initialIndex = 1,
  });

  @override
  State<JadwalFisioterapiPage> createState() => _JadwalFisioterapiPageState();
}

class _JadwalFisioterapiPageState extends State<JadwalFisioterapiPage> {
  late int _selectedIndex;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _jadwalList = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    setState(() {
      _isLoading = true;
    });

    String formattedDateForApi = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final String url =
        'http://localhost/golden_api/get_jadwal.php?username=${widget.username}&tanggal=$formattedDateForApi';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['status'] == 'success') {
            _jadwalList = data['data'] ?? [];
          } else {
            _jadwalList = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _jadwalList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _jadwalList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTitleDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
    String formattedInputDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
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
              height: 32,
              width: 32,
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'JADWAL TERAPI : $formattedTitleDate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ),

              Container(
                color: const Color(0xFFF0F6FA),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  formattedInputDate,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        ElevatedButton(
                          onPressed: _fetchJadwal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A8E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Filter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _isLoading
                  ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _jadwalList.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40.0,
                      horizontal: 16.0,
                    ),
                    child: Center(
                      child: Text(
                        'Tidak ada jadwal terapi untuk tanggal ini.',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF0F6FA),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'No',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Pasien',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Terapis',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Jam',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Tanggal Terapi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows:
                          _jadwalList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var row = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(row['nama'] ?? '-')),
                                DataCell(Text(row['nama_terapis'] ?? '-')),
                                DataCell(
                                  Text(
                                    '${row['jam_terapi']?.toString().substring(0, 5) ?? '-'} WIB',
                                  ),
                                ),
                                DataCell(Text(row['tanggal_terapi'] ?? '-')),
                                DataCell(
                                  _buildStatusBadge(row['status'] ?? '-'),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
            ],
          ),
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

  Widget _buildStatusBadge(String status) {
    String statusLower = status.toLowerCase();
    Color bgColor;
    Color textColor;

    if (statusLower == 'disetujui' || statusLower == 'selesai') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color.fromARGB(255, 0, 255, 0);
    } else if (statusLower == 'pending') {
      bgColor = const Color(0xFFFFF3E0);
      textColor = Colors.orange;
    } else if (statusLower == 'ditolak' || statusLower == 'dibatalkan') {
      bgColor = Colors.red;
      textColor = Colors.pink;
    } else if (statusLower == 'diproses') {
      bgColor = const Color(0xFFE8F3F5);
      textColor = Colors.blue;
    } else {
      bgColor = Colors.grey.shade200;
      textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
