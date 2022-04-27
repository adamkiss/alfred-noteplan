<?php
    
function noteplan_callback_url(string $method, array $params = []): string {
    return implode('', [
        'noteplan://x-callback-url/',
            $method,
        '?',
            http_build_query($params, encoding_type: PHP_QUERY_RFC3986)
    ]);
}

function noteplan_create_note(array $config, string $title, ?string $folder): string {
    $params = [
        'text' => $config['noteplan_new_note']($title),
        'openNote' => 'yes',
        'useExistingSubWindow' => 'yes'
    ];
    if (isset($folder) && $folder !== '/') { $params['folder'] = $folder; }

    return noteplan_callback_url('addNote', $params);
}