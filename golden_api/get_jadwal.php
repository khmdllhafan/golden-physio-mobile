<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");

include "koneksi.php";

if (!isset($conn) || $conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database gagal."
    ]);
    exit();
}

$tanggal = isset($_GET['tanggal']) ? trim($_GET['tanggal']) : date('Y-m-d');

if (!preg_match("/^\d{4}-\d{2}-\d{2}$/", $tanggal)) {
    $tanggal = date('Y-m-d');
}

$query = "SELECT p.*, t.nama_lengkap AS nama_terapis 
          FROM pemesanan p 
          LEFT JOIN terapis t ON p.id_terapis = t.id_terapis 
          WHERE p.tanggal_terapi = ? 
          ORDER BY p.jam_terapi ASC";

$stmt = $conn->prepare($query);

if ($stmt) {
    $stmt->bind_param("s", $tanggal);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "tanggal_filter" => $tanggal,
        "data" => $data
    ]);

    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyiapkan query database."
    ]);
}

$conn->close();
