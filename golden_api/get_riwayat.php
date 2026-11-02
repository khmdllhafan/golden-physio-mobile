<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

header("Content-Type: application/json; charset=UTF-8");
include "koneksi.php";

$username = isset($_GET['username']) ? trim($_GET['username']) : '';
$tanggal  = isset($_GET['tanggal']) ? trim($_GET['tanggal']) : '';
$bulan    = isset($_GET['bulan']) ? trim($_GET['bulan']) : '';
$tahun    = isset($_GET['tahun']) ? trim($_GET['tahun']) : '';
$sort     = (isset($_GET['sort']) && strtoupper($_GET['sort']) == 'ASC') ? 'ASC' : 'DESC';

$query = "SELECT p.*, t.nama_lengkap AS nama_terapis 
          FROM pemesanan p 
          LEFT JOIN terapis t ON p.id_terapis = t.id_terapis 
          LEFT JOIN user u ON (p.id_user = u.id_user OR LOWER(p.nama) = LOWER(u.username) OR LOWER(p.nama) = LOWER(u.nama_lengkap))
          WHERE 1=1";

$params = [];
$types  = "";

if (!empty($username)) {
    $query .= " AND (LOWER(u.username) = LOWER(?) OR LOWER(p.nama) = LOWER(?) OR LOWER(u.nama_lengkap) = LOWER(?))";
    $params[] = $username;
    $params[] = $username;
    $params[] = $username;
    $types   .= "sss";
}

if (!empty($tanggal)) {
    $query .= " AND p.tanggal_terapi = ?";
    $params[] = $tanggal;
    $types   .= "s";
}

if (!empty($bulan)) {
    $query .= " AND MONTH(p.tanggal_terapi) = ?";
    $params[] = $bulan;
    $types   .= "i";
}

if (!empty($tahun)) {
    $query .= " AND YEAR(p.tanggal_terapi) = ?";
    $params[] = $tahun;
    $types   .= "i";
}

$query .= " ORDER BY p.tanggal_terapi $sort, p.jam_terapi $sort";

$stmt = $conn->prepare($query);

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyiapkan query: " . $conn->error
    ]);
    exit();
}

if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);

$stmt->close();
$conn->close();
