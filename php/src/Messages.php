<?php

declare(strict_types=1);

final class Messages {
    public function __construct(private PDO $pdo) {}

    /**
     * Summary of getMessageByConversationId
     * @param int $id
     * @return list<array{id:int,content:non-empty-string,recipient_id:int}
     */
    public function getMessageByConversationId(int $id):array {
        $sql = 'SELECT * FROM Messages WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $messages;
    }
}