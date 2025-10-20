<?php

declare(strict_types=1);

namespace Php\Src;

use DateTime;
use DateTimeImmutable;
use Dotenv\Dotenv;

$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->load();


use Firebase\JWT\JWT;
use Php\Src\Connection;
use Php\Src\Users;

function checkLog(bool $error, string $reason):array{
    return ["error"=> $error,"reason"=> $reason];
}
function normalizedReturn(bool $error, string $data):array{
    if($error)
        return ['error'=>true, 'reason'=>$data];
    return ['error'=>false, 'data'=>$data];
}

final class Authentification {
    public function __construct(private Users $users_db){}
    
    public function login(string $username, string $password): array{
        $user = $this->users_db->getUserByUsername($username);
        if(!$user){
            return ['error'=>true,'reason'=>"Username doesn't exist"];
        }
        $rt = $this->generationJWT($user);
        // DOIT RETOURNER 2 TOKENS.
        return Utils::dbReturn(false, ["AT" => "blabla", "RT" => $rt]);
    }

    public function createUser(string $username, string $password): array {
        if(strlen($password) < 8){
            return Utils::dbReturn(true, 'password too short');
        }
        $h_pwd = password_hash($password, PASSWORD_BCRYPT);
        $res = $this->users_db->addUser($username, $h_pwd);
        return $res;
    }

    public function generationJWT($user):string{
        $now = new DateTimeImmutable();
        $conf = [
            'iss' => 'localhost:8000',
            'aud' => 'mobile:8000',
            'iat' => $now,
            'sub' => $user['data']['id'],
            'exp' => $now->modify('+15 day')
        ];
        $key = $_ENV['JWT_KEY'];
        JWT::$leeway=60;
        $refreshToken = JWT::encode($conf, $key, 'HS256');
        return $refreshToken;
    }
}