<?php

declare(strict_types= 1);

namespace Php\Src;


final class Utils {
    public static function dbReturn(bool $error, ?string $data):array {
        if($error){return ["error"=> $error,"reason"=> $data];}
        return ["error"=> $error,"data"=> $data ?? ""];
    }
}