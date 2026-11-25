
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'halaman_pasien.dart';
import 'halaman_dokter.dart';
import 'halaman_pemeriksaan.dart';
import 'halaman_riwayat_pasien.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late Future<_DataDashboard> dataDashboard;

  @override
  void initState() {
    super.initState();
    muatDashboard();
  }

  void muatDashboard() {
    dataDashboard = ambilDataDashboard();
  }

  Future<_DataDashboard> ambilDataDashboard() async {
    final hasil = await Future.wait<List<dynamic>>([
      ApiService.getPasien(),
      ApiService.getDokter(),
      ApiService.getPemeriksaan(),
    ]);

    return _DataDashboard(
      pasien: hasil[0],
      dokter: hasil[1],
      pemeriksaan: hasil[2],
    );
  }

  Future<void> bukaHalaman(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => halaman),
    );

    if (!mounted) return;

    setState(() {
      muatDashboard();
    });
  }

  String formatTanggal(dynamic nilai) {
    if (nilai == null) return '-';

    final tanggal = DateTime.tryParse(nilai.toString());
    if (tanggal == null) return nilai.toString();

    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF1769AA),
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Klinik Sehat',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                Text(
                  'Sistem Manajemen Klinik',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () {
              setState(() {
                muatDashboard();
              });
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF1769AA),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<_DataDashboard>(
        future: dataDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 54,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Data dashboard belum dapat dimuat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          muatDashboard();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          final pemeriksaanTerbaru =
              List<dynamic>.from(data.pemeriksaan);

          pemeriksaanTerbaru.sort((a, b) {
            final tanggalA = DateTime.tryParse(
                  a['tanggal_pemeriksaan']?.toString() ?? '',
                ) ??
                DateTime(2000);

            final tanggalB = DateTime.tryParse(
                  b['tanggal_pemeriksaan']?.toString() ?? '',
                ) ??
                DateTime(2000);

            return tanggalB.compareTo(tanggalA);
          });

          final tigaTerbaru = pemeriksaanTerbaru.take(3).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                muatDashboard();
              });
              await dataDashboard;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1769AA),
                        Color(0xFF123B5D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1769AA)
                            .withValues(alpha: 0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELAMAT DATANG',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Kelola Klinik\nLebih Mudah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                height: 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pantau data dan aktivitas pelayanan klinik dalam satu aplikasi.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 43,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Ringkasan Klinik',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Informasi data yang tersimpan saat ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _KartuStatistik(
                        judul: 'Pasien',
                        jumlah: data.pasien.length,
                        ikon: Icons.people_alt_rounded,
                        warna: const Color(0xFF1976D2),
                        latar: const Color(0xFFE7F1FB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _KartuStatistik(
                        judul: 'Dokter',
                        jumlah: data.dokter.length,
                        ikon: Icons.medical_services_rounded,
                        warna: const Color(0xFF16866A),
                        latar: const Color(0xFFE5F5EF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _KartuStatistik(
                        judul: 'Periksa',
                        jumlah: data.pemeriksaan.length,
                        ikon: Icons.assignment_rounded,
                        warna: const Color(0xFFE18A28),
                        latar: const Color(0xFFFFF2DF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 27),

                const Text(
                  'Menu Layanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pilih layanan yang ingin dikelola',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.38,
                  children: [
                    _KartuMenu(
                      judul: 'Data Pasien',
                      deskripsi: 'Kelola data pasien',
                      ikon: Icons.people_alt_rounded,
                      warna: const Color(0xFF1976D2),
                      latar: const Color(0xFFE7F1FB),
                      onTap: () => bukaHalaman(
                        const HalamanPasien(),
                      ),
                    ),
                    _KartuMenu(
                      judul: 'Data Dokter',
                      deskripsi: 'Kelola data dokter',
                      ikon: Icons.medical_services_rounded,
                      warna: const Color(0xFF16866A),
                      latar: const Color(0xFFE5F5EF),
                      onTap: () => bukaHalaman(
                        const HalamanDokter(),
                      ),
                    ),
                    _KartuMenu(
                      judul: 'Pemeriksaan',
                      deskripsi: 'Catat pemeriksaan',
                      ikon: Icons.assignment_rounded,
                      warna: const Color(0xFFE18A28),
                      latar: const Color(0xFFFFF2DF),
                      onTap: () => bukaHalaman(
                        const HalamanPemeriksaan(),
                      ),
                    ),
                    _KartuMenu(
                      judul: 'Riwayat Pasien',
                      deskripsi: 'Lihat riwayat medis',
                      ikon: Icons.history_rounded,
                      warna: const Color(0xFF7955B5),
                      latar: const Color(0xFFF0EAFE),
                      onTap: () => bukaHalaman(
                        const HalamanRiwayatPasien(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 27),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pemeriksaan Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF243447),
                      ),
                    ),
                    TextButton(
                      onPressed: () => bukaHalaman(
                        const HalamanPemeriksaan(),
                      ),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (tigaTerbaru.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 38,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada pemeriksaan',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...tigaTerbaru.map((pemeriksaan) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEDF0F5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        leading: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F1FB),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            color: Color(0xFF1769AA),
                          ),
                        ),
                        title: Text(
                          pemeriksaan['nama_pasien']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF243447),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Dr. ${pemeriksaan['nama_dokter'] ?? '-'}\n'
                            '${formatTanggal(pemeriksaan['tanggal_pemeriksaan'])}',
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                        onTap: () => bukaHalaman(
                          const HalamanPemeriksaan(),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DataDashboard {
  final List<dynamic> pasien;
  final List<dynamic> dokter;
  final List<dynamic> pemeriksaan;

  const _DataDashboard({
    required this.pasien,
    required this.dokter,
    required this.pemeriksaan,
  });
}

class _KartuStatistik extends StatelessWidget {
  final String judul;
  final int jumlah;
  final IconData ikon;
  final Color warna;
  final Color latar;

  const _KartuStatistik({
    required this.judul,
    required this.jumlah,
    required this.ikon,
    required this.warna,
    required this.latar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEDF0F5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              ikon,
              color: warna,
              size: 19,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            jumlah.toString(),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243447),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            judul,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuMenu extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
  final Color latar;
  final VoidCallback onTap;

  const _KartuMenu({
    required this.judul,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
    required this.latar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFEDF0F5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: latar,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  ikon,
                  color: warna,
                  size: 23,
                ),
              ),
              const Spacer(),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243447),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                deskripsi,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
