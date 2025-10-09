<?php

declare(strict_types=1);

function pdo_pg():PDO{
    $dsn = sprintf(
        "pgsql:host=%s;port=%s;dbname=%s",
        getenv("PMAHOST") ?: '127.0.0.1',
        getenv('PMAPORT') ?:'5432',
        getenv('PMADB') ?:'app_dev');
        $user = getenv('PMAUSER') ?: 'app_dev';
        $pass = getenv('PMAPASS') ?: '1281';
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]);
        return $pdo;
}