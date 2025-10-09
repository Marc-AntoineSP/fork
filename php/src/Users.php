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
}