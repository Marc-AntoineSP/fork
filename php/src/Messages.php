<?php

declare(strict_types=1);

namespace Php\Src;

use PDO;


final class Messages {
    public function __construct(private PDO $pdo) {}

    public function getMessageById(int $id): array {
        $sql = "SELECT * FROM Messages WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(":id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $message = $stmt->fetch(PDO::FETCH_ASSOC);
        return $message;
    }

    /**
     * Summary of getMessageByConversationId
     * @param int $id
     * @return list<array{id:int,content:non-empty-string,recipient_id:int}
     */
    public function getMessageByConversationId(int $convId):array {
        $sql = 'SELECT * FROM Messages WHERE conversation_id = :convId';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':convId', $convId, PDO::PARAM_INT);
        $stmt->execute();
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $messages;
    }

    public function addMessage(int $user_id, int $conv_id, string $message): bool {
        try{
        $sql = 'INSERT INTO Messages (sender_id, conversation_id, content) VALUES (:user_id, :conv_id, :message)';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':user_id', $user_id, PDO::PARAM_INT);
        $stmt->bindValue(':conv_id', $conv_id, PDO::PARAM_INT);
        $stmt->bindValue(':message', $message, PDO::PARAM_STR);
        $ok = $stmt->execute();
        return $ok && $stmt->rowCount() === 1;
        }catch(\PDOException $e){
            return false;
        }
    }
}