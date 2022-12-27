<?php $start = hrtime(true);

require_once __DIR__ . '/vendor/autoload.php';

use Adamkiss\AlfredNoteplanFTS\Alfred;
use Adamkiss\AlfredNoteplanFTS\CacheDatabase;
use Adamkiss\AlfredNoteplanFTS\Database;

// Get query or die trying
$query = $argv[1] ?? exit();

try {
   // Ensure database existence
    Database::ensureExistence();

    /**
     * Initiate the refresh (post-instal, mostly)
     */
    if ($query === '-r') {
        Alfred::exit([
            Alfred::item(
                title: "Refresh the database",
                subtitle: "Includes a setup, if needed",
                arg: '--refresh'
            )
        ]);
    }

    /**
     * Run the refresh
     */
    if ($query === '--refresh') {
        $modified = CacheDatabase::getNotesModifiedSince(Database::getLastRun());
        Database::updateIndex($modified);
        Database::setLastRun(time());

        printf("Done in %03.2fms", (hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */);
        exit();
    }

    // // run & exit
    // exit(match (true) {
    //     $query === '-r' => Items::refreshItem(),
    //     $query === '--refresh' => Database::getInstance()->refresh(),
    //     str_starts_with($query, 'New: ') => '…',
    //     default => Database::getInstance()->search($query)
    // });


} catch (\Throwable $th) {
    Alfred::error($th);
}