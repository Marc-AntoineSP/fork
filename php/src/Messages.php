<?php

declare(strict_types=1);

namespace Php\Src;

use PDO;

final class Messages {
    public function __construct(private PDO $pdo) {}

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
}