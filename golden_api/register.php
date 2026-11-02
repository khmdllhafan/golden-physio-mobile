<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");
include "koneksi.php";

$input_data = json_decode(file_get_contents('php://input'), true);

$username      = isset($input_data['username']) ? trim($input_data['username']) : (isset($_POST['username']) ? trim($_POST['username']) : '');
$password      = isset($input_data['password']) ? $input_data['password'] : (isset($_POST['password']) ? $_POST['password'] : '');
$nama_lengkap  = isset($input_data['nama_lengkap']) ? trim($input_data['nama_lengkap']) : (isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : '');
$tanggal_lahir = isset($input_data['tanggal_lahir']) ? trim($input_data['tanggal_lahir']) : (isset($_POST['tanggal_lahir']) ? trim($_POST['tanggal_lahir']) : '');
$jenis_kelamin = isset($input_data['jenis_kelamin']) ? trim($input_data['jenis_kelamin']) : (isset($_POST['jenis_kelamin']) ? trim($_POST['jenis_kelamin']) : '');
$alamat        = isset($input_data['alamat']) ? trim($input_data['alamat']) : (isset($_POST['alamat']) ? trim($_POST['alamat']) : '');
$no_hp         = isset($input_data['no_hp']) ? trim($input_data['no_hp']) : (isset($_POST['no_hp']) ? trim($_POST['no_hp']) : '');

if (empty($username) || empty($password) || empty($nama_lengkap)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username, password, dan nama lengkap wajib diisi!"
    ]);
    exit();
}

if (!isset($conn) || $conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database belum terhubung dengan benar."
    ]);
    exit();
}

$check = $conn->prepare("SELECT id_user FROM user WHERE username = ?");
if (!$check) {
    echo json_encode([
        "status" => "error",
        "message" => "Prepare statement error: " . $conn->error
    ]);
    exit();
}

$check->bind_param("s", $username);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Username sudah digunakan, silakan pilih yang lain."
    ]);
    $check->close();
    $conn->close();
    exit();
}
$check->close();

$hashed_password = password_hash($password, PASSWORD_DEFAULT);

$stmt = $conn->prepare("INSERT INTO user (username, password, nama_lengkap, tanggal_lahir, jenis_kelamin, alamat, no_hp) VALUES (?, ?, ?, ?, ?, ?, ?)");
if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Prepare insert error: " . $conn->error
    ]);
    exit();
}

$stmt->bind_param("sssssss", $username, $hashed_password, $nama_lengkap, $tanggal_lahir, $jenis_kelamin, $alamat, $no_hp);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Registrasi berhasil! Silakan login."
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyimpan ke database: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
