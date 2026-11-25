
import 'package:flutter/material.dart';
import '../api_service.dart';

const Color _biruE = Color(0xFF1769AA);
const Color _gelapE = Color(0xFF123B5D);
const Color _latarE = Color(0xFFF4F7FB);

InputDecoration _dekorasiEditPemeriksaan(String label, IconData ikon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(ikon, color: _biruE),
    filled: true,
    fillColor: const Color(0xFFF8FAFD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFE2EAF2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _biruE, width: 1.5),
    ),
  );
}

class HalamanEditPemeriksaan extends StatefulWidget {
  final Map<String, dynamic> pemeriksaan;

  const HalamanEditPemeriksaan({
    super.key,
    required this.pemeriksaan,
  });

  @override
  State<HalamanEditPemeriksaan> createState() =>
      _HalamanEditPemeriksaanState();
}

class _HalamanEditPemeriksaanState
    extends State<HalamanEditPemeriksaan> {
  final _formKey = GlobalKey<FormState>();
  final keluhanController = TextEditingController();
  final diagnosisController = TextEditingController();
  final tindakanController = TextEditingController();

  List<dynamic> daftarPasien = [];
  List<dynamic> daftarDokter = [];

  int? pasienTerpilih;
  int? dokterTerpilih;
  DateTime? tanggalPemeriksaan;

  bool sedangMemuat = true;
  bool sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();

    keluhanController.text =
        widget.pemeriksaan['keluhan']?.toString() ?? '';
    diagnosisController.text =
        widget.pemeriksaan['diagnosis']?.toString() ?? '';
    tindakanController.text =
        widget.pemeriksaan['tindakan']?.toString() ?? '';

    pasienTerpilih = int.tryParse(
      widget.pemeriksaan['pasien_id']?.toString() ?? '',
    );
    dokterTerpilih = int.tryParse(
      widget.pemeriksaan['dokter_id']?.toString() ?? '',
    );
    tanggalPemeriksaan = DateTime.tryParse(
      widget.pemeriksaan['tanggal_pemeriksaan']?.toString() ?? '',
    );

    muatDataDropdown();
  }

  @override
  void dispose() {
    keluhanController.dispose();
    diagnosisController.dispose();
    tindakanController.dispose();
    super.dispose();
  }

  Future<void> muatDataDropdown() async {
    try {
      final hasil = await Future.wait([
        ApiService.getPasien(),
        ApiService.getDokter(),
      ]);

      if (!mounted) return;
      setState(() {
        daftarPasien = hasil[0];
        daftarDokter = hasil[1];
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => sedangMemuat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pasien/dokter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: tanggalPemeriksaan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null) {
      setState(() => tanggalPemeriksaan = tanggal);
    }
  }

  String formatTanggal(DateTime? tanggal) {
    if (tanggal == null) return 'Pilih tanggal pemeriksaan';
    return '${tanggal.day.toString().padLeft(2, '0')}/'
        '${tanggal.month.toString().padLeft(2, '0')}/'
        '${tanggal.year}';
  }

  String formatApi(DateTime tanggal) {
    final sekarang = DateTime.now();
    return '${tanggal.year}-'
        '${tanggal.month.toString().padLeft(2, '0')}-'
        '${tanggal.day.toString().padLeft(2, '0')} '
        '${sekarang.hour.toString().padLeft(2, '0')}:'
        '${sekarang.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    if (pasienTerpilih == null ||
        dokterTerpilih == null ||
        tanggalPemeriksaan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasien, dokter, dan tanggal wajib dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => sedangMenyimpan = true);

    try {
      await ApiService.updatePemeriksaan(
        pemeriksaanId: int.parse(
          widget.pemeriksaan['pemeriksaan_id'].toString(),
        ),
        pasienId: pasienTerpilih!,
        dokterId: dokterTerpilih!,
        tanggalPemeriksaan: formatApi(tanggalPemeriksaan!),
        keluhan: keluhanController.text.trim(),
        diagnosis: diagnosisController.text.trim(),
        tindakan: tindakanController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemeriksaan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui pemeriksaan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => sedangMenyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latarE,
      appBar: AppBar(
        title: const Text('Edit Pemeriksaan'),
        backgroundColor: Colors.white,
        foregroundColor: _gelapE,
        elevation: 0,
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : daftarPasien.isEmpty || daftarDokter.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 48, color: Colors.orange),
                        const SizedBox(height: 12),
                        const Text(
                          'Data pasien atau dokter belum tersedia.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => sedangMemuat = true);
                            muatDataDropdown();
                          },
                          child: const Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_biruE, _gelapE],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.edit_note,
                                    color: Colors.white, size: 35),
                                SizedBox(height: 12),
                                Text(
                                  'Perbarui Pemeriksaan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Sesuaikan informasi pemeriksaan pasien.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text('Identitas Pemeriksaan',
                              style: TextStyle(
                                color: _gelapE,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 17),
                          DropdownButtonFormField<int>(
                            value: daftarPasien.any((item) =>
                                    int.tryParse(
                                      item['pasien_id'].toString(),
                                    ) == pasienTerpilih)
                                ? pasienTerpilih
                                : null,
                            isExpanded: true,
                            decoration: _dekorasiEditPemeriksaan(
                              'Pilih Pasien', Icons.person_outline,
                            ),
                            items: daftarPasien.map((item) {
                              final id = int.tryParse(
                                item['pasien_id'].toString(),
                              );
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  '${item['nama_pasien']} • ${item['nomor_rm'] ?? '-'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => pasienTerpilih = value),
                            validator: (value) =>
                                value == null ? 'Pasien wajib dipilih' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: daftarDokter.any((item) =>
                                    int.tryParse(
                                      item['dokter_id'].toString(),
                                    ) == dokterTerpilih)
                                ? dokterTerpilih
                                : null,
                            isExpanded: true,
                            decoration: _dekorasiEditPemeriksaan(
                              'Pilih Dokter',
                              Icons.medical_services_outlined,
                            ),
                            items: daftarDokter.map((item) {
                              final id = int.tryParse(
                                item['dokter_id'].toString(),
                              );
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  item['nama_dokter'].toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => dokterTerpilih = value),
                            validator: (value) =>
                                value == null ? 'Dokter wajib dipilih' : null,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: pilihTanggal,
                            borderRadius: BorderRadius.circular(13),
                            child: InputDecorator(
                              decoration: _dekorasiEditPemeriksaan(
                                'Tanggal Pemeriksaan',
                                Icons.calendar_month_outlined,
                              ),
                              child: Text(formatTanggal(tanggalPemeriksaan)),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text('Hasil Pemeriksaan',
                              style: TextStyle(
                                color: _gelapE,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 17),
                          TextFormField(
                            controller: keluhanController,
                            maxLines: 3,
                            decoration: _dekorasiEditPemeriksaan(
                              'Keluhan Pasien', Icons.sick_outlined,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Keluhan wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: diagnosisController,
                            maxLines: 3,
                            decoration: _dekorasiEditPemeriksaan(
                              'Diagnosis',
                              Icons.health_and_safety_outlined,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Diagnosis wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: tindakanController,
                            maxLines: 3,
                            decoration: _dekorasiEditPemeriksaan(
                              'Tindakan (Opsional)',
                              Icons.medication_outlined,
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 53,
                            child: ElevatedButton.icon(
                              onPressed: sedangMenyimpan
                                  ? null : simpanPerubahan,
                              icon: sedangMenyimpan
                                  ? const SizedBox(
                                      width: 19, height: 19,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(sedangMenyimpan
                                  ? 'Menyimpan...' : 'Simpan Perubahan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _biruE,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
