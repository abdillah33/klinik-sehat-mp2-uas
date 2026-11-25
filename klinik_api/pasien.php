
<?php
require_once 'koneksi.php';

header("Content-Type: application/json; charset=UTF-8");

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {

    $query = mysqli_query($koneksi, "SELECT * FROM pasien ORDER BY pasien_id DESC");

    if ($query) {
        $data = [];

        while ($row = mysqli_fetch_assoc($query)) {
            $data[] = $row;
        }

        echo json_encode([
            "status" => true,
            "pesan" => "Data pasien berhasil diambil",
            "data" => $data
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal mengambil data pasien"
        ]);
    }

} elseif ($method == 'POST') {

    $input = json_decode(file_get_contents("php://input"), true);

    $nomor_rm = $input['nomor_rm'] ?? '';
    $nama_pasien = $input['nama_pasien'] ?? '';
    $tanggal_lahir = $input['tanggal_lahir'] ?? '';
    $jenis_kelamin = $input['jenis_kelamin'] ?? '';
    $nomor_telepon = $input['nomor_telepon'] ?? '';
    $alamat = $input['alamat'] ?? '';

    if (
        $nomor_rm == '' ||
        $nama_pasien == '' ||
        $tanggal_lahir == '' ||
        !in_array($jenis_kelamin, ['Laki-laki', 'Perempuan'], true)
    ) {
        echo json_encode([
            "status" => false,
            "pesan" => "Data wajib belum lengkap atau jenis kelamin tidak valid"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "INSERT INTO pasien
        (nomor_rm, nama_pasien, tanggal_lahir, jenis_kelamin, nomor_telepon, alamat, tanggal_daftar)
        VALUES (?, ?, ?, ?, ?, ?, CURDATE())"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "ssssss",
        $nomor_rm,
        $nama_pasien,
        $tanggal_lahir,
        $jenis_kelamin,
        $nomor_telepon,
        $alamat
    );

    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "status" => true,
            "pesan" => "Data pasien berhasil ditambahkan"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menambahkan data pasien"
        ]);
    }

    mysqli_stmt_close($stmt);

} elseif ($method == 'PUT') {

    $input = json_decode(file_get_contents("php://input"), true);

    $pasien_id = $input['pasien_id'] ?? '';
    $nomor_rm = $input['nomor_rm'] ?? '';
    $nama_pasien = $input['nama_pasien'] ?? '';
    $tanggal_lahir = $input['tanggal_lahir'] ?? '';
    $jenis_kelamin = $input['jenis_kelamin'] ?? '';
    $nomor_telepon = $input['nomor_telepon'] ?? '';
    $alamat = $input['alamat'] ?? '';

    if (
        $pasien_id == '' ||
        $nomor_rm == '' ||
        $nama_pasien == '' ||
        $tanggal_lahir == '' ||
        !in_array($jenis_kelamin, ['Laki-laki', 'Perempuan'], true)
    ) {
        echo json_encode([
            "status" => false,
            "pesan" => "Data wajib belum lengkap atau jenis kelamin tidak valid"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "UPDATE pasien
        SET nomor_rm = ?, nama_pasien = ?, tanggal_lahir = ?,
            jenis_kelamin = ?, nomor_telepon = ?, alamat = ?
        WHERE pasien_id = ?"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "ssssssi",
        $nomor_rm,
        $nama_pasien,
        $tanggal_lahir,
        $jenis_kelamin,
        $nomor_telepon,
        $alamat,
        $pasien_id
    );

    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "status" => true,
            "pesan" => "Data pasien berhasil diperbarui"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal memperbarui data pasien"
        ]);
    }

    mysqli_stmt_close($stmt);

} elseif ($method == 'DELETE') {

    $input = json_decode(file_get_contents("php://input"), true);

    $pasien_id = $input['pasien_id'] ?? '';

    if ($pasien_id == '') {
        echo json_encode([
            "status" => false,
            "pesan" => "ID pasien harus diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "DELETE FROM pasien WHERE pasien_id = ?"
    );

    mysqli_stmt_bind_param($stmt, "i", $pasien_id);

    if (mysqli_stmt_execute($stmt)) {

        if (mysqli_stmt_affected_rows($stmt) > 0) {
            echo json_encode([
                "status" => true,
                "pesan" => "Data pasien berhasil dihapus"
            ]);
        } else {
            echo json_encode([
                "status" => false,
                "pesan" => "Data pasien tidak ditemukan"
            ]);
        }

    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menghapus data pasien"
        ]);
    }

    mysqli_stmt_close($stmt);
}
?>
