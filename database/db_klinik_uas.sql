-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 25, 2026 at 10:55 AM
-- Server version: 8.0.30
-- PHP Version: 8.3.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_klinik_uas`
--

-- --------------------------------------------------------

--
-- Table structure for table `dokter`
--

CREATE TABLE `dokter` (
  `dokter_id` int NOT NULL,
  `nama_dokter` varchar(100) NOT NULL,
  `spesialisasi` varchar(100) NOT NULL,
  `nomor_telepon` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `dokter`
--

INSERT INTO `dokter` (`dokter_id`, `nama_dokter`, `spesialisasi`, `nomor_telepon`, `email`) VALUES
(2, 'Dr. Budi Santoso Test', 'Dokter Umum', '081234567891', 'budi@example.com'),
(4, 'Adipati Dolken', 'Dokter Mata', '081234564891', 'adipatidokter@gmail.com'),
(5, 'Dr. Abdillah', 'Spesialis Kejiwaan', '08123456789', 'giebrandokter@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `pasien`
--

CREATE TABLE `pasien` (
  `pasien_id` int NOT NULL,
  `nomor_rm` varchar(20) NOT NULL,
  `nama_pasien` varchar(100) NOT NULL,
  `tanggal_lahir` date NOT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') NOT NULL,
  `nomor_telepon` varchar(20) DEFAULT NULL,
  `alamat` text,
  `tanggal_daftar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pasien`
--

INSERT INTO `pasien` (`pasien_id`, `nomor_rm`, `nama_pasien`, `tanggal_lahir`, `jenis_kelamin`, `nomor_telepon`, `alamat`, `tanggal_daftar`) VALUES
(2, 'RM002', 'Andi Saputra', '2000-05-15', 'Laki-laki', '081234567890', 'Karawang, Jawa Barat', NULL),
(4, 'RM003', 'Giebran Abdillah', '2005-07-14', 'Laki-laki', '859531708855', 'Karawang', '2026-11-08'),
(5, 'RM004', 'Salsa', '2005-08-28', 'Perempuan', '089876543211', 'Karawang Timur', '2026-11-08'),
(6, 'RM005', 'Theo', '2000-01-15', 'Laki-laki', '0811111122', 'Tegal sawah', '2026-11-08');

-- --------------------------------------------------------

--
-- Table structure for table `pemeriksaan`
--

CREATE TABLE `pemeriksaan` (
  `pemeriksaan_id` int NOT NULL,
  `pasien_id` int NOT NULL,
  `dokter_id` int NOT NULL,
  `tanggal_pemeriksaan` datetime NOT NULL,
  `keluhan` text NOT NULL,
  `diagnosis` text NOT NULL,
  `tindakan` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pemeriksaan`
--

INSERT INTO `pemeriksaan` (`pemeriksaan_id`, `pasien_id`, `dokter_id`, `tanggal_pemeriksaan`, `keluhan`, `diagnosis`, `tindakan`) VALUES
(3, 2, 2, '2026-11-03 08:04:00', 'sakit perut sejak kemarin ', 'gangguan pencernaan ', 'pemerikasaan umum dan pemberian edukasi '),
(4, 4, 4, '2026-11-08 14:36:00', 'sakit perut', 'asam lambung', 'pemeriksaan umum dan pemberian obat kapsul'),
(5, 5, 2, '2026-11-08 15:27:00', 'nyeri betis', 'ketegangan otot', 'terapi saja'),
(6, 6, 2, '2026-11-08 15:40:00', 'sakit kepala', 'migren', 'obat resep dokter');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `dokter`
--
ALTER TABLE `dokter`
  ADD PRIMARY KEY (`dokter_id`);

--
-- Indexes for table `pasien`
--
ALTER TABLE `pasien`
  ADD PRIMARY KEY (`pasien_id`),
  ADD UNIQUE KEY `nomor_rm` (`nomor_rm`);

--
-- Indexes for table `pemeriksaan`
--
ALTER TABLE `pemeriksaan`
  ADD PRIMARY KEY (`pemeriksaan_id`),
  ADD KEY `pasien_id` (`pasien_id`),
  ADD KEY `dokter_id` (`dokter_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dokter`
--
ALTER TABLE `dokter`
  MODIFY `dokter_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pasien`
--
ALTER TABLE `pasien`
  MODIFY `pasien_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `pemeriksaan`
--
ALTER TABLE `pemeriksaan`
  MODIFY `pemeriksaan_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pemeriksaan`
--
ALTER TABLE `pemeriksaan`
  ADD CONSTRAINT `pemeriksaan_ibfk_1` FOREIGN KEY (`pasien_id`) REFERENCES `pasien` (`pasien_id`),
  ADD CONSTRAINT `pemeriksaan_ibfk_2` FOREIGN KEY (`dokter_id`) REFERENCES `dokter` (`dokter_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
