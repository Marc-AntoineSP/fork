<?php

declare(strict_types=1);

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