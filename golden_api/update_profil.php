<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json");
include "koneksi.php";

$old_username = isset($_POST['old_username']) ? trim($_POST['old_username']) : '';
$username     = isset($_POST['username']) ? trim($_POST['username']) : '';
$no_hp        = isset($_POST['no_hp']) ? trim($_POST['no_hp']) : '';
$alamat       = isset($_POST['alamat']) ? trim($_POST['alamat']) : '';
$password     = isset($_POST['password']) ? trim($_POST['password']) : '';

if (empty($old_username)) {
    $old_username = $username;
}

if (empty($old_username) || empty($no_hp) || empty($alamat)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username, No HP, dan Alamat tidak boleh kosong."
    ]);
    exit();
}

if (!empty($password)) {
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $query = "UPDATE user SET username = ?, no_hp = ?, alamat = ?, password = ? WHERE username = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("sssss", $username, $no_hp, $alamat, $hashed_password, $old_username);
} else {
    $query = "UPDATE user SET username = ?, no_hp = ?, alamat = ? WHERE username = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ssss", $username, $no_hp, $alamat, $old_username);
}

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Profil berhasil diperbarui!"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal memperbarui profil: " . $conn->error
    ]);
}

$stmt->close();
$conn->close();
