<?php
require_once __DIR__ . '/src/alfred.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);

try {
    $results = [];
    [$rawQuery, $rgRegex] = alfred_query_to_rg_regex($argv);

    $capture = shell_exec(
        sprintf("cd '%s' && rg --pcre2 -m 1 -iU '%s' Calendar Notes",
            $config['noteplan_root'],
            $rgRegex
        )
    );

    if (! $capture) {
        $results []= alfred_create_note_item($rawQuery, $config);

        echo alfred_itemize($results);
    }

    $matches = explode("\n", $capture);
    $files = [];
    foreach($matches as $match) {
        if (empty($match)) {
            continue;
        }

        [$file, $text] = explode(':', $match, 2);
        if (array_key_exists($file, $files)) {
            $files[$file] []= $text;
        } else {
            $files[$file] = [$text];
        }
    }

    foreach ($files as $file => $matchArray) {
        $path = explode('/', $file);
        $title = str_replace('.md', '', array_pop($path));
        $type = array_shift($path);
        $iconType = $type === 'Calendar' ? 'calendar' : 'note';
        $notePath = implode('/', $path);

        $match = substr(implode('↩', $matchArray), 0, 100);

        $callback = noteplan_callback_url(
            method: 'openNote',
            params: $type === 'Calendar'
                ? ['noteDate' => $title]
                : ['filename' => rawurlencode($notePath)]
        );
        
        $items []= [
            'title' => $title,
            'subtitle' => $type === 'Calendar'
                ? "📆 {$match}"
                : "📝 {$notePath} • {$match}",
            'arg' => $callback . '&useExistingSubWindow=yes',
            'valid' => true,
            'icon' => [
                'path' => __DIR__ . "/icons/noteplan-{$iconType}.png",
            ],
            "mods" => [
                "cmd" => [
                    "arg" => $callback . '&subWindow=yes',
                    "subtitle" => "Open in a new window"
                ]
            ]
        ];
    }

    echo alfred_itemize($items);
} catch (\Throwable $th) {
    echo alfred_return_error($th);
}