<?php

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
	 * List dash commands
	 */
	if ($query === '-') {
		Alfred::exit([
			Alfred::item(
				title: '-r',
				subtitle: 'Initiate a cache refresh',
				autocomplete: '-r'
			),
			Alfred::item(
				title: '-n',
				subtitle: 'Create a new note',
				autocomplete: '-n '
			)
		]);
	}

    /**
     * Initiate the refresh (post-instal, mostly)
     */
    if ($query === '-r') {
        Alfred::exit([
            Alfred::item(
                title: "Refresh the database",
                subtitle: "Includes a setup, if needed",
                arg: '-refresh'
            )
        ]);
    }

    /**
     * Return new note autocomplete
     */
    if ($query === '-n') {
        Alfred::exit([
			Alfred::item(
				title: 'Add note…',
				subtitle: 'Create a new note',
				autocomplete: '-n '
			)
        ]);
    }

    /**
     * Get folders and return the addNote queries
     */
    if (str_starts_with($query, '-n ')) {
        $folders = CacheDatabase::getAllFolders();
		array_unshift($folders, null);

		$title = explode('-n ', $query)[1];

		Alfred::exit([
			Alfred::item(
				title: "Add note \"{$title}\"",
				subtitle: "Creates a new note",
				arg: $title,
				icon: ['path'=>'icons/icon-new.icns']
			)
		]);
    }

    /**
     * Search and exit
     */
    Alfred::exit([
		...Database::search($query),
		Alfred::item(
			title: "Add note \"{$query}\"",
			subtitle: "Creates a new note",
			arg: "-n {$query}",
			icon: ['path'=>'icons/icon-new.icns']
		)
	]);
} catch (\Throwable $th) {
    Alfred::error($th);
}
