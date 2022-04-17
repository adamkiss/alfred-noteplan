<?php
require_once __DIR__ . '/_shared.php';

function prepareQuery(array $a) {
    // $a[0] is the script name
    $rawQuery = $a[1]; 
    

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

function itemize(array $items) {
    return json_encode(['items' => $items]);
}

function main(array $arguments): string {
    $results = [];
    [$rawQuery, $searchQuery] = prepareQuery($arguments);

    $capture = shell_exec(sprintf("cd '%s' && rg --pcre2 -m 1 -iU '%s' Calendar Notes", NOTEPLAN_ROOT, $searchQuery));
    if (! $capture) {
        $results []= [
            'title' => "Create '{$rawQuery}'",
            'subtitle' => 'No results • Create a note instead',
            'icon' => [
                'path' => __DIR__ . "/icons/noteplan-note.png",
            ],
            'arg' => NOTEPLAN_URL_OPEN . '/openNote?noteDate=today',
        ];

        return itemize($results);
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

        $results []= [
            'title' => $title,
            'subtitle' => $type === 'Calendar'
                ? "📆 {$match}"
                : "📝 {$notePath} • {$match}",
            'arg' => NOTEPLAN_URL_OPEN . (
                $type === 'Calendar'
                    ? '?noteDate=' . $title
                    : '?notePath=' . rawurlencode(implode('/', array_slice($path, 1)))
            ) . '&useExistingSubWindow=yes',
            'icon' => [
                'path' => __DIR__ . "/icons/noteplan-{$iconType}.png",
            ],
        ];
    }
    
    return itemize($results);
}

try {
    echo main($argv);
} catch (\Throwable $th) {
    ray($th);
}