
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'detail_dokter.dart';
import 'form_dokter.dart';

class HalamanDokter extends StatefulWidget {
  const HalamanDokter({super.key});

  @override
  State<HalamanDokter> createState() => _HalamanDokterState();
}

class _HalamanDokterState extends State<HalamanDokter> {
  late Future<List<dynamic>> daftarDokter;
  final TextEditingController searchController = TextEditingController();
  String kataKunci = '';

  static const Color biru = Color(0xFF1769AA);
  static const Color latar = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    muatDokter();
  }

  void muatDokter() {
    daftarDokter = ApiService.getDokter();
  }

  Future<void> refreshDokter() async {
    setState(() {
      muatDokter();
    });
    await daftarDokter;
  }

  Future<void> bukaFormTambah() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HalamanTambahDokter(),
      ),
    );

    if (hasil == true && mounted) {
      setState(() {
        muatDokter();
      });
    }
  }

  Future<void> bukaDetailDokter(Map<String, dynamic> data) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanDetailDokter(data: data),
      ),
    );

    if (hasil == true && mounted) {
      setState(() {
        muatDokter();
      });
    }
  }

  List<dynamic> filterDokter(List<dynamic> data) {
    if (kataKunci.isEmpty) return data;

    return data.where((dokter) {
      final nama = (dokter['nama_dokter'] ?? '')
          .toString()
          .toLowerCase();
      final spesialisasi = (dokter['spesialisasi'] ?? '')
          .toString()
          .toLowerCase();

      return nama.contains(kataKunci.toLowerCase()) ||
          spesialisasi.contains(kataKunci.toLowerCase());
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
          'Data Dokter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: daftarDokter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: biru),
            );
          }

          if (snapshot.hasError) {
            return _tampilanError();
          }

          final semuaDokter = snapshot.data ?? [];
          final dokter = filterDokter(semuaDokter);

          return RefreshIndicator(
            color: biru,
            onRefresh: refreshDokter,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1769AA),
                        Color(0xFF2689CB),
                      ],
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
                              'Manajemen Dokter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Kelola informasi dokter yang bertugas di klinik.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 17),
                            Text(
                              '${semuaDokter.length} Dokter Terdaftar',
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
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Dokter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Cari dan lihat informasi tenaga medis klinik.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      kataKunci = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau spesialisasi dokter...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: biru,
                    ),
                    suffixIcon: kataKunci.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                kataKunci = '';
                              });
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
                      borderSide: const BorderSide(
                        color: Color(0xFFE7ECF2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                if (dokter.isEmpty)
                  _tampilanKosong()
                else
                  ...dokter.map((item) {
                    final data = Map<String, dynamic>.from(item);

                    final nama = data['nama_dokter']?.toString() ?? '-';
                    final spesialisasi =
                        data['spesialisasi']?.toString() ?? '-';
                    final telepon =
                        data['nomor_telepon']?.toString() ?? '-';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(19),
                          onTap: () => bukaDetailDokter(data),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                color: const Color(0xFFE9EEF4),
                              ),
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
                                    Icons.medical_services_rounded,
                                    color: biru,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        spesialisasi,
                                        style: const TextStyle(
                                          color: biru,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        telepon,
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
          'Tambah Dokter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _tampilanKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          Icon(
            Icons.medical_information_rounded,
            size: 65,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 13),
          Text(
            kataKunci.isEmpty
                ? 'Belum ada data dokter'
                : 'Dokter tidak ditemukan',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243447),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kataKunci.isEmpty
                ? 'Data dokter akan muncul di sini.'
                : 'Coba gunakan nama atau spesialisasi lainnya.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
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
            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data dokter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  muatDokter();
                });
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
