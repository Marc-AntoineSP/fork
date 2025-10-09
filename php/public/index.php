<?php

declare(strict_types=1);

use Php\Src\Connection;
use Php\Src\Users;

require __DIR__ ."/../vendor/autoload.php";

// API :

$users_db = new Users(Connection::connnect());
$method = $_SERVER['REQUEST_METHOD'];
$path = rtrim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/', '/');

header('Content-Type:application/json');

switch(true){
    case $method == 'GET' && $path == '/users':
        $userlist = $users_db->getAll();
        echo json_encode(['data'=> $userlist]);
        exit;
    case $method == 'GET' && preg_match('#^/users/(?P<id>\d+)$#', $path, $m):
        $id = (int)$m['id'];
        $user = $users_db->getUserById($id);
        if(!$user) {
            http_response_code(404);
            echo json_encode(['error'=> 'User not found']);
            exit;
        }
        echo json_encode(['data'=> $user]);
        exit;
        
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}