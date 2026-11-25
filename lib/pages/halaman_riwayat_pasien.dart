
import 'package:flutter/material.dart';
import '../api_service.dart';

const Color warnaUtama = Color(0xFF1769AA);
const Color warnaGelap = Color(0xFF123B5D);
const Color warnaLatar = Color(0xFFF4F7FB);

class HalamanRiwayatPasien extends StatefulWidget {
  const HalamanRiwayatPasien({super.key});

  @override
  State<HalamanRiwayatPasien> createState() =>
      _HalamanRiwayatPasienState();
}

class _HalamanRiwayatPasienState extends State<HalamanRiwayatPasien> {
  List<dynamic> daftarDokter = [];
  List<dynamic> daftarPemeriksaan = [];

  int dokterTerpilih = -1;
  bool sedangMemuat = true;
  bool semuaData = false;

  DateTime tanggalFilter = DateTime.now();
  String kataKunci = '';

  final pencarianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    muatData();
  }

  @override
  void dispose() {
    pencarianController.dispose();
    super.dispose();
  }

  Future<void> muatData() async {
    if (mounted) setState(() => sedangMemuat = true);

    try {
      final hasil = await Future.wait([
        ApiService.getDokter(),
        ApiService.getPemeriksaan(),
      ]);

      if (!mounted) return;

      setState(() {
        daftarDokter = hasil[0];
        daftarPemeriksaan = hasil[1];

        if (dokterTerpilih != -1 &&
            !daftarDokter.any(
              (item) => item['dokter_id'].toString() ==
                  dokterTerpilih.toString(),
            )) {
          dokterTerpilih = -1;
        }

        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => sedangMemuat = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat riwayat medis: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

    final tanggal = DateTime.tryParse(nilai.toString());
    if (tanggal == null) return nilai.toString();

    const bulan = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
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

  List<dynamic> get dataBerdasarkanFilter {
    final hasil = daftarPemeriksaan.where((item) {
      final cocokTanggal = semuaData ||
          tanggalKey(item['tanggal_pemeriksaan']) ==
              tanggalKey(tanggalFilter.toIso8601String());

      final cocokDokter = dokterTerpilih == -1 ||
          item['dokter_id'].toString() == dokterTerpilih.toString();

      return cocokTanggal && cocokDokter;
    }).toList();

    hasil.sort((a, b) {
      final tanggalA = DateTime.tryParse(
        a['tanggal_pemeriksaan']?.toString() ?? '',
      );
      final tanggalB = DateTime.tryParse(
        b['tanggal_pemeriksaan']?.toString() ?? '',
      );

      if (tanggalA == null || tanggalB == null) return 0;
      return tanggalB.compareTo(tanggalA);
    });

    return hasil;
  }

  List<dynamic> get riwayatTersaring {
    if (kataKunci.trim().isEmpty) return dataBerdasarkanFilter;

    final kata = kataKunci.toLowerCase().trim();

    return dataBerdasarkanFilter.where((item) {
      final namaPasien =
          item['nama_pasien']?.toString().toLowerCase() ?? '';
      final nomorRM = item['nomor_rm']?.toString().toLowerCase() ?? '';
      final dokter = item['nama_dokter']?.toString().toLowerCase() ?? '';
      final keluhan = item['keluhan']?.toString().toLowerCase() ?? '';
      final diagnosis = item['diagnosis']?.toString().toLowerCase() ?? '';
      final tindakan = item['tindakan']?.toString().toLowerCase() ?? '';

      return namaPasien.contains(kata) ||
          nomorRM.contains(kata) ||
          dokter.contains(kata) ||
          keluhan.contains(kata) ||
          diagnosis.contains(kata) ||
          tindakan.contains(kata);
    }).toList();
  }

  Widget bannerRiwayat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [warnaUtama, warnaGelap],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, color: Colors.white, size: 36),
          SizedBox(height: 13),
          Text(
            'Riwayat Medis Pasien',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Lihat catatan pemeriksaan pasien secara terstruktur.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget kartuStatistik() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: warnaUtama,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pemeriksaan',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${dataBerdasarkanFilter.length} Pemeriksaan',
                style: const TextStyle(
                  color: warnaGelap,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget kartuRiwayat(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: warnaUtama,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nama_pasien']?.toString() ?? '-',
                      style: const TextStyle(
                        color: warnaGelap,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. RM: ${data['nomor_rm'] ?? '-'}',
                      style: const TextStyle(
                        color: warnaUtama,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1),
          ),
          informasi('Dokter', data['nama_dokter']),
          informasi('Tanggal Pemeriksaan', formatTanggal(data['tanggal_pemeriksaan'])),
          informasi('Keluhan', data['keluhan']),
          informasi('Diagnosis', data['diagnosis']),
          informasi('Tindakan', data['tindakan']),
        ],
      ),
    );
  }

  Widget informasi(String judul, dynamic nilai) {
    final isi = nilai?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isi.isEmpty ? '-' : isi,
            style: const TextStyle(
              color: warnaGelap,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget keadaanKosong(String pesan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: AppBar(
        title: const Text('Riwayat Pasien'),
        backgroundColor: Colors.white,
        foregroundColor: warnaGelap,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: sedangMemuat ? null : muatData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: muatData,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  bannerRiwayat(),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Dokter',
                    style: TextStyle(
                      color: warnaGelap,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: dokterTerpilih,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.medical_services_outlined,
                        color: warnaUtama,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2EAF2),
                        ),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text('Semua Dokter'),
                      ),
                      ...daftarDokter.map((item) {
                        return DropdownMenuItem<int>(
                          value: int.tryParse(item['dokter_id'].toString()),
                          child: Text(
                            item['nama_dokter']?.toString() ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => dokterTerpilih = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Tanggal Pemeriksaan',
                    style: TextStyle(
                      color: warnaGelap,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pilihTanggal,
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: Text(
                            semuaData
                                ? 'Pilih Tanggal'
                                : formatTanggalFilter(tanggalFilter),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: warnaUtama,
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
                            foregroundColor:
                                semuaData ? Colors.white : warnaUtama,
                            backgroundColor:
                                semuaData ? warnaUtama : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  kartuStatistik(),
                  const SizedBox(height: 22),
                  const Text(
                    'Catatan Pemeriksaan',
                    style: TextStyle(
                      color: warnaGelap,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pencarianController,
                    onChanged: (value) => setState(() => kataKunci = value),
                    decoration: InputDecoration(
                      hintText: 'Cari pasien, RM, dokter, keluhan, diagnosis...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: kataKunci.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                pencarianController.clear();
                                setState(() => kataKunci = '');
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (riwayatTersaring.isEmpty)
                    keadaanKosong(
                      kataKunci.isNotEmpty
                          ? 'Tidak ditemukan catatan yang sesuai pencarian.'
                          : 'Tidak ada riwayat pemeriksaan pada filter yang dipilih.',
                    )
                  else
                    ...riwayatTersaring.map(
                      (item) => kartuRiwayat(
                        Map<String, dynamic>.from(item),
                      ),
                    ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
    );
  }
}
