<?php

declare(strict_types= 1);

namespace Php\Src;


final class Utils {
    public static function dbReturn(bool $error, mixed $data): array {
    return ['error' => $error, 'data' => $data];
}
}