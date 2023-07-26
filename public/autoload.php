<?php

declare(strict_types=1);

namespace WESTERN;

spl_autoload_register(function(string $className) {
    require_once str_replace('\\', '/', $className) . '.php';
});

?>