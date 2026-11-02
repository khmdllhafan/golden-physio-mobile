# 📱 Golden Physio Mobile

> **Sistem Informasi Pemesanan Fisioterapi Berbasis Mobile (Role Pasien)**  
> Dibuat untuk memenuhi syarat kelulusan Tugas Akhir / Skripsi.

---

## 📋 Tentang Proyek
**Golden Physio** adalah aplikasi berbasis *mobile* yang dirancang untuk memudahkan pasien dalam melakukan pemesanan layanan fisioterapi, melihat jadwal terapis, memantau riwayat terapi, serta mendapatkan informasi lokasi klinik secara akurat dan efisien. Aplikasi ini dibangun menggunakan framework **Flutter** dan bahasa pemrograman **Dart**.

---

## ✨ Fitur Utama
* **Autentikasi Pengguna**: Sistem registrasi, *login*, dan pemulihan kata sandi (*lupa password*) yang aman bagi pasien.
* **Beranda & Informasi**: Tdashboard interaktif untuk melihat ringkasan layanan.
* **Pemesanan Fisioterapi**: Fitur pemesanan jadwal sesi terapi secara *online*.
* **Jadwal & Riwayat Terapi**: Memantau jadwal kunjungan aktif serta melihat rekam jejak riwayat terapi sebelumnya.
* **Lokasi & Peta**: Integrasi peta digital untuk memandu pasien menuju lokasi klinik.
* **Profil Pasien**: Pengelolaan informasi data diri dan akun pengguna.

---

## 🛠️ Teknologi yang Digunakan
* **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI toolkit)
* **Bahasa Pemrograman**: [Dart](https://dart.dev/)
* **IDE**: Visual Studio Code / Android Studio

---

## 📂 Struktur Direktori Proyek
```text
golden-physio/
│
├── lib/
│   ├── views/
│   │   └── user/           # Halaman antarmuka pengguna (Pasien)
│   │       ├── home_page.dart
│   │       ├── jadwal_fisioterapi_page.dart
│   │       ├── login_page.dart
│   │       ├── lokasi_map_page.dart
│   │       ├── lupa_password_page.dart
│   │       ├── pemesanan_fisioterapi_page.dart
│   │       ├── profil_saya_page.dart
│   │       ├── registrasi_page.dart
│   │       ├── riwayat_terapi.dart
│   │       └── splash_page.dart
│   └── main.dart           # Titik masuk utama aplikasi Flutter
│
├── pubspec.yaml            # Konfigurasi dependensi dan aset
└── README.md
