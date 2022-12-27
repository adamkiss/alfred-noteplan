<?php

require_once __DIR__ . '/vendor/autoload.php';

use Adamkiss\AlfredNoteplanFTS\Alfred;
use Adamkiss\AlfredNoteplanFTS\CacheDatabase;
use Adamkiss\AlfredNoteplanFTS\Database;
use Adamkiss\AlfredNoteplanFTS\NoteplanCallback;

// Get title or die trying
$title = $argv[1] ?? exit();

try {
   // Ensure database existence
    Database::ensureExistence();

	$folders = CacheDatabase::getAllFolders();
	array_unshift($folders, null);

	Alfred::exit(
		array_map(fn($f) => Alfred::item(
			uid: urlencode($f ?? "root_folder"),
			title: $f ?? 'Notes root',
			subtitle: "Create note '{$title}' in the folder '{$f}'",
			icon: ['path'=>'icons/icon-folder.icns'],
			arg: NoteplanCallback::add($title, $f)
		), $folders)
	);
} catch (\Throwable $th) {
    Alfred::error($th);
}
