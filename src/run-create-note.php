<?php
require_once __DIR__ . '/src/alfred.php';
require_once __DIR__ . '/src/fs.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);

try {
    $items = [];

    foreach (fs_list_folders($config) as $folder) {

    };
    
    printf("Done in %03.2fms", (hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */);
} catch (\Throwable $th) {
    echo $th->getMessage();
}

