<?php
declare(strict_types=1);

namespace Php\Src\db;

use PDO;


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

final class Connection {
    public static function connnect():PDO {
        $host = getenv('PMA') ?: '127.0.0.1';
        $port = (int)getenv('PMAPORT') ?: 3306;
        $db = getenv('PMADB') ?:'projet_cube2';
        $user = getenv('PMAUSER') ?:'app';
        $pass = getenv('PMAPASS') ?:'app_password';

        return new PDO(
            "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4",
            $user,
            $pass,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]
        );
    }
}