<?php

declare(strict_types=1);

use function Php\Src\db_users\users_list;

require __DIR__ ."/../vendor/autoload.php";

// API :

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

header('Content-Type:application/json');

switch(true){
    case $method == 'GET' && $path == '/':
        $userlist = users_list();
        echo json_encode(['data'=> $userlist]);
        exit;
    case $method == 'POST' && $path == '/conversation':
        
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}