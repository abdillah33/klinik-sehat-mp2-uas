
<?php
require_once 'koneksi.php';

header("Content-Type: application/json; charset=UTF-8");

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {

    $query = mysqli_query($koneksi, "SELECT * FROM dokter");

    if ($query) {
        $data = [];

        while ($row = mysqli_fetch_assoc($query)) {
            $data[] = $row;
        }

        echo json_encode([
            "status" => true,
            "pesan" => "Data dokter berhasil diambil",
            "data" => $data
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal mengambil data dokter"
        ]);
    }

} elseif ($method == 'POST') {

    $input = json_decode(file_get_contents("php://input"), true);

    $nama_dokter = $input['nama_dokter'] ?? '';
    $spesialisasi = $input['spesialisasi'] ?? '';
    $nomor_telepon = $input['nomor_telepon'] ?? '';
    $email = $input['email'] ?? '';

    if ($nama_dokter == '' || $spesialisasi == '') {
        echo json_encode([
            "status" => false,
            "pesan" => "Nama dokter dan spesialisasi wajib diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "INSERT INTO dokter (nama_dokter, spesialisasi, nomor_telepon, email) VALUES (?, ?, ?, ?)"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "ssss",
        $nama_dokter,
        $spesialisasi,
        $nomor_telepon,
        $email
    );

    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "status" => true,
            "pesan" => "Data dokter berhasil ditambahkan"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menambahkan data dokter"
        ]);
    }

    mysqli_stmt_close($stmt);

} elseif ($method == 'PUT') {

    $input = json_decode(file_get_contents("php://input"), true);

    $dokter_id = $input['dokter_id'] ?? 0;
    $nama_dokter = $input['nama_dokter'] ?? '';
    $spesialisasi = $input['spesialisasi'] ?? '';
    $nomor_telepon = $input['nomor_telepon'] ?? '';
    $email = $input['email'] ?? '';

    if ($dokter_id <= 0 || $nama_dokter == '' || $spesialisasi == '') {
        echo json_encode([
            "status" => false,
            "pesan" => "ID dokter, nama dokter, dan spesialisasi wajib diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "UPDATE dokter SET nama_dokter = ?, spesialisasi = ?, nomor_telepon = ?, email = ? WHERE dokter_id = ?"
    );

    mysqli_stmt_bind_param(
        $stmt,
        "ssssi",
        $nama_dokter,
        $spesialisasi,
        $nomor_telepon,
        $email,
        $dokter_id
    );

    if (mysqli_stmt_execute($stmt)) {
        if (mysqli_stmt_affected_rows($stmt) > 0) {
            echo json_encode([
                "status" => true,
                "pesan" => "Data dokter berhasil diperbarui"
            ]);
        } else {
            echo json_encode([
                "status" => false,
                "pesan" => "Data dokter tidak ditemukan atau tidak ada perubahan"
            ]);
        }
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal memperbarui data dokter"
        ]);
    }

    mysqli_stmt_close($stmt);
}

elseif ($method == 'DELETE') {

    $input = json_decode(file_get_contents("php://input"), true);

    $dokter_id = $input['dokter_id'] ?? 0;

    if ($dokter_id <= 0) {
        echo json_encode([
            "status" => false,
            "pesan" => "ID dokter wajib diisi"
        ]);
        exit;
    }

    $stmt = mysqli_prepare(
        $koneksi,
        "DELETE FROM dokter WHERE dokter_id = ?"
    );

    mysqli_stmt_bind_param($stmt, "i", $dokter_id);

    if (mysqli_stmt_execute($stmt)) {
        if (mysqli_stmt_affected_rows($stmt) > 0) {
            echo json_encode([
                "status" => true,
                "pesan" => "Data dokter berhasil dihapus"
            ]);
        } else {
            echo json_encode([
                "status" => false,
                "pesan" => "Data dokter tidak ditemukan"
            ]);
        }
    } else {
        echo json_encode([
            "status" => false,
            "pesan" => "Gagal menghapus data dokter"
        ]);
    }

    mysqli_stmt_close($stmt);
}

?>