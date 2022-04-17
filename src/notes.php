<?php

function notes_remove_empty(array $notes): array {
    return array_filter($notes, fn($note) => !empty($note));
}

function notes_process_calendar_entry(array $config, array $note): array {
    // get date out of the file name
    $breadcrumbs = explode('/', $note['file']);
    $date = substr(array_pop($breadcrumbs), 0, 8);

    // calendar specific details
    $merge = [
        'type' => 'calendar',
        'path' => null,
        'title' => date($config['calendar_title_format'], strtotime($date)),
        'callback' => ['method'=>'openNote', 'params' => ['noteDate' => $date]],
    ];

    return array_merge($note, $merge);
}

function notes_process_note(array $config, array $note): array {
    $breadcrumbs = explode('/', $note['file']);
    $path = array_slice($breadcrumbs, 1, -1);
    $pathName = implode('/', array_slice($breadcrumbs, 1));

    $merge = [
        'type' => 'note',
        'path' => empty($path) ? '/' : implode('/', $path),
        'callback' => ['method'=>'openNote', 'params' => ['filename' => rawurlencode($pathName)]],
    ];

    return array_merge($note, $merge);
}