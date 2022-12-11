<?php
require_once __DIR__ . '/src/alfred.php';
require_once __DIR__ . '/src/db.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);
$join_snippet_matches = sprintf(
    '/\%s([\s\-\+\_\!\?\.\,]+?)\%s/i',
    $config['snippet_match_end'], $config['snippet_match_start']
);

try {
    $db = db_connect();
    [$originalQuery, $sqliteFtsQuery] = alfred_query_to_sqlite($argv);

    $result = db_query_fts($db, $sqliteFtsQuery, $config);    

    $items = [];
    while($r = $result->fetchArray(SQLITE3_ASSOC)) {
        $snip = str_replace("\n", '↩', $r['snippet']); // replace newlines with ↩
        $snip = preg_replace($join_snippet_matches, '$1', $snip);
        $title = preg_replace($join_snippet_matches, '$1', $r['title']);

        $item = [
            'title' => $title,
            'subtitle' => $r['path']
                ? "{$r['path']} • {$snip}"
                : $snip,
            'arg' => $r['callback'] . '&useExistingSubWindow=yes',
            'icon' => [
                'path' => __DIR__ . "/icons/icon-{$r['type']}.icns",
            ],
            "mods" => [
                "cmd" => [
                    "arg" => $r['callback'] . '&subWindow=yes',
                    "subtitle" => "Open in a new window"
                ]
            ]
        ];

        $items []= $item;
    }

    $items []= alfred_create_note_item($originalQuery, $config);

    echo alfred_itemize($items);
} catch (\Throwable $th) {
    echo alfred_return_error($th);
} finally {
    $db->close();
}
