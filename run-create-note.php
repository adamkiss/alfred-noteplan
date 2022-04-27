<?php
$start = hrtime(true);

require_once __DIR__ . '/src/alfred.php';
require_once __DIR__ . '/src/fs.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);

try {
    $items = [];

    $title = $argv[1];
    $folders = array_merge(['/' => 'Notes directory'], fs_list_folders('notes', $config));

    $items = array_map(fn($name, $relPath) => [
        'title' => $name,
        'subtitle' => ($relPath === '/')
            ? "Create note '{$title}' in the Notes root"
            : "Create note '{$title}' in the folder {$name}",
        'arg' => noteplan_create_note($config, $title, $relPath),
        'valid' => 'yes',
        'icon' => [
            'path' => __DIR__ . "/icons/noteplan-note.png",
        ],
    ], $folders, array_keys($folders));

    echo alfred_itemize($items);
} catch (\Throwable $th) {
    echo $th->getMessage();
}

