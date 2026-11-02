<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");
include_once "koneksi.php";

$inputData = json_decode(file_get_contents("php://input"), true);

$username = '';
$password = '';

if (!empty($inputData)) {
    $username = isset($inputData['username']) ? trim($inputData['username']) : '';
    $password = isset($inputData['password']) ? $inputData['password'] : '';
} else {
    $username = isset($_POST['username']) ? trim($_POST['username']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
}

if (empty($username) || empty($password)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username dan password tidak boleh kosong"
    ]);
    exit();
}

if (!isset($conn) || $conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database tidak tersedia"
    ]);
    exit();
}

$query = "SELECT * FROM user WHERE username = ?";
$stmt = $conn->prepare($query);

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyiapkan query database: " . $conn->error
    ]);
    exit();
}

$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    if (password_verify($password, $row['password']) || $password == $row['password']) {
        echo json_encode([
            "status" => "success",
            "message" => "Login berhasil",
            "data" => [
                "id_user" => $row['id_user'],
                "username" => $row['username'],
                "nama_lengkap" => $row['nama_lengkap']
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Password salah"
        ]);
    }
} else {
    echo json_encode([
        "status" => "not_registered",
        "message" => "Akun belum terdaftar, silahkan registrasi terlebih dahulu"
    ]);
}

$stmt->close();
$conn->close();
