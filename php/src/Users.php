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

    public function addUser(string $user, string $h_password):array{
        try{
            $sql = 'INSERT INTO Users (username, hash_password) VALUES (:user, :h_password)';
            $stmt = $this->pdo->prepare($sql);
            $stmt->bindValue(':user', $user, PDO::PARAM_STR);
            $stmt->bindValue(':h_password', $h_password, PDO::PARAM_STR);
            $stmt->execute();

            if($stmt->rowCount() === 0){
                return Utils::dbReturn(true, 'No INSERT done.');
            }
            
            $id = $this->pdo->lastInsertId();
            $getSql = 'SELECT * FROM Users WHERE id = :id';
            $stmt = $this->pdo->prepare($getSql);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            return Utils::dbReturn(false, $stmt->fetch(PDO::FETCH_ASSOC));
        }catch(\PDOException $e){
            return Utils::dbReturn(true, $e->getMessage());
        }
    }
}