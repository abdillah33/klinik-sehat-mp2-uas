
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Alamat API dari laptop
  static const String baseUrl =
      'http://192.168.101.71/klinik_api';

  // ==============================
  // API PASIEN
  // ==============================

  static Future<List<dynamic>> getPasien() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pasien.php'),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] == true) {
        return hasil['data'];
      } else {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal mengambil data pasien');
    }
  }

  static Future<void> tambahPasien({
    required String nomorRm,
    required String namaPasien,
    required String tanggalLahir,
    required String jenisKelamin,
    required String nomorTelepon,
    required String alamat,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pasien.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nomor_rm': nomorRm,
        'nama_pasien': namaPasien,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
        'nomor_telepon': nomorTelepon,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menambahkan data pasien');
    }
  }

  static Future<void> updatePasien({
    required int pasienId,
    required String nomorRm,
    required String namaPasien,
    required String tanggalLahir,
    required String jenisKelamin,
    required String nomorTelepon,
    required String alamat,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pasien.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pasien_id': pasienId,
        'nomor_rm': nomorRm,
        'nama_pasien': namaPasien,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
        'nomor_telepon': nomorTelepon,
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal memperbarui data pasien');
    }
  }

  static Future<void> hapusPasien({
    required int pasienId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pasien.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pasien_id': pasienId,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menghapus data pasien');
    }
  }

  // ==============================
  // API DOKTER
  // ==============================

  static Future<List<dynamic>> getDokter() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dokter.php'),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] == true) {
        return hasil['data'];
      } else {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal mengambil data dokter');
    }
  }

  static Future<void> tambahDokter({
    required String namaDokter,
    required String spesialisasi,
    required String nomorTelepon,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dokter.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama_dokter': namaDokter,
        'spesialisasi': spesialisasi,
        'nomor_telepon': nomorTelepon,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menambahkan data dokter');
    }
  }

  static Future<void> updateDokter({
    required int dokterId,
    required String namaDokter,
    required String spesialisasi,
    required String nomorTelepon,
    required String email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dokter.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dokter_id': dokterId,
        'nama_dokter': namaDokter,
        'spesialisasi': spesialisasi,
        'nomor_telepon': nomorTelepon,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal memperbarui data dokter');
    }
  }

  static Future<void> hapusDokter({
    required int dokterId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/dokter.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dokter_id': dokterId,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menghapus data dokter');
    }
  }

  // ==============================
  // API PEMERIKSAAN
  // ==============================

  // Mengambil daftar pemeriksaan
  static Future<List<dynamic>> getPemeriksaan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pemeriksaan.php'),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] == true) {
        return hasil['data'];
      } else {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal mengambil data pemeriksaan');
    }
  }

  // Menambahkan pemeriksaan
  static Future<void> tambahPemeriksaan({
    required int pasienId,
    required int dokterId,
    required String tanggalPemeriksaan,
    required String keluhan,
    required String diagnosis,
    required String tindakan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pemeriksaan.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pasien_id': pasienId,
        'dokter_id': dokterId,
        'tanggal_pemeriksaan': tanggalPemeriksaan,
        'keluhan': keluhan,
        'diagnosis': diagnosis,
        'tindakan': tindakan,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menambahkan data pemeriksaan');
    }
  }

  // Memperbarui pemeriksaan
  static Future<void> updatePemeriksaan({
    required int pemeriksaanId,
    required int pasienId,
    required int dokterId,
    required String tanggalPemeriksaan,
    required String keluhan,
    required String diagnosis,
    required String tindakan,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pemeriksaan.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pemeriksaan_id': pemeriksaanId,
        'pasien_id': pasienId,
        'dokter_id': dokterId,
        'tanggal_pemeriksaan': tanggalPemeriksaan,
        'keluhan': keluhan,
        'diagnosis': diagnosis,
        'tindakan': tindakan,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal memperbarui data pemeriksaan');
    }
  }

  // Menghapus pemeriksaan
  static Future<void> hapusPemeriksaan({
    required int pemeriksaanId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pemeriksaan.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pemeriksaan_id': pemeriksaanId,
      }),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);

      if (hasil['status'] != true) {
        throw Exception(hasil['pesan']);
      }
    } else {
      throw Exception('Gagal menghapus data pemeriksaan');
    }
  }
}
