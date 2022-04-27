<?php

require_once __DIR__ . '/noteplan.php';

function alfred_itemize(array $items): string {
    return json_encode(['items' => $items]);
}

function alfred_return_error(Throwable $th): string {
    return alfred_itemize([
        ['title' => 'Error: ' . $th->getMessage(), 'arg' => $th->getMessage(), 'valid' => false]
    ]);
}

function alfred_query_to_sqlite(array $argv): array {
    // $a[0] is the script name
    $originalQuery = $argv[1]; 

    // Remove everything except numbers, letters and spaces
    $sqliteQuery = preg_replace('/[^\p{L}\s\d]/', '', $originalQuery);
    // compress spaces
    $sqliteQuery = preg_replace('/\s+/', ' ', $sqliteQuery);
    // modify each word => word*
    $sqliteQuery = str_replace(' ', '* ', $sqliteQuery). '*';

    return [
        $originalQuery,
        $sqliteQuery
    ];
}

function alfred_query_to_rg_regex(array $argv): array {
    // $argv[0] is the script name
    $rawQuery = $argv[1]; 

    // Remove everything except numbers, letters and spaces
    $rawQuery = preg_replace('/[^\p{L}\s\d]/', '', $rawQuery);
    // compress spaces
    $rawQuery = preg_replace('/\s+/', ' ', $rawQuery);

    $lookupParts = explode(' ', $rawQuery);
    $last = array_pop($lookupParts);

    // append suffix to each element: explode -> map -> implode 
    return [
        $rawQuery,
        implode('', [...array_map(fn($l) => "{$l}(?s:(?!{$l}).)*?", $lookupParts), $last]),
    ];
}

function alfred_create_note_item(string $title, array $config) {
    return [
        'title' => "Create '$title'",
        'subtitle' => 'Create a new note',
        'arg' => $title,
        'icon' => [
            'path' => __DIR__ . "/../icons/icon-create.icns",
        ]
    ];
}