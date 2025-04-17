<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$servername = "localhost"; 
$username = "root"; 
$password = ""; 
$database = ""; 

try {
    // First try to connect without database to check credentials
    $conn = new mysqli($servername, $username, $password);
    
    if ($conn->connect_error) {
        throw new Exception("Initial connection failed: " . $conn->connect_error);
    }
    
    // Try to create database if it doesn't exist
    $conn->query("CREATE DATABASE IF NOT EXISTS $database");
    $conn->select_db($database);
    
    // Create table if it doesn't exist
    $conn->query("CREATE TABLE IF NOT EXISTS app_settings (
        id INT PRIMARY KEY AUTO_INCREMENT,
        minimum_version VARCHAR(10) NOT NULL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )");
    
    // Insert default data if not exists
    $conn->query("INSERT IGNORE INTO app_settings (id, minimum_version) VALUES (1, '2.0.0')");
    
    $sql = "SELECT minimum_version FROM app_settings LIMIT 1";
    $result = $conn->query($sql);

    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }

    $row = $result->fetch_assoc();

    if (!$row) {
        throw new Exception("No data found in app_settings table");
    }

    // Return the minimum version
    echo json_encode([
        "minimum_version" => $row["minimum_version"],
        "status" => "success"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "error" => $e->getMessage(),
        "status" => "error",
        "server" => $servername,
        "database" => $database,
        "username" => $username
    ]);
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}
?>
