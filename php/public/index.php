<?php

declare(strict_types=1);

use Php\Src\db\Connection;
use Php\Src\db_users\Users;

require __DIR__ ."/../vendor/autoload.php";

// API :

$users_db = new Users(Connection::connnect());
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

header('Content-Type:application/json');

switch(true){
    case $method == 'GET' && $path == '/':
        $userlist = $users_db->getAll();
        echo json_encode(['data'=> $userlist]);
        exit;
    case $method == 'POST' && $path == '/conversation':
        
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}