import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'jadwal_fisioterapi_page.dart';
import 'pemesanan_fisioterapi_page.dart';
import 'profil_saya_page.dart';
import 'login_page.dart';

class RiwayatTerapiPage extends StatefulWidget {
  final String username;
  final int initialIndex;

  const RiwayatTerapiPage({
    super.key,
    required this.username,
    this.initialIndex = 3,
  });

  @override
  State<RiwayatTerapiPage> createState() => _RiwayatTerapiPageState();
}

class _RiwayatTerapiPageState extends State<RiwayatTerapiPage> {
  DateTime? _selectedDate;
  String? _selectedBulan;
  final TextEditingController _tahunController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  String _sortOrder = 'DESC';

  bool _isLoading = false;
  List<dynamic> _riwayatList = [];

  late int _selectedIndex;

  final Map<String, String> _namaBulan = {
    '1': 'Jan',
    '2': 'Feb',
    '3': 'Mar',
    '4': 'Apr',
    '5': 'Mei',
    '6': 'Jun',
    '7': 'Jul',
    '8': 'Agu',
    '9': 'Sep',
    '10': 'Okt',
    '11': 'Nov',
    '12': 'Des',
  };

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _fetchRiwayat();
  }

  @override
  void dispose() {
    _tahunController.dispose();
    super.dispose();
  }

  Future<void> _fetchRiwayat() async {
    setState(() {
      _isLoading = true;
    });

    String tanggalParam =
        _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : '';
    String bulanParam = _selectedBulan ?? '';
    String tahunParam = _tahunController.text.trim();

    String usernamePasien = widget.username;

    final String url =
        'http://localhost/golden_api/get_riwayat.php?username=$usernamePasien&tanggal=$tanggalParam&bulan=$bulanParam&tahun=$tahunParam&sort=$_sortOrder';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['status'] == 'success') {
            _riwayatList = data['data'] ?? [];
          } else {
            _riwayatList = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _riwayatList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _riwayatList = [];
        _isLoading = false;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedDate = null;
      _selectedBulan = null;
      _tahunController.text = '';
      _sortOrder = 'DESC';
    });
    _fetchRiwayat();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          transitionDuration: const Duration(
                            milliseconds: 600,
                          ),
                        ),
                        (route) =>
                            false,
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'RIWAYAT TERAPI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ),

              Container(
                color: const Color(0xFFF0F6FA),
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDate == null
                                        ? 'dd/mm/yyyy'
                                        : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_selectedDate!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          _selectedDate == null
                                              ? Colors.grey.shade500
                                              : Colors.black,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bulan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedBulan,
                                hint: const Text(
                                  'Semua',
                                  style: TextStyle(fontSize: 13),
                                ),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Semua',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ..._namaBulan.entries.map((e) {
                                    return DropdownMenuItem<String>(
                                      value: e.key,
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBulan = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tahun:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _tahunController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Urutkan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortOrder,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'DESC',
                                    child: Text(
                                      'Terbaru ke Terlama',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ASC',
                                    child: Text(
                                      'Terlama ke Terbaru',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _sortOrder = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _fetchRiwayat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00bfff),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Filter'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _resetFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Reset'),
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
                  : _riwayatList.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40.0,
                      horizontal: 16.0,
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada data riwayat untuk pasien ini.',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
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
                                  'Tanggal Terapi',
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
                                  'Terapis',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Keluhan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Riwayat Cedera',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Catatan',
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
                                _riwayatList.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var row = entry.value;

                                  String tglFormatted =
                                      row['tanggal_terapi'] != null
                                          ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse(
                                              row['tanggal_terapi'],
                                            ),
                                          )
                                          : '-';

                                  String jamFormatted =
                                      row['jam_terapi'] != null
                                          ? '${row['jam_terapi'].toString().substring(0, 5)} WIB'
                                          : '-';

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(
                                        Text(
                                          tglFormatted,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(jamFormatted)),
                                      DataCell(
                                        Text(row['nama_terapis'] ?? '-'),
                                      ),
                                      DataCell(Text(row['keluhan'] ?? '-')),
                                      DataCell(
                                        Text(row['riwayat_cedera'] ?? '-'),
                                      ),
                                      DataCell(Text(row['catatan'] ?? '-')),
                                      DataCell(
                                        _buildStatusBadge(row['status'] ?? '-'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      );
                    },
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
                transitionDuration: const Duration(
                  milliseconds: 600,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String s = status.toLowerCase();
    Color bgColor;
    Color textColor;

    if (s == 'disetujui' || s == 'selesai') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color.fromARGB(255, 0, 255, 0);
    } else if (s == 'pending') {
      bgColor = const Color(0xFFFFF3E0); 
      textColor = Colors.orange;
    } else if (s == 'ditolak' || s == 'dibatalkan' || s == 'batal') {
      bgColor = Colors.red; 
      textColor = Colors.pink;
    } else if (s == 'diproses') {
      bgColor = const Color(0xFFE8F3F5); 
      textColor = Colors.blue; 
    } else {
      bgColor = Colors.grey.shade200;
      textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ), 
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          6,
        ), 
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12, 
          fontWeight:
              FontWeight.bold, 
        ),
      ),
    );
  }
}
