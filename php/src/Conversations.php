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
    public function getConversationById(int $id):array {
        $sql = 'SELECT id, name, recipient_id WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        return $data;
    }
}