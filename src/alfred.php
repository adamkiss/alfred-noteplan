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

function alfred_create_note_item(string $title, array $config) {
    return [
        'title' => $title,
        'subtitle' => 'Create new note',
        'arg' => noteplan_callback_url('addNote', [
            'text' => $config['noteplan_new_note']($title),
            'openNote' => 'yes',
            'useExistingSubwindow' => 'yes',
        ]),
        'icon' => [
            'path' => __DIR__ . "/icons/noteplan-note.png",
        ],
        "mods" => [
            "cmd" => [
                "arg" => noteplan_callback_url('addNote', [
                    'text' => $config['noteplan_new_note']($title),
                    'openNote' => 'yes',
                    'useExistingSubwindow' => 'yes',
                ]),
                "subtitle" => "Create a note in a new window"
            ]
        ]
    ];
}