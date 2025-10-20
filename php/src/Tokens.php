<?php

declare(strict_types=1);
namespace Php\Src;

use PDO;
use Php\Src\Utils;

final class Tokens {
    public function __construct(private PDO $pdo){}

    /**
     * Summary of getRefresh
     * @param mixed $userid
     * @return array{data: mixed}
     */
    function getRefresh($userid): array{
        $sql = "SELECT (token_hash) FROM Refresh_token WHERE user_id = :userid";
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':userid', $userid, PDO::PARAM_INT);
        $stmt->execute();
        $res = $stmt->fetch(PDO::FETCH_ASSOC);
        return Utils::dbReturn(false, $res);
    }

    function storeRefresh($RT, $conf):array{
        $sql = 'INSERT INTO Refresh_token (token_hash, user_id, created_at, expires_at) VALUES (:token_hash, :user_id, :created_at, :expires_at)';
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':token_hash', $RT, PDO::PARAM_STR);
        $stmt->bindValue(':user_id', $conf['sub'], PDO::PARAM_INT);
        $stmt->bindValue(':created_at', $conf['iat'], PDO::PARAM_INT);
        $stmt->bindValue(':expires_at', $conf['exp'], PDO::PARAM_INT);
        $stmt->execute();
        return Utils::dbReturn(false, null);
    }
}