import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'jadwal_fisioterapi_page.dart';
import 'riwayat_terapi.dart';
import 'profil_saya_page.dart';
import 'login_page.dart';

class PemesananFisioterapiPage extends StatefulWidget {
  final String username;
  final int initialIndex;

  const PemesananFisioterapiPage({
    super.key,
    required this.username,
    this.initialIndex = 2,
  });

  @override
  State<PemesananFisioterapiPage> createState() =>
      _PemesananFisioterapiPageState();
}

class _PemesananFisioterapiPageState extends State<PemesananFisioterapiPage> {
  final _formKey = GlobalKey<FormState>();

  late int _selectedIndex;

  late final TextEditingController _namaController;
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _keluhanController = TextEditingController();
  final TextEditingController _riwayatCederaController =
      TextEditingController();

  String? _selectedTerapis;
  String? _selectedJam;
  DateTime? _selectedDate;

  bool _isAgreed = false;
  bool _isSubmitting = false;
  bool _noHpError = false;

  List<dynamic> _listTerapis = [];
  final List<String> _listJam = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '19:00',
    '20:00',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _namaController = TextEditingController(text: widget.username);
    _fetchTerapis();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _keluhanController.dispose();
    _riwayatCederaController.dispose();
    super.dispose();
  }

  Future<void> _fetchTerapis() async {
    final String url =
        'http://localhost/golden_api/get_terapis.php';
    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        setState(() {
          if (decodedData is Map && decodedData.containsKey('data')) {
            _listTerapis = decodedData['data'] ?? [];
          } else if (decodedData is List) {
            _listTerapis = decodedData;
          } else {
            _listTerapis = [];
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listTerapis = [
          {'id_terapis': '1', 'nama_lengkap': 'Yovan'},
          {'id_terapis': '4', 'nama_lengkap': 'agung'},
        ];
      });
      debugPrint("Error mengambil terapis: $e");
    }
  }

  void _validateNoHp(String value) {
    setState(() {
      if (value.isNotEmpty && (!value.startsWith('08') || value.length < 10)) {
        _noHpError = true;
      } else {
        _noHpError = false;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitPemesanan() async {
    if (_formKey.currentState!.validate() &&
        _isAgreed &&
        !_noHpError &&
        _selectedDate != null &&
        _selectedTerapis != null &&
        _selectedJam != null) {
      setState(() {
        _isSubmitting = true;
      });

      final String url =
          'http://localhost/golden_api/simpan_pemesanan.php'; // Diubah ke loopback Termux

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'nama': _namaController.text,
            'no_hp': _noHpController.text,
            'alamat': _alamatController.text,
            'id_terapis': _selectedTerapis!,
            'tanggal_terapi': DateFormat('yyyy-MM-dd').format(_selectedDate!),
            'jam_terapi': _selectedJam!,
            'keluhan': _keluhanController.text,
            'riwayat_cedera': _riwayatCederaController.text,
          },
        );

        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Pemesanan berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => JadwalFisioterapiPage(
                    username: widget.username,
                    initialIndex: 1,
                  ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim pemesanan ke server'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi seluruh data formulir dengan benar.'),
          backgroundColor: Colors.orange,
        ),
      );
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(24.0),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PEMESANAN FISIOTERAPI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_noHpError)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Nomor HP harus diawali 08 dan minimal 10 angka.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),

                  const Text(
                    'Nama',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'No Handphone',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noHpController,
                    keyboardType: TextInputType.number,
                    onChanged: _validateNoHp,
                    decoration: InputDecoration(
                      hintText: '08xxxxxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'No Handphone tidak boleh kosong';
                      }
                      if (!value.startsWith('08') || value.length < 10) {
                        return 'Format No HP tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Alamat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _alamatController,
                    decoration: InputDecoration(
                      hintText: 'Alamat lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Alamat tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Pilih Terapis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedTerapis,
                    hint: const Text('-- Pilih Terapis Tersedia --'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items:
                        _listTerapis.map<DropdownMenuItem<String>>((t) {
                          String id = (t['id_terapis'] ?? t['id']).toString();
                          String nama =
                              t['nama_lengkap'] ?? t['nama'] ?? 'Terapis';

                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(nama),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerapis = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null
                                ? 'Silakan pilih terapis terlebih dahulu'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Tanggal Terapi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'dd/MM/yyyy'
                                : DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedDate!),
                            style: TextStyle(
                              color:
                                  _selectedDate == null
                                      ? Colors.grey.shade600
                                      : Colors.black,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Jam Terapi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedJam,
                    hint: const Text('-- Pilih Jam Tersedia --'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items:
                        _listJam.map((jam) {
                          return DropdownMenuItem<String>(
                            value: jam,
                            child: Text('$jam WIB'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedJam = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Silakan pilih jam terapi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Keluhan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _keluhanController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan keluhan Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Keluhan tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Riwayat Cedera Sebelumnya',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _riwayatCederaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Riwayat penyakit atau cedera (opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Saya menyatakan bahwa data yang saya isi adalah benar dan saya bersedia mengikuti prosedur serta ketentuan layanan fisioterapi.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed:
                          (_isAgreed && !_noHpError && !_isSubmitting)
                              ? _submitPemesanan
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00bfff),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Kirim Pemesanan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
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
}
