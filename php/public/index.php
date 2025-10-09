<?php

declare(strict_types=1);
require __DIR__ ."/../vendor/autoload.php";

function pdo_sql():PDO{
    $dsn  = 'mysql:host=127.0.0.1;port=3306;dbname=projet_cube2;charset=utf8mb4';
    $user = 'app';
    $pass = 'app_password';
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]);
    return $pdo;
}

// REQUETES : 

// Consulter la liste :

function users_list():array{
    $pdo = pdo_sql();
    $sql = 'SELECT id, username, hash_password, created_at FROM Users';
    $users = $pdo->query($sql)->fetchAll();
    return $users;
}

// API :

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

header('Content-Type:application/json');

switch(true){
    case $method == 'GET' && $path == '/':
        $userlist = users_list();
        echo json_encode(['data'=> $userlist]);
        exit;
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}