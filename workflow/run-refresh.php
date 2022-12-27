<?php $start = hrtime(true);

require_once __DIR__ . '/vendor/autoload.php';

use Adamkiss\AlfredNoteplanFTS\CacheDatabase;
use Adamkiss\AlfredNoteplanFTS\Database;

try {
   // Ensure database existence
    Database::ensureExistence();

	$modified = CacheDatabase::getNotesModifiedSince(Database::getLastRun());
	Database::updateIndex($modified);
	Database::setLastRun(time());

	printf(
		"Updated %d notes in %03.2fms",
		count($modified),
		(hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */
	);
	exit();
} catch (\Throwable $th) {
    exit($th->getMessage());
}
