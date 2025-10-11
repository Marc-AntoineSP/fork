<?php
declare(strict_types=1);

namespace Php\Src;

use PDO;

// REQUETES : 

final class Users {
    public function __construct(private PDO $pdo) {}

    /** 
     * GET ALL Users
     * @return list<array{id:int,username:string}> 
    */
    public function getAll():array{

        $sql = 'SELECT id, username FROM Users';
        return $this->pdo->query($sql)->fetchAll();

    }

    /**
     * Summary of getUserById
     * @param int $id
     * @return array
     */
    public function getUserById(int $id):array|bool{
        $sql = 'SELECT id, username, hash_password FROM Users WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $user = $stmt->fetch();
        return $user;
    }

    public function getUserByUsername(string $username):array|bool{
        $sql = 'SELECT * FROM Users WHERE username = :username';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':username', $username, PDO::PARAM_STR);
        $stmt->execute();
        $user = $stmt->fetch();
        return $user;
    }

    public function deleteUserById(int $id):bool{
        try{$sql = 'DELETE FROM Users WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        return $stmt->execute();}catch(\PDOException $e){return false;}
    }
}