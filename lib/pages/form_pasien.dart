
import 'package:flutter/material.dart';
import '../api_service.dart';

const Color _biru = Color(0xFF1769AA);
const Color _gelap = Color(0xFF123B5D);
const Color _latar = Color(0xFFF4F7FB);

Widget _headerPasien(String judul, String deskripsi) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_biru, _gelap],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_add_alt_1, color: Colors.white, size: 35),
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

InputDecoration _dekorasiPasien(String label, IconData ikon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(ikon, color: _biru),
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
      borderSide: const BorderSide(color: _biru, width: 1.5),
    ),
  );
}

class HalamanTambahPasien extends StatefulWidget {
  const HalamanTambahPasien({super.key});

  @override
  State<HalamanTambahPasien> createState() => _HalamanTambahPasienState();
}

class _HalamanTambahPasienState extends State<HalamanTambahPasien> {
  final formKey = GlobalKey<FormState>();
  final nomorRmController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalController = TextEditingController();
  final teleponController = TextEditingController();
  final alamatController = TextEditingController();

  String jenisKelamin = 'Laki-laki';
  bool sedangMenyimpan = false;

  @override
  void dispose() {
    nomorRmController.dispose();
    namaController.dispose();
    tanggalController.dispose();
    teleponController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (tanggal != null) {
      setState(() {
        tanggalController.text =
            '${tanggal.year.toString().padLeft(4, '0')}-'
            '${tanggal.month.toString().padLeft(2, '0')}-'
            '${tanggal.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> simpanPasien() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => sedangMenyimpan = true);

    try {
      await ApiService.tambahPasien(
        nomorRm: nomorRmController.text.trim(),
        namaPasien: namaController.text.trim(),
        tanggalLahir: tanggalController.text.trim(),
        jenisKelamin: jenisKelamin,
        nomorTelepon: teleponController.text.trim(),
        alamat: alamatController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil ditambahkan'),
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

  Widget input({
    required String label,
    required TextEditingController controller,
    required IconData ikon,
    required String pesan,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: _dekorasiPasien(label, ikon).copyWith(
          suffixIcon: readOnly
              ? const Icon(Icons.calendar_month, color: _biru)
              : null,
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? pesan : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        title: const Text('Tambah Pasien'),
        backgroundColor: Colors.white,
        foregroundColor: _gelap,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerPasien(
                'Registrasi Pasien',
                'Lengkapi informasi pasien baru dengan benar.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Identitas Pasien', style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: _gelap,
                    )),
                    const SizedBox(height: 18),
                    input(
                      label: 'Nomor Rekam Medis',
                      controller: nomorRmController,
                      ikon: Icons.badge_outlined,
                      pesan: 'Nomor RM wajib diisi',
                    ),
                    input(
                      label: 'Nama Pasien',
                      controller: namaController,
                      ikon: Icons.person_outline,
                      pesan: 'Nama pasien wajib diisi',
                    ),
                    input(
                      label: 'Tanggal Lahir',
                      controller: tanggalController,
                      ikon: Icons.calendar_month_outlined,
                      pesan: 'Tanggal lahir wajib diisi',
                      readOnly: true,
                      onTap: pilihTanggal,
                    ),
                    DropdownButtonFormField<String>(
                      value: jenisKelamin,
                      decoration: _dekorasiPasien(
                        'Jenis Kelamin', Icons.wc_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Laki-laki', child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'Perempuan', child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => jenisKelamin = value);
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    input(
                      label: 'Nomor Telepon',
                      controller: teleponController,
                      ikon: Icons.phone_outlined,
                      pesan: 'Nomor telepon wajib diisi',
                      keyboard: TextInputType.phone,
                    ),
                    input(
                      label: 'Alamat',
                      controller: alamatController,
                      ikon: Icons.location_on_outlined,
                      pesan: 'Alamat wajib diisi',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton.icon(
                        onPressed: sedangMenyimpan ? null : simpanPasien,
                        icon: sedangMenyimpan
                            ? const SizedBox(
                                width: 19, height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          sedangMenyimpan ? 'Menyimpan...' : 'Simpan Pasien',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _biru,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HalamanEditPasien extends StatefulWidget {
  final Map<String, dynamic> data;

  const HalamanEditPasien({
    super.key,
    required this.data,
  });

  @override
  State<HalamanEditPasien> createState() => _HalamanEditPasienState();
}

class _HalamanEditPasienState extends State<HalamanEditPasien> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomorRmController;
  late TextEditingController namaController;
  late TextEditingController tanggalController;
  late TextEditingController teleponController;
  late TextEditingController alamatController;

  String? jenisKelamin;
  bool sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    nomorRmController = TextEditingController(
      text: widget.data['nomor_rm']?.toString() ?? '',
    );
    namaController = TextEditingController(
      text: widget.data['nama_pasien']?.toString() ?? '',
    );
    tanggalController = TextEditingController(
      text: widget.data['tanggal_lahir']?.toString() ?? '',
    );
    teleponController = TextEditingController(
      text: widget.data['nomor_telepon']?.toString() ?? '',
    );
    alamatController = TextEditingController(
      text: widget.data['alamat']?.toString() ?? '',
    );
    jenisKelamin = widget.data['jenis_kelamin']?.toString();
    if (jenisKelamin != 'Laki-laki' && jenisKelamin != 'Perempuan') {
      jenisKelamin = 'Laki-laki';
    }
  }

  @override
  void dispose() {
    nomorRmController.dispose();
    namaController.dispose();
    tanggalController.dispose();
    teleponController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal() async {
    final awal = DateTime.tryParse(tanggalController.text);
    final tanggal = await showDatePicker(
      context: context,
      initialDate: awal ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (tanggal != null) {
      setState(() {
        tanggalController.text =
            '${tanggal.year.toString().padLeft(4, '0')}-'
            '${tanggal.month.toString().padLeft(2, '0')}-'
            '${tanggal.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => sedangMenyimpan = true);

    try {
      await ApiService.updatePasien(
        pasienId: int.parse(widget.data['pasien_id'].toString()),
        nomorRm: nomorRmController.text.trim(),
        namaPasien: namaController.text.trim(),
        tanggalLahir: tanggalController.text.trim(),
        jenisKelamin: jenisKelamin!,
        nomorTelepon: teleponController.text.trim(),
        alamat: alamatController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pasien berhasil diperbarui'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        title: const Text('Edit Pasien'),
        backgroundColor: Colors.white,
        foregroundColor: _gelap,
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
                _headerPasien(
                  'Perbarui Data Pasien',
                  'Pastikan informasi yang diperbarui sudah benar.',
                ),
                const SizedBox(height: 22),
                _editInput('Nomor Rekam Medis', nomorRmController,
                    Icons.badge_outlined),
                _editInput('Nama Pasien', namaController,
                    Icons.person_outline),
                TextFormField(
                  controller: tanggalController,
                  readOnly: true,
                  onTap: pilihTanggal,
                  decoration: _dekorasiPasien(
                    'Tanggal Lahir', Icons.calendar_month_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: jenisKelamin,
                  decoration: _dekorasiPasien(
                    'Jenis Kelamin', Icons.wc_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Laki-laki', child: Text('Laki-laki'),
                    ),
                    DropdownMenuItem(
                      value: 'Perempuan', child: Text('Perempuan'),
                    ),
                  ],
                  onChanged: (v) => setState(() => jenisKelamin = v),
                ),
                const SizedBox(height: 15),
                _editInput('Nomor Telepon', teleponController,
                    Icons.phone_outlined, keyboard: TextInputType.phone),
                TextFormField(
                  controller: alamatController,
                  maxLines: 3,
                  decoration: _dekorasiPasien(
                    'Alamat', Icons.location_on_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 22),
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
                      backgroundColor: _biru,
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

  Widget _editInput(
    String label,
    TextEditingController controller,
    IconData ikon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _dekorasiPasien(label, ikon),
        validator: (v) =>
            v == null || v.trim().isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }
}
