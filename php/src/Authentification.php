<?php

declare(strict_types=1);

namespace Php\Src;
use Php\Src\Connection;
use Php\Src\Users;

function checkLog(bool $error, string $reason):array{
    return ["error"=> $error,"reason"=> $reason];
}

final class Authentification {
    public function __construct(private Users $users_db){}
    
    public function login(string $username, string $password): array{
        $user = $this->users_db->getUserByUsername($username);
        if(!$user){
            return ['error'=>true,'reason'=>"Username doesn't exist"];
        }
        $passwordCheck = ($password == $user["hash_password"]) ? checkLog(false, "") : checkLog(true,"Invalid credentials");
        return $passwordCheck;
    }
}