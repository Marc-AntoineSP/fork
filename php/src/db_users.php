<?php
declare(strict_types=1);

namespace Php\Src\db_users;

use function Php\Src\db\pdo_sql;

// REQUETES : 

// Consulter la liste :

function users_list():array{
    $pdo = pdo_sql();
    $sql = 'SELECT id, username, hash_password, created_at FROM Users';
    $users = $pdo->query($sql)->fetchAll();
    return $users;
}