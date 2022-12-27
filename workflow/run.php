<?php $start = hrtime(true);

require_once __DIR__ . '/vendor/autoload.php';

use Adamkiss\AlfredNoteplanFTS\Alfred;
use Adamkiss\AlfredNoteplanFTS\CacheDatabase;
use Adamkiss\AlfredNoteplanFTS\Database;
use Adamkiss\AlfredNoteplanFTS\NoteplanCallback;

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

        printf(
			"Updated %d notes in %03.2fms",
			count($modified),
			(hrtime(true) - $start) / 1e+6 /* nanoseconds to milliseconds */
		);
        exit();
    }

    /**
     * Get folders and return the addNote queries
     */
    if (str_starts_with($query, 'New: ')) {
        $folders = CacheDatabase::getAllFolders();
		array_unshift($folders, null);

		$title = explode('New: ', $query)[1];

		Alfred::exit(
			array_map(fn($f) => Alfred::item(
				uid: urlencode($f ?? "root_folder"),
				title: $f ?? 'Notes root',
				subtitle: "Create note '{$title}' in the folder '{$f}'",
				icon: ['path'=>'icons/icon-folder.icns'],
				arg: NoteplanCallback::add($title, $f)
			), $folders)
		);
    }

    /**
     * Search and exit
     */
    Alfred::exit([
		...Database::search($query),
		Alfred::item(
			title: "Add note \"{$query}\"",
			subtitle: "Creates a new note",
			arg: "New: {$query}",
			icon: ['path'=>'icons/icon-new.icns']
		)
	]);
} catch (\Throwable $th) {
    Alfred::error($th);
}
