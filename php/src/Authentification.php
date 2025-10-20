<?php

declare(strict_types=1);

namespace Php\Src;

use DateTimeImmutable;
use Dotenv\Dotenv;

$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->load();


use Firebase\JWT\JWT;
use Php\Src\Connection;
use Php\Src\Users;
use Php\Src\Tokens;

function checkLog(bool $error, string $reason):array{
    return ["error"=> $error,"reason"=> $reason];
}
function normalizedReturn(bool $error, string $data):array{
    if($error)
        return ['error'=>true, 'reason'=>$data];
    return ['error'=>false, 'data'=>$data];
}

final class Authentification {

    private $tokendb;
    
    public function __construct(private Users $users_db){
        $this->tokendb = new Tokens(Connection::connect());
    }
    

    public function login(string $username, string $password): array{
        $user = $this->users_db->getUserByUsername($username);
        if(!$user){
            return ['error'=>true,'reason'=>"Username doesn't exist"];
        }
        $rt = $this->generationRT($user);
        $at = $this->generationAT($rt, $user);
        // DOIT RETOURNER 2 TOKENS.
        return Utils::dbReturn(false, $rt);
    }

    public function createUser(string $username, string $password): array {
        if(strlen($password) < 8){
            return Utils::dbReturn(true, 'password too short');
        }
        $h_pwd = password_hash($password, PASSWORD_BCRYPT);
        $res = $this->users_db->addUser($username, $h_pwd);
        return $res;
    }

    public function generationRT($user):array{
        $now = new DateTimeImmutable();
        $conf = [
            'iss' => 'localhost:8000',
            'aud' => 'mobile:8000',
            'iat' => $now->getTimestamp(),
            'sub' => $user['data']['id'],
            'exp' => $now->modify('+15 day')->getTimestamp()
        ];
        $key = $_ENV['JWT_KEY'];
        JWT::$leeway=60;
        $refreshToken = JWT::encode($conf, $key, 'HS256');
        $h_rt = hash('sha256', $refreshToken);
        $accessToken = JWT::encode($conf, $h_rt, 'HS256');
        return ["at"=>$accessToken, "rt"=>$refreshToken, "conf"=>$conf];
    }

    public function generationAT($rt, $conf):string{
        $now = new DateTimeImmutable();
        $conf = [
            'iss' => 'localhost:8000',
            'aud' => 'mobile:8000',
            'iat' => $now->getTimestamp(),
            'sub' => $conf['sub'],
            'exp' => $now->modify('+10 minutes')->getTimestamp()
        ];
        $accessToken = JWT::encode(payload:$conf, key:(string)$rt, alg:'HS256');
        return $accessToken;
    }

    public function storeRT($rt, $conf){
        $h_rt = hash('sha256', $rt);
        $this->tokendb->storeRefresh($h_rt, $conf);
    }
    // public function verifyAT():bool{

    // }
}