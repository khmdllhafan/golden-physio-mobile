<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");
include "koneksi.php";

$username = isset($_GET['username']) ? trim($_GET['username']) : '';

if (empty($username)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username tidak ditemukan"
    ]);
    exit();
}

if (!isset($conn) || $conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database gagal"
    ]);
    exit();
}

$stmt = $conn->prepare("SELECT * FROM user WHERE username = ?");
if ($stmt) {
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        echo json_encode([
            "status" => "success",
            "user" => $row
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "User tidak ditemukan"
        ]);
    }

    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyiapkan kueri database"
    ]);
}

$conn->close();
