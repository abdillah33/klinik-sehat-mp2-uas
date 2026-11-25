
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detail_pemeriksaan.dart';
import 'form_pemeriksaan.dart';

class HalamanPemeriksaan extends StatefulWidget {
  const HalamanPemeriksaan({super.key});

  @override
  State<HalamanPemeriksaan> createState() => _HalamanPemeriksaanState();
}

class _HalamanPemeriksaanState extends State<HalamanPemeriksaan> {
  late Future<List<dynamic>> daftarPemeriksaan;
  final TextEditingController searchController = TextEditingController();

  String kataKunci = '';
  DateTime tanggalFilter = DateTime.now();
  bool semuaData = false;

  static const Color biru = Color(0xFF1769AA);
  static const Color latar = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    muatPemeriksaan();
  }

  void muatPemeriksaan() {
    daftarPemeriksaan = ApiService.getPemeriksaan();
  }

  Future<void> refreshPemeriksaan() async {
    setState(() => muatPemeriksaan());
    await daftarPemeriksaan;
  }

  Future<void> bukaFormTambah() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HalamanTambahPemeriksaan(),
      ),
    );

    if (hasil == true && mounted) {
      setState(() => muatPemeriksaan());
    }
  }

  Future<void> bukaDetail(Map<String, dynamic> data) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanDetailPemeriksaan(pemeriksaan: data),
      ),
    );

    if ((hasil == true || hasil == 'dihapus') && mounted) {
      setState(() => muatPemeriksaan());
    }
  }

  String tanggalKey(dynamic nilai) {
    if (nilai == null || nilai.toString().isEmpty) return '';

    final tanggal = DateTime.tryParse(nilai.toString());
    if (tanggal == null) return '';

    return '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
  }

  String formatTanggal(dynamic nilai) {
    if (nilai == null) return '-';

    final date = DateTime.tryParse(nilai.toString());
    if (date == null) return nilai.toString();

    const bulan = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  String formatTanggalFilter(DateTime tanggal) {
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
      helpText: 'Pilih tanggal pemeriksaan',
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

  List<dynamic> filterPemeriksaan(List<dynamic> data) {
    final berdasarkanTanggal = data.where((item) {
      if (semuaData) return true;

      return tanggalKey(item['tanggal_pemeriksaan']) ==
          tanggalKey(tanggalFilter.toIso8601String());
    }).toList();

    if (kataKunci.trim().isEmpty) return berdasarkanTanggal;

    final keyword = kataKunci.toLowerCase().trim();

    return berdasarkanTanggal.where((item) {
      final pasien = (item['nama_pasien'] ?? '').toString().toLowerCase();
      final dokter = (item['nama_dokter'] ?? '').toString().toLowerCase();
      final diagnosis = (item['diagnosis'] ?? '').toString().toLowerCase();
      final rm = (item['nomor_rm'] ?? '').toString().toLowerCase();

      return pasien.contains(keyword) ||
          dokter.contains(keyword) ||
          diagnosis.contains(keyword) ||
          rm.contains(keyword);
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
          'Data Pemeriksaan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: daftarPemeriksaan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: biru));
          }

          if (snapshot.hasError) return _tampilanError();

          final semuaDataPemeriksaan = snapshot.data ?? [];
          final dataPemeriksaan = filterPemeriksaan(semuaDataPemeriksaan);

          return RefreshIndicator(
            color: biru,
            onRefresh: refreshPemeriksaan,
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
                              'Riwayat Pemeriksaan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Pantau catatan pemeriksaan dan pelayanan pasien.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              '${dataPemeriksaan.length} Pemeriksaan Ditampilkan',
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
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Pemeriksaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Filter berdasarkan tanggal pemeriksaan dan cari catatan.',
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
                          semuaData ? 'Pilih Tanggal' : formatTanggalFilter(tanggalFilter),
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
                    hintText: 'Cari pasien, dokter, atau diagnosis...',
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
                if (dataPemeriksaan.isEmpty)
                  _tampilanKosong()
                else
                  ...dataPemeriksaan.map((item) {
                    final data = Map<String, dynamic>.from(item);
                    final namaPasien = data['nama_pasien']?.toString() ?? '-';
                    final nomorRM = data['nomor_rm']?.toString() ?? '-';
                    final namaDokter = data['nama_dokter']?.toString() ?? '-';
                    final diagnosis = data['diagnosis']?.toString() ?? '-';
                    final tanggal = formatTanggal(data['tanggal_pemeriksaan']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(19),
                          onTap: () => bukaDetail(data),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: const Color(0xFFE9EEF4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F2FC),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.assignment_ind_rounded,
                                        color: biru,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            namaPasien,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF243447),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'No. RM: $nomorRM',
                                            style: const TextStyle(
                                              color: biru,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Divider(height: 1, color: Color(0xFFEEF1F5)),
                                const SizedBox(height: 13),
                                _barisInformasi(Icons.medical_services_outlined, 'Dokter', namaDokter),
                                const SizedBox(height: 10),
                                _barisInformasi(Icons.calendar_month_rounded, 'Tanggal', tanggal),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.health_and_safety_rounded,
                                            color: biru,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            'Diagnosis',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        diagnosis,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF243447),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
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
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Pemeriksaan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _barisInformasi(IconData ikon, String judul, String isi) {
    return Row(
      children: [
        Icon(ikon, size: 17, color: Colors.grey.shade500),
        const SizedBox(width: 9),
        Text(
          '$judul:',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            isi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF243447),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tampilanKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 65, color: Colors.grey.shade400),
          const SizedBox(height: 13),
          Text(
            kataKunci.isNotEmpty
                ? 'Pemeriksaan tidak ditemukan'
                : semuaData
                    ? 'Belum ada pemeriksaan'
                    : 'Tidak ada pemeriksaan pada tanggal ini',
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
              'Gagal memuat data pemeriksaan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => muatPemeriksaan()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
