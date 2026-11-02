<?php
if (ob_get_level()) {
    ob_clean();
}

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include "koneksi.php";

if (!isset($conn) || !$conn) {
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database gagal atau variabel koneksi tidak ditemukan.",
        "data" => []
    ]);
    exit();
}

$query = "SELECT id_terapis, username, nama_lengkap FROM terapis";
$result = mysqli_query($conn, $query);

$data = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            "id_terapis"   => $row['id_terapis'],
            "nama_lengkap" => !empty($row['nama_lengkap']) ? $row['nama_lengkap'] : $row['username']
        ];
    }

    echo json_encode([
        "status" => "success",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode([
        "status" => "error",
        "message" => mysqli_error($conn),
        "data" => []
    ], JSON_UNESCAPED_UNICODE);
}
