
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'form_pasien.dart';

class HalamanDetailPasien extends StatelessWidget {
  final Map<String, dynamic> data;

  const HalamanDetailPasien({
    super.key,
    required this.data,
  });

  static const Color biru = Color(0xFF1769AA);
  static const Color biruGelap = Color(0xFF123B5D);
  static const Color latar = Color(0xFFF4F7FB);

  String nilai(String key) {
    final hasil = data[key]?.toString();
    return hasil == null || hasil.trim().isEmpty ? '-' : hasil;
  }

  Widget itemInformasi(IconData ikon, String label, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
        builder: (context) => HalamanEditPasien(data: data),
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
        title: const Text('Hapus Data Pasien'),
        content: Text(
          'Apakah kamu yakin ingin menghapus data pasien ${nilai('nama_pasien')}?',
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
      await ApiService.hapusPasien(
        pasienId: int.parse(nilai('pasien_id')),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data pasien: $e'),
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
          'Detail Pasien',
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
                vertical: 28,
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
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nilai('nama_pasien'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'No. RM: ${nilai('nomor_rm')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
                    'Informasi Pribadi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: biruGelap,
                    ),
                  ),
                  const SizedBox(height: 22),
                  itemInformasi(
                    Icons.badge_outlined,
                    'Nomor Rekam Medis',
                    nilai('nomor_rm'),
                  ),
                  itemInformasi(
                    Icons.person_outline,
                    'Nama Pasien',
                    nilai('nama_pasien'),
                  ),
                  itemInformasi(
                    Icons.calendar_month_outlined,
                    'Tanggal Lahir',
                    nilai('tanggal_lahir'),
                  ),
                  itemInformasi(
                    Icons.wc_outlined,
                    'Jenis Kelamin',
                    nilai('jenis_kelamin'),
                  ),
                  itemInformasi(
                    Icons.phone_outlined,
                    'Nomor Telepon',
                    nilai('nomor_telepon'),
                  ),
                  itemInformasi(
                    Icons.location_on_outlined,
                    'Alamat',
                    nilai('alamat'),
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
                label: const Text('Edit Data Pasien'),
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
                label: const Text('Hapus Data Pasien'),
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
