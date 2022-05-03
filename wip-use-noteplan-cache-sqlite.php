<?php
$start = hrtime(true);

define('FRONTMATTER_REGEX', '/---.*?title\:\s*?(.*?)\n.*?---/is');
define('MARKDOWN_TITLE_REGEX', '/^#\s*(.*)(?:\n|\s---)/');

require_once __DIR__ . '/src/db.php';
require_once __DIR__ . '/src/notes.php';
require_once __DIR__ . '/src/noteplan.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);

try {
    $cache_db = new SQLite3($config['noteplan_root'] . '/Caches/sync-cache.db');
    $db = new SQLite3(__DIR__ . '/db3.sqlite3');

    db_ensure_exists($db);
    db_clean($db);
    
    // sketch metadata table
    $db->exec('CREATE TABLE IF NOT EXISTS metadata (
        key TEXT PRIMARY KEY,
        value TEXT
    )');

    // get and set last run
    $last_run = $db->querySingle('SELECT value FROM metadata WHERE key = "last_run"');
    $current_run = time() * 1000;
    $s = $db->prepare('INSERT INTO metadata (key, value) VALUES (\'last_run\', :value) ON CONFLICT(key) DO UPDATE SET value = :value');
    $s->bindParam(':value', $last_run);
    $s->execute();

    $modified = $cache_db->query('SELECT note_type, filename, modified, content FROM metadata WHERE is_directory = 0 AND LENGTH(content) AND modified > '.$last_run);
    while($r = $modified->fetchArray(SQLITE3_ASSOC)) {
        $fakePreviousFormat = ['file' => ($r['note_type'] === 1 ? 'Notes/' : 'Calendar/') . $r['filename']];

        // @note This is a bit brittle - if there's any whitespace at the beginning
        // it'll fail to match the title.
        $hasFrontmatter = $r['content'][0] !== '#';
    
        if ($hasFrontmatter) {
            $title = trim(preg_match(FRONTMATTER_REGEX,$r['content'], $matches)
                ? $matches[1]
                : '');
            $content = trim(preg_replace(FRONTMATTER_REGEX, '',$r['content']));
        } else {
            $title = trim(preg_match(MARKDOWN_TITLE_REGEX,$r['content'], $matches)
                ? $matches[1]
                : '');
            $content = trim(preg_replace(MARKDOWN_TITLE_REGEX, '',$r['content']));
        }
    
        if (! is_null($config['precache_modify_content'])) {
            $content = call_user_func($config['precache_modify_content'], $content);
        }

        $fakePreviousFormat['title'] = $title;
        $fakePreviousFormat['body'] = $content;

        $processed = $r['note_type'] === 0
            ? notes_process_calendar_entry($config, $fakePreviousFormat)
            : notes_process_note($config, $fakePreviousFormat);
        db_insert($db, $processed);
    }

    $cache_db->close();
    $db->close();

    // $calendarEntries = fs_read_directory('calendar', $config);
    // foreach (notes_remove_empty($calendarEntries) as $entry) {
    //     db_insert($db, notes_process_calendar_entry($config, $entry));
    // }

    // $notes = fs_read_directory('notes', $config);
    // foreach (notes_remove_empty($notes) as $note) {
    //     db_insert($db, notes_process_note($config, $note));
    // }
    
    printf("Done in %03.2fms", (hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */);
} catch (\Throwable $th) {
    echo $th->getMessage();
}

