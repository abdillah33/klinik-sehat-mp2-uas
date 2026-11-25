
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'edit_pemeriksaan.dart';

class HalamanDetailPemeriksaan extends StatelessWidget {
  final Map<String, dynamic> pemeriksaan;

  const HalamanDetailPemeriksaan({
    super.key,
    required this.pemeriksaan,
  });

  static const Color biru = Color(0xFF1769AA);
  static const Color biruGelap = Color(0xFF123B5D);
  static const Color latar = Color(0xFFF4F7FB);

  String nilai(String key) {
    final hasil = pemeriksaan[key]?.toString();
    return hasil == null || hasil.trim().isEmpty ? '-' : hasil;
  }

  Widget itemInformasi(
    IconData ikon,
    String label,
    String isi, {
    bool multiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: biru.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: biru, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isi,
                  style: const TextStyle(
                    color: Color(0xFF243447),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> bukaEdit(BuildContext context) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanEditPemeriksaan(
          pemeriksaan: pemeriksaan,
        ),
      ),
    );

    if (hasil == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> konfirmasiHapus(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Hapus Data Pemeriksaan'),
        content: Text(
          'Apakah kamu yakin ingin menghapus data pemeriksaan ${nilai('nama_pasien')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !context.mounted) return;

    try {
      await ApiService.hapusPemeriksaan(
        pemeriksaanId: int.parse(nilai('pemeriksaan_id')),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pemeriksaan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, 'dihapus');
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus pemeriksaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        title: const Text(
          'Informasi Pemeriksaan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: biruGelap,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 25,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [biru, biruGelap],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Data Pemeriksaan Pasien',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nilai('tanggal_pemeriksaan'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identitas Pasien',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: biruGelap,
                    ),
                  ),
                  const SizedBox(height: 22),
                  itemInformasi(
                    Icons.person_outline,
                    'Nama Pasien',
                    nilai('nama_pasien'),
                  ),
                  itemInformasi(
                    Icons.badge_outlined,
                    'Nomor Rekam Medis',
                    nilai('nomor_rm'),
                  ),
                  const Divider(height: 15),
                  const SizedBox(height: 15),
                  const Text(
                    'Informasi Pemeriksaan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: biruGelap,
                    ),
                  ),
                  const SizedBox(height: 22),
                  itemInformasi(
                    Icons.medical_services_outlined,
                    'Dokter Pemeriksa',
                    nilai('nama_dokter'),
                  ),
                  itemInformasi(
                    Icons.calendar_month_outlined,
                    'Tanggal Pemeriksaan',
                    nilai('tanggal_pemeriksaan'),
                  ),
                  itemInformasi(
                    Icons.sick_outlined,
                    'Keluhan',
                    nilai('keluhan'),
                  ),
                  itemInformasi(
                    Icons.health_and_safety_outlined,
                    'Diagnosis',
                    nilai('diagnosis'),
                  ),
                  itemInformasi(
                    Icons.medication_outlined,
                    'Tindakan',
                    nilai('tindakan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => bukaEdit(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Pemeriksaan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: biru,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => konfirmasiHapus(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Pemeriksaan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
