
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detail_pasien.dart';
import 'form_pasien.dart';

class HalamanPasien extends StatefulWidget {
  const HalamanPasien({super.key});

  @override
  State<HalamanPasien> createState() => _HalamanPasienState();
}

class _HalamanPasienState extends State<HalamanPasien> {
  late Future<List<dynamic>> daftarPasien;
  final TextEditingController searchController = TextEditingController();

  String kataKunci = '';
  DateTime tanggalFilter = DateTime.now();
  bool semuaData = false;

  static const Color biru = Color(0xFF1769AA);
  static const Color latar = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    muatPasien();
  }

  void muatPasien() {
    daftarPasien = ApiService.getPasien();
  }

  Future<void> refreshPasien() async {
    setState(() => muatPasien());
    await daftarPasien;
  }

  Future<void> bukaFormTambah() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HalamanTambahPasien(),
      ),
    );

    if (hasil == true && mounted) {
      setState(() => muatPasien());
    }
  }

  Future<void> bukaDetailPasien(Map<String, dynamic> data) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanDetailPasien(data: data),
      ),
    );

    if (hasil == true && mounted) {
      setState(() => muatPasien());
    }
  }

  String tanggalKey(dynamic nilai) {
    if (nilai == null || nilai.toString().isEmpty) return '';

    final tanggal = DateTime.tryParse(nilai.toString());
    if (tanggal == null) return '';

    return '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
  }

  String formatTanggal(DateTime tanggal) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Future<void> pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: tanggalFilter,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal pendaftaran',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (hasil != null && mounted) {
      setState(() {
        tanggalFilter = hasil;
        semuaData = false;
      });
    }
  }

  List<dynamic> filterPasien(List<dynamic> data) {
    final berdasarkanTanggal = data.where((item) {
      if (semuaData) return true;

      return tanggalKey(item['tanggal_daftar']) ==
          tanggalKey(tanggalFilter.toIso8601String());
    }).toList();

    if (kataKunci.trim().isEmpty) return berdasarkanTanggal;

    final keyword = kataKunci.toLowerCase().trim();

    return berdasarkanTanggal.where((pasien) {
      final nama = (pasien['nama_pasien'] ?? '').toString().toLowerCase();
      final rm = (pasien['nomor_rm'] ?? '').toString().toLowerCase();

      return nama.contains(keyword) || rm.contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF243447),
        elevation: 0,
        title: const Text(
          'Data Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: daftarPasien,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: biru));
          }

          if (snapshot.hasError) return _tampilanError();

          final semuaPasien = snapshot.data ?? [];
          final pasien = filterPasien(semuaPasien);

          return RefreshIndicator(
            color: biru,
            onRefresh: refreshPasien,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1769AA), Color(0xFF2689CB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manajemen Pasien',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Kelola informasi dan data pasien klinik.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              '${pasien.length} Pasien Ditampilkan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Pasien',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Filter berdasarkan tanggal pendaftaran dan cari pasien.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pilihTanggal,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          semuaData ? 'Pilih Tanggal' : formatTanggal(tanggalFilter),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: biru,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => semuaData = true),
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text('Semua Data'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: semuaData ? Colors.white : biru,
                          backgroundColor: semuaData ? biru : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => kataKunci = value),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau nomor rekam medis...',
                    prefixIcon: const Icon(Icons.search_rounded, color: biru),
                    suffixIcon: kataKunci.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              searchController.clear();
                              setState(() => kataKunci = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFE7ECF2)),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                if (pasien.isEmpty)
                  _tampilanKosong()
                else
                  ...pasien.map((item) {
                    final data = Map<String, dynamic>.from(item);
                    final nama = data['nama_pasien']?.toString() ?? '-';
                    final rm = data['nomor_rm']?.toString() ?? '-';
                    final gender = data['jenis_kelamin']?.toString() ?? '-';
                    final telepon = data['nomor_telepon']?.toString() ?? '-';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(19),
                          onTap: () => bukaDetailPasien(data),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFE9EEF4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 53,
                                  height: 53,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F2FC),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: biru,
                                    size: 29,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF243447),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No. RM: $rm',
                                        style: const TextStyle(
                                          color: biru,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '$gender  •  $telepon',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: bukaFormTambah,
        backgroundColor: biru,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Tambah Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _tampilanKosong() {
    final pesan = kataKunci.isNotEmpty
        ? 'Pasien tidak ditemukan'
        : semuaData
            ? 'Belum ada data pasien'
            : 'Tidak ada pasien pada tanggal ini';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(Icons.person_search_rounded, size: 65, color: Colors.grey.shade400),
          const SizedBox(height: 13),
          Text(
            pesan,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243447),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba pilih tanggal lain atau gunakan Semua Data.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _tampilanError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 55, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data pasien',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => muatPasien()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
