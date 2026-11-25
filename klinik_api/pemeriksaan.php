
<?php
require_once 'koneksi.php';

header("Content-Type: application/json; charset=UTF-8");

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {

    $query = mysqli_query(
        $koneksi,
        "SELECT
            pemeriksaan.pemeriksaan_id,
            pemeriksaan.pasien_id,
            pasien.nama_pasien,
            pasien.nomor_rm,
            pemeriksaan.dokter_id,
            dokter.nama_dokter,
            pemeriksaan.tanggal_pemeriksaan,
            pemeriksaan.keluhan,
            pemeriksaan.diagnosis,
            pemeriksaan.tindakan
        FROM pemeriksaan
        JOIN pasien ON pemeriksaan.pasien_id = pasien.pasien_id
        JOIN dokter ON pemeriksaan.dokter_id = dokter.dokter_id
        ORDER BY pemeriksaan.pemeriksaan_id DESC"
    );

    if ($query) {
        $data = [];

        while ($row = mysqli_fetch_assoc($query)) {
            $data[] = $row;
        }

        echo json_encode([
            "status" => true,
            "pesan" => "Data pemeriksaan berhasil diambil",
            "data" => $data
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal mengambil data pemeriksaan"
        ]);
    }

} elseif ($method == 'POST') {

    $input = json_decode(file_get_contents("php://input"), true);

    $pasien_id = $input['pasien_id'] ?? 0;
    $dokter_id = $input['dokter_id'] ?? 0;
    $tanggal_pemeriksaan = $input['tanggal_pemeriksaan'] ?? '';
    $keluhan = $input['keluhan'] ?? '';
    $diagnosis = $input['diagnosis'] ?? '';
    $tindakan = $input['tindakan'] ?? '';

    if (
        $pasien_id <= 0 ||
        $dokter_id <= 0 ||
        $tanggal_pemeriksaan == '' ||
        $keluhan == '' ||
        $diagnosis == ''
    ) {
        echo json_encode([
            "status" => false,
            "pesan" => "Data wajib pemeriksaan harus diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "INSERT INTO pemeriksaan
        (pasien_id, dokter_id, tanggal_pemeriksaan, keluhan, diagnosis, tindakan)
        VALUES (?, ?, ?, ?, ?, ?)"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "iissss",
        $pasien_id,
        $dokter_id,
        $tanggal_pemeriksaan,
        $keluhan,
        $diagnosis,
        $tindakan
    );

    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "status" => true,
            "pesan" => "Data pemeriksaan berhasil ditambahkan"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menambahkan data pemeriksaan"
        ]);
    }

    mysqli_stmt_close($stmt);

} elseif ($method == 'PUT') {

    $input = json_decode(file_get_contents("php://input"), true);

    $pemeriksaan_id = $input['pemeriksaan_id'] ?? 0;
    $pasien_id = $input['pasien_id'] ?? 0;
    $dokter_id = $input['dokter_id'] ?? 0;
    $tanggal_pemeriksaan = $input['tanggal_pemeriksaan'] ?? '';
    $keluhan = $input['keluhan'] ?? '';
    $diagnosis = $input['diagnosis'] ?? '';
    $tindakan = $input['tindakan'] ?? '';

    if (
        $pemeriksaan_id <= 0 ||
        $pasien_id <= 0 ||
        $dokter_id <= 0 ||
        $tanggal_pemeriksaan == '' ||
        $keluhan == '' ||
        $diagnosis == ''
    ) {
        echo json_encode([
            "status" => false,
            "pesan" => "Data pemeriksaan wajib diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "UPDATE pemeriksaan
        SET pasien_id = ?, dokter_id = ?, tanggal_pemeriksaan = ?,
            keluhan = ?, diagnosis = ?, tindakan = ?
        WHERE pemeriksaan_id = ?"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "iissssi",
        $pasien_id,
        $dokter_id,
        $tanggal_pemeriksaan,
        $keluhan,
        $diagnosis,
        $tindakan,
        $pemeriksaan_id
    );

    if (mysqli_stmt_execute($stmt)) {
        if (mysqli_stmt_affected_rows($stmt) > 0) {
            echo json_encode([
                "status" => true,
                "pesan" => "Data pemeriksaan berhasil diperbarui"
            ]);
        } else {
            echo json_encode([
                "status" => false,
                "pesan" => "Data pemeriksaan tidak ditemukan atau tidak ada perubahan"
            ]);
        }
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal memperbarui data pemeriksaan"
        ]);
    }

    mysqli_stmt_close($stmt);

} elseif ($method == 'DELETE') {

    $input = json_decode(file_get_contents("php://input"), true);
    $pemeriksaan_id = $input['pemeriksaan_id'] ?? 0;

    if ($pemeriksaan_id <= 0) {
        echo json_encode([
            "status" => false,
            "pesan" => "ID pemeriksaan wajib diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "DELETE FROM pemeriksaan WHERE pemeriksaan_id = ?"
    );

    mysqli_stmt_bind_param($stmt, "i", $pemeriksaan_id);

    if (mysqli_stmt_execute($stmt)) {
        if (mysqli_stmt_affected_rows($stmt) > 0) {
            echo json_encode([
                "status" => true,
                "pesan" => "Data pemeriksaan berhasil dihapus"
            ]);
        } else {
            echo json_encode([
                "status" => false,
                "pesan" => "Data pemeriksaan tidak ditemukan"
            ]);
        }
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menghapus data pemeriksaan"
        ]);
    }

    mysqli_stmt_close($stmt);
}
?>