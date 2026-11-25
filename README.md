
# Klinik Sehat

Aplikasi Sistem Informasi Manajemen Klinik berbasis Flutter dan PHP.

Project ini dibuat untuk memenuhi tugas akhir mata kuliah Mobile Programming II.

## Deskripsi

Klinik Sehat merupakan aplikasi yang membantu pengelolaan data klinik, mulai dari data pasien, data dokter, pemeriksaan pasien, hingga riwayat medis pasien.

Aplikasi ini menggunakan Flutter sebagai frontend, PHP sebagai backend API, dan MySQL sebagai database.

## Fitur Aplikasi

- Dashboard
- Manajemen data pasien (CRUD)
- Manajemen data dokter (CRUD)
- Manajemen data pemeriksaan (CRUD)
- Detail data pasien, dokter, dan pemeriksaan
- Riwayat medis pasien
- Pencarian data
- Filter tanggal pada data pasien, pemeriksaan, dan riwayat medis

## Teknologi yang Digunakan

- Flutter
- Dart
- PHP
- MySQL
- Laragon
- REST API

## Struktur Project

```text
klinik-sehat-mp2-uas/
├── android/
├── lib/
│   ├── api_service.dart
│   ├── main.dart
│   └── pages/
├── test/
├── klinik_api/
│   ├── dokter.php
│   ├── koneksi.php
│   ├── pasien.php
│   ├── pemeriksaan.php
│   └── tes_koneksi.php
├── pubspec.yaml
└── README.md
```

## Persiapan Menjalankan Aplikasi

1. Install Flutter SDK.
2. Install Laragon.
3. Siapkan database MySQL dengan nama `db_klinik_uas`.
4. Letakkan folder API PHP pada direktori web Laragon.
5. Sesuaikan konfigurasi koneksi database pada `koneksi.php`.
6. Sesuaikan alamat API pada file `lib/api_service.dart` dengan alamat komputer yang menjalankan Laragon.
7. Jalankan aplikasi Flutter pada perangkat Android.

## Pengembang

Giebran Abdillah

Mahasiswa Sistem Informasi  
Universitas Bina Sarana Informatika
