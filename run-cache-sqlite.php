<?php
$start = hrtime(true);

require_once __DIR__ . '/src/alfred.php';
require_once __DIR__ . '/src/db.php';
require_once __DIR__ . '/src/fs.php';
require_once __DIR__ . '/src/noteplan.php';
require_once __DIR__ . '/src/notes.php';

$config = array_merge(
    require_once __DIR__ . '/src/defaults.php',
    require_once __DIR__ . '/_config.php'
);

try {
    $db = db_connect();
    db_ensure_exists($db);
    db_clean($db);

    $calendarEntries = fs_read_directory('calendar', $config);
    foreach (notes_remove_empty($calendarEntries) as $entry) {
        db_insert($db, notes_process_calendar_entry($config, $entry));
    }

    $notes = fs_read_directory('notes', $config);
    foreach (notes_remove_empty($notes) as $note) {
        db_insert($db, notes_process_note($config, $note));
    }
    
    $db->close();

    printf("Done in %03.2fms", (hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */);
} catch (\Throwable $th) {
    echo $th->getMessage();
} finally {
    $db->close();
}
