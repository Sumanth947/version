<?php
$host = "localhost";  // Change if necessary
$user = "root";       // Change if necessary
$password = "";       // Change if necessary
$database = "postman_test"; // Change to your actual database name

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
} else {
    echo "Database connection successful!";
}

$conn->close();
?>
