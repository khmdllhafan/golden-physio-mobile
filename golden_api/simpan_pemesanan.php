<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include "koneksi.php";

$data = json_decode(file_get_contents("php://input"), true);

$nama           = $_POST['nama'] ?? $data['nama'] ?? '';
$no_hp          = $_POST['no_hp'] ?? $data['no_hp'] ?? '';
$alamat         = $_POST['alamat'] ?? $data['alamat'] ?? '';
$id_terapis     = $_POST['id_terapis'] ?? $data['id_terapis'] ?? null;
$tanggal_terapi = $_POST['tanggal_terapi'] ?? $data['tanggal_terapi'] ?? '';
$jam_terapi     = $_POST['jam_terapi'] ?? $data['jam_terapi'] ?? '';
$keluhan        = $_POST['keluhan'] ?? $data['keluhan'] ?? '';
$riwayat_cedera = $_POST['riwayat_cedera'] ?? $data['riwayat_cedera'] ?? '';
$status         = 'Pending';

if (empty($nama) || empty($no_hp) || empty($alamat) || empty($id_terapis) || empty($tanggal_terapi) || empty($jam_terapi)) {
    echo json_encode([
        "status" => "error",
        "message" => "Mohon lengkapi seluruh field formulir."
    ]);
    exit();
}

$stmt = $conn->prepare("INSERT INTO pemesanan (nama, no_hp, alamat, id_terapis, tanggal_terapi, jam_terapi, keluhan, riwayat_cedera, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssisssss", $nama, $no_hp, $alamat, $id_terapis, $tanggal_terapi, $jam_terapi, $keluhan, $riwayat_cedera, $status);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Pemesanan berhasil disimpan!"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyimpan ke database: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
