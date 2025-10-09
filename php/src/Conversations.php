<?php

declare(strict_types=1);

namespace Php\Src;

use PDO;

final class Conversations {
    private $pdo = null;

    public function __construct(PDO $pdo) {}

    /**
     * GET /conversations
     * @return array
     */
    public function getAll():array {
        $sql = 'SELECT id, name FROM Conversations';
        $stmt = $this->pdo->prepare($sql);
        $stmt = $stmt->execute();
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $data;
    }

    /**
     * GET /conversations/:id
     * @param int $id
     * @return array
     */
    public function getConversationById(int $id):array {
        $sql = 'SELECT id, name, recipient_id WHERE id = :id';
        $stmt = $this->pdo->prepare($sql);
        $stmt = $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt = $stmt->execute();
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        return $data;
    }
}