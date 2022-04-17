<?php

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