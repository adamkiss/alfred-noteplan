import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_cache.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:alfred_noteplan_fts_refresh/note.dart';

int refresh(DbFts db, {bool force = false}) {
	final cache = DbCache(sqlite3.open(Config.path_cache_db));

	// Get changed notes in Cache
	initializeDateFormatting('en_GB', null);
	List<Note> new_notes = [];
	for (var result in cache.select_updated(since: force ? 0 : db.get_last_update())) { new_notes.add(Note(result)); }

	// Delete/reinsert the notes
	if (new_notes.isNotEmpty) {
		db.delete_notes(new_notes.map((e) => e.filename));
		db.insert_notes(new_notes);
	}

	// Save the last update and cleanup
	db.set_last_update();
	cache.dispose();

	// return number of updates
	return new_notes.length;
}