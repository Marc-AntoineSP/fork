<?php

declare(strict_types=1);

use Php\Src\Authentification;
use Php\Src\Connection;
use Php\Src\Conversations;
use Php\Src\Messages;
use Php\Src\Users;

require __DIR__ ."/../vendor/autoload.php";

// API :

$users_db = new Users(Connection::connect());
$auth = new Authentification($users_db);    
$conversations_db = new Conversations(Connection::connect());
$messages_db = new Messages(Connection::connect());

$method = $_SERVER['REQUEST_METHOD'];
$path = rtrim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/', '/');

header('Content-Type:application/json');

function httpOk(int $httpCode, ?array $payload = []): never{
    http_response_code($httpCode);
    if($httpCode === 204){exit;}
    echo json_encode(['data'=> $payload]);
    exit;
}
function httpFail(int $httpCode, string $error): never{
    http_response_code($httpCode);
    echo json_encode(['error'=> $error]);
    exit;
}

switch(true){
    case $method == 'GET' && $path == '/users':
        $userlist = $users_db->getAll();
        httpOk(200, $userlist);

    case $method == 'GET' && preg_match('#^/users/(?P<id>\d+)$#', $path, $m):
        $id = (int)$m['id'];
        $user = $users_db->getUserById($id);
        if(!$user) {
            httpFail(404, "User $id not found");
        }
        httpOk(200, $user);

    case $method == 'GET' && $path == '/conversations':
        $conversations = $conversations_db->getAll();
        httpOk(200, $conversations);

    case $method == 'GET'&& preg_match('#^/conversations/(?P<id>\d+)$#', $path, $m):
        $id = (int)$m['id'];
        $conversation = $conversations_db->getConversationById($id);
        if(!$conversation) {
            httpFail(404, "Conversation $id doesn't exist");
        }
        httpOk(200, $conversation);

    case $method == 'GET'&& preg_match('#^/conversations/(?P<convId>\d+)/messages$#', $path, $m):
        $convId = (int)$m['convId'];
        $messages = $messages_db->getMessageByConversationId($convId);
        if(!$messages){
            httpFail(404, "Conversation $convId doesn't exist");
        }
        httpOk(200, $messages);

    case $method == "GET"&& preg_match("#^/messages/(?P<id>\d+)#", $path, $m):
        $id = (int)$m["id"];
        $message = $messages_db->getMessageById($id);
        if(!$message) {
            httpFail(404, "Message $id doesn't exist");
        }
        httpOk(200, $message);

    case $method == "POST"&& $path == "/auth":
        $username = trim($_POST["username"] ?? '');
        $password = trim($_POST["password"] ?? '');
        if(empty($username) || empty($password)) {
            httpFail(422, "Veuillez renseigner les 2 champs svp");
        }
        $errLog = $auth->login($username, $password);
        if($errLog['error']) {
            httpFail(401, $errLog['reason']);
        }
        httpOk(204);

    case $method == "POST"&& preg_match("#^/conversations/(?P<conv_id>\d+)/messages$#", $path, $m):
        $conv_id = (int)$m["conv_id"];
        $message = $_POST["message"] ??"";
        $user_id = (int)$_POST["user_id"];
        if(empty($conv_id) || empty($user_id)) {
            httpFail(402, "Invalid POST request");
        }
        $ok = $messages_db->addMessage($user_id, $conv_id, $message);
        if($ok) {
            httpOk(201, ["resource created"]);
        }else{
            http_response_code(500);
            echo json_encode(["error"=> "Oops, la DB a pas aimé"]);
            exit;
        }
    case $method == "POST"&& $path == '/conversations':
        $main_user_id = (int)$_POST['user_id'] ?? "";
        $recipient_id = (int)$_POST['recipient_id'] ?? "";
        $name = (string)$_POST['name'] ?? "";
        if(empty($recipient_id) || empty($name) || empty($main_user_id)){http_response_code(400); json_encode(["error"=>"Invalid POST request"]); exit;}
        $ok = $conversations_db->addConversation($main_user_id, $recipient_id, $name);
        if(!$ok){
            http_response_code(500);
            echo json_encode(["error"=> "Oops, la DB a pas aimé"]);
            exit;
        }
        http_response_code(201);
        header('Location http://127.0.0.1:8000/conversations');
        exit;
    case $method == "PATCH" && preg_match("#^/messages/(?P<msg_id>\d+)$#", $path, $m):
        $message_id = (int)$m["msg_id"];
        $body = file_get_contents('php://input');
        if($body === false || $body === ''){
            http_response_code(400);
            echo json_encode(['error'=> 'Empty request, did you mean to DELETE ?']);
            exit;
        }
        try{
        $content = json_decode($body, true, 512, JSON_THROW_ON_ERROR);
        if(!is_array($content)){
            http_response_code(400);
            echo json_encode(['error'=> 'Bad JSON']);
            exit;
        }
        $messages_db->updateMessage($message_id, (string)$content['content']);
        http_response_code(200);
        echo json_encode(['message'=> 'updated']);
        exit;
        }catch(JsonException $e){
            http_response_code(400);
            echo json_encode(['error' => 'Bad JSON']);
            exit;
        }
    default:
        http_response_code(404);
        echo json_encode(['error'=> "URI Doesn't exist"]);
}