<?php

declare(strict_types=1);

use Php\Src\Connection;
use Php\Src\Conversations;
use Php\Src\Users;

require __DIR__ ."/../vendor/autoload.php";

// API :

$users_db = new Users(Connection::connnect());
$conversations_db = new Conversations(Connection::connnect());
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
            echo json_encode(['error'=> "User $id not found"]);
            exit;
        }
        echo json_encode(['data'=> $user]);
        exit;
    case $method == 'GET' && $path == '/conversations':
        $conversations = $conversations_db->getAll();
        echo json_encode(['data'=> $conversations]);
        exit;
    case $method == 'GET'&& preg_match('#^/conversations/(?P<id>\d+)#', $path, $m):
        $id = (int)$m['id'];
        $conversation = $conversations_db->getConversationById($id);
        if(!$conversation) {
            http_response_code(404);
            echo json_encode(['error'=> "Conversation $id doesn't exist"]);
            exit;
        }
        echo json_encode(['data'=> $conversation]);
        exit;
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}