<?php
header("Content-Type: application/json");
include 'koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username         = isset($_POST['username']) ? trim($_POST['username']) : '';
    $nama_lengkap     = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : '';
    $tanggal_lahir    = isset($_POST['tanggal_lahir']) ? trim($_POST['tanggal_lahir']) : '';
    $password         = isset($_POST['password']) ? $_POST['password'] : '';
    $confirm_password = isset($_POST['confirm_password']) ? $_POST['confirm_password'] : '';

    if (empty($username) || empty($nama_lengkap) || empty($tanggal_lahir) || empty($password) || empty($confirm_password)) {
        echo json_encode([
            "status" => "error",
            "message" => "Semua kolom wajib diisi!"
        ]);
        exit();
    }

    if ($password !== $confirm_password) {
        echo json_encode([
            "status" => "error",
            "message" => "Password dan Konfirmasi Password tidak cocok!"
        ]);
        exit();
    }

    $stmt = $conn->prepare("SELECT id_user FROM pasien WHERE username = ? AND nama_lengkap = ? AND tanggal_lahir = ?");
    $stmt->bind_param("sss", $username, $nama_lengkap, $tanggal_lahir);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $id_user = $row['id_user'];

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        $update_stmt = $conn->prepare("UPDATE pasien SET password = ? WHERE id_user = ?");
        $update_stmt->bind_param("si", $hashed_password, $id_user);

        if ($update_stmt->execute()) {
            echo json_encode([
                "status" => "success",
                "message" => "Password berhasil diubah!"
            ]);
        } else {
            echo json_encode([
                "status" => "error",
                "message" => "Gagal memperbarui password ke database."
            ]);
        }

        $update_stmt->close();
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Data diri (Username, Nama Lengkap, atau Tanggal Lahir) tidak ditemukan!"
        ]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Metode request tidak valid!"
    ]);
}
