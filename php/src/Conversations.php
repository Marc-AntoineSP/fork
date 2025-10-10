<?php

declare(strict_types=1);

namespace Php\Src;

use PDO;

final class Conversations {
    public function __construct(private PDO $pdo) {}

    /**
     * GET /conversations
     * @return array
     */
    public function getAll():array {
        $sql = 'SELECT id, name FROM Conversations';
        return $this->pdo->query($sql)->fetchAll();
    }

    /**
     * GET /conversations/:id
     * @param int $id
     * @return array
     */
    public function getConversationById(int $id):array|bool {
        $sql = 'SELECT id, name, recipient_id FROM Conversations WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        return $data;
    }

    public function addConversation(int $main_user_id, int $recipient_id, string $name):bool{
        $sql = 'INSERT INTO Conversations (main_user_id, recipient_id, name) VALUES (:main_user_id, :recipient_id, :name)';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':main_user_id', $main_user_id, PDO::PARAM_INT);
        $stmt->bindValue(':recipient_id', $recipient_id, PDO::PARAM_INT);
        $stmt->bindValue(':name', $name, PDO::PARAM_STR);
        return $stmt->execute();
    }

    public function updateConversation(int $conv_id, string $name):array|bool{
        try{$sql = 'UPDATE Conversations SET name = :name WHERE id = :conv_id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':conv_id', $conv_id, PDO::PARAM_INT);
        $stmt->bindValue(':name', $name, PDO::PARAM_STR);
        $res = $stmt->execute();
        if(!$res){return false;}

        $getSql = 'SELECT id, name FROM Conversations WHERE id = :conv_id';
        $getStmt = $this->pdo->prepare($getSql);
        $getStmt->bindValue(':conv_id', $conv_id, PDO::PARAM_INT);
        $getStmt->execute();

        return $getStmt->fetch(PDO::FETCH_ASSOC);}catch(\PDOException $e){return false;}
    }
}