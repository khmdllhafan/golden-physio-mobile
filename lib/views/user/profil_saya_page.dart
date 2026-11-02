import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'jadwal_fisioterapi_page.dart';
import 'pemesanan_fisioterapi_page.dart';
import 'riwayat_terapi.dart';
import 'login_page.dart';

class ProfilSayaPage extends StatefulWidget {
  final String username;
  final int initialIndex;

  const ProfilSayaPage({
    super.key,
    required this.username,
    this.initialIndex = 4,
  });

  @override
  State<ProfilSayaPage> createState() => _ProfilSayaPageState();
}

class _ProfilSayaPageState extends State<ProfilSayaPage> {
  final _formKey = GlobalKey<FormState>();

  late int _selectedIndex;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _jenisKelaminController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordBaruController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;

  Map<String, String> _initialData = {};

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _fetchProfilData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _namaLengkapController.dispose();
    _tanggalLahirController.dispose();
    _jenisKelaminController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _passwordBaruController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfilData() async {
    final String url =
        'http://localhost/golden_api/get_profil.php?username=${widget.username}';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          var user = data['user'];
          setState(() {
            _usernameController.text = user['username'] ?? '';
            _namaLengkapController.text = user['nama_lengkap'] ?? '';
            _tanggalLahirController.text = user['tanggal_lahir'] ?? '';
            _jenisKelaminController.text = user['jenis_kelamin'] ?? '';
            _noHpController.text = user['no_hp'] ?? '';
            _alamatController.text = user['alamat'] ?? '';

            _initialData = {
              'username': _usernameController.text,
              'no_hp': _noHpController.text,
              'alamat': _alamatController.text,
            };

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _passwordError = null;

      _usernameController.text = _initialData['username'] ?? '';
      _noHpController.text = _initialData['no_hp'] ?? '';
      _alamatController.text = _initialData['alamat'] ?? '';

      _passwordBaruController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _validatePasswordMatch() {
    String p1 = _passwordBaruController.text;
    String p2 = _confirmPasswordController.text;

    setState(() {
      if (p1.isNotEmpty && p2.isNotEmpty && p1 != p2) {
        _passwordError = 'Password dan konfirmasi password tidak cocok!';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _updateProfil() async {
    if (_passwordError != null) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final String url = 'http://localhost/golden_api/update_profil.php';

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'old_username':
                widget.username,
            'username': _usernameController.text,
            'no_hp': _noHpController.text,
            'alamat': _alamatController.text,
            'password': _passwordBaruController.text,
          },
        );

        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Profil berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {
              _initialData['username'] = _usernameController.text;
              _initialData['no_hp'] = _noHpController.text;
              _initialData['alamat'] = _alamatController.text;
              _isEditing = false;
              _passwordBaruController.clear();
              _confirmPasswordController.clear();
            });

            if (_usernameController.text != widget.username) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ProfilSayaPage(username: _usernameController.text),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Gagal memperbarui profil'),
                backgroundColor: Colors.red,
              ),
            );
          }
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

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 750),
                    padding: const EdgeInsets.all(28.0),
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
                            'PROFIL SAYA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_passwordError != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _passwordError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          _buildLabel('Username'),
                          TextFormField(
                            controller: _usernameController,
                            readOnly: !_isEditing,
                            decoration: _buildInputDecoration(
                              isReadOnly: !_isEditing,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Nama Lengkap'),
                          TextFormField(
                            controller: _namaLengkapController,
                            readOnly: true,
                            decoration: _buildInputDecoration(isReadOnly: true),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Tanggal Lahir'),
                          TextFormField(
                            controller: _tanggalLahirController,
                            readOnly: true,
                            decoration: _buildInputDecoration(isReadOnly: true),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Jenis Kelamin'),
                          TextFormField(
                            controller: _jenisKelaminController,
                            readOnly: true,
                            decoration: _buildInputDecoration(isReadOnly: true),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Nomor HP'),
                          TextFormField(
                            controller: _noHpController,
                            readOnly: !_isEditing,
                            keyboardType: TextInputType.phone,
                            decoration: _buildInputDecoration(
                              isReadOnly: !_isEditing,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Alamat'),
                          TextFormField(
                            controller: _alamatController,
                            readOnly: !_isEditing,
                            maxLines: 3,
                            decoration: _buildInputDecoration(
                              isReadOnly: !_isEditing,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Password Baru'),
                          TextFormField(
                            controller: _passwordBaruController,
                            readOnly: !_isEditing,
                            obscureText: _obscurePassword,
                            onChanged: (_) => _validatePasswordMatch(),
                            decoration: _buildInputDecoration(
                              isReadOnly: !_isEditing,
                              hint: 'Masukkan password baru',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          
                          _buildLabel('Konfirmasi Password Baru'),
                          TextFormField(
                            controller: _confirmPasswordController,
                            readOnly: !_isEditing,
                            obscureText: _obscureConfirmPassword,
                            onChanged: (_) => _validatePasswordMatch(),
                            decoration: _buildInputDecoration(
                              isReadOnly: !_isEditing,
                              hint: 'Ulangi password baru',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          
                          const Text(
                            '* Kosongkan kedua kolom di atas jika tidak ingin mengganti password Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          
                          Center(
                            child:
                                !_isEditing
                                    ? ElevatedButton(
                                      onPressed: _enableEditing,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF00bfff,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 36,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Edit Profil',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed:
                                              _isSubmitting
                                                  ? null
                                                  : _updateProfil,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00bfff,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 28,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child:
                                              _isSubmitting
                                                  ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : const Text(
                                                    'Simpan',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _cancelEditing,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.grey.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 28,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Batal',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
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

  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required bool isReadOnly,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 1.5),
      ),
      suffixIcon: suffixIcon,
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
}
