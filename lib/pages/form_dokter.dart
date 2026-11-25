
import 'package:flutter/material.dart';
import '../api_service.dart';

const Color _biruD = Color(0xFF1769AA);
const Color _gelapD = Color(0xFF123B5D);
const Color _latarD = Color(0xFFF4F7FB);

InputDecoration _dekorasiDokter(String label, IconData ikon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(ikon, color: _biruD),
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
      borderSide: const BorderSide(color: _biruD, width: 1.5),
    ),
  );
}

Widget _headerDokter(String judul, String deskripsi) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_biruD, _gelapD],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.medical_services_outlined,
            color: Colors.white, size: 35),
        const SizedBox(height: 13),
        Text(judul, style: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 5),
        Text(deskripsi, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

class HalamanTambahDokter extends StatefulWidget {
  const HalamanTambahDokter({super.key});

  @override
  State<HalamanTambahDokter> createState() => _HalamanTambahDokterState();
}

class _HalamanTambahDokterState extends State<HalamanTambahDokter> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final spesialisasiController = TextEditingController();
  final teleponController = TextEditingController();
  final emailController = TextEditingController();

  bool sedangMenyimpan = false;

  @override
  void dispose() {
    namaController.dispose();
    spesialisasiController.dispose();
    teleponController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> simpanDokter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => sedangMenyimpan = true);

    try {
      await ApiService.tambahDokter(
        namaDokter: namaController.text.trim(),
        spesialisasi: spesialisasiController.text.trim(),
        nomorTelepon: teleponController.text.trim(),
        email: emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data dokter berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => sedangMenyimpan = false);
    }
  }

  Widget input(String label, TextEditingController controller,
      IconData ikon, String pesan,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _dekorasiDokter(label, ikon),
        validator: (v) =>
            v == null || v.trim().isEmpty ? pesan : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latarD,
      appBar: AppBar(
        title: const Text('Tambah Dokter'),
        backgroundColor: Colors.white,
        foregroundColor: _gelapD,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                _headerDokter(
                  'Registrasi Dokter',
                  'Masukkan informasi tenaga medis klinik.',
                ),
                const SizedBox(height: 22),
                input('Nama Dokter', namaController,
                    Icons.person_outline, 'Nama dokter wajib diisi'),
                input('Spesialisasi', spesialisasiController,
                    Icons.medical_information_outlined,
                    'Spesialisasi wajib diisi'),
                input('Nomor Telepon', teleponController,
                    Icons.phone_outlined, 'Nomor telepon wajib diisi',
                    keyboard: TextInputType.phone),
                input('Email', emailController,
                    Icons.email_outlined, 'Email wajib diisi',
                    keyboard: TextInputType.emailAddress),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton.icon(
                    onPressed: sedangMenyimpan ? null : simpanDokter,
                    icon: sedangMenyimpan
                        ? const SizedBox(
                            width: 19, height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      sedangMenyimpan ? 'Menyimpan...' : 'Simpan Dokter',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _biruD,
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

class HalamanEditDokter extends StatefulWidget {
  final Map<String, dynamic> data;

  const HalamanEditDokter({
    super.key,
    required this.data,
  });

  @override
  State<HalamanEditDokter> createState() => _HalamanEditDokterState();
}

class _HalamanEditDokterState extends State<HalamanEditDokter> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController spesialisasiController;
  late TextEditingController teleponController;
  late TextEditingController emailController;

  bool sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(
      text: widget.data['nama_dokter']?.toString() ?? '',
    );
    spesialisasiController = TextEditingController(
      text: widget.data['spesialisasi']?.toString() ?? '',
    );
    teleponController = TextEditingController(
      text: widget.data['nomor_telepon']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: widget.data['email']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    spesialisasiController.dispose();
    teleponController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => sedangMenyimpan = true);

    try {
      await ApiService.updateDokter(
        dokterId: int.parse(widget.data['dokter_id'].toString()),
        namaDokter: namaController.text.trim(),
        spesialisasi: spesialisasiController.text.trim(),
        nomorTelepon: teleponController.text.trim(),
        email: emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data dokter berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => sedangMenyimpan = false);
    }
  }

  Widget input(String label, TextEditingController controller,
      IconData ikon, String pesan,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _dekorasiDokter(label, ikon),
        validator: (v) =>
            v == null || v.trim().isEmpty ? pesan : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latarD,
      appBar: AppBar(
        title: const Text('Edit Dokter'),
        backgroundColor: Colors.white,
        foregroundColor: _gelapD,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                _headerDokter(
                  'Perbarui Data Dokter',
                  'Pastikan informasi dokter sudah sesuai.',
                ),
                const SizedBox(height: 22),
                input('Nama Dokter', namaController,
                    Icons.person_outline, 'Nama dokter wajib diisi'),
                input('Spesialisasi', spesialisasiController,
                    Icons.medical_information_outlined,
                    'Spesialisasi wajib diisi'),
                input('Nomor Telepon', teleponController,
                    Icons.phone_outlined, 'Nomor telepon wajib diisi',
                    keyboard: TextInputType.phone),
                input('Email', emailController,
                    Icons.email_outlined, 'Email wajib diisi',
                    keyboard: TextInputType.emailAddress),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton.icon(
                    onPressed: sedangMenyimpan ? null : simpanPerubahan,
                    icon: sedangMenyimpan
                        ? const SizedBox(
                            width: 19, height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      sedangMenyimpan ? 'Menyimpan...' : 'Simpan Perubahan',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _biruD,
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
