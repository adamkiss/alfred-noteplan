import 'dart:developer';

import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_cache.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:alfred_noteplan_fts_refresh/note.dart';

void refresh({bool force = false}) {
	// print('Using sqlite3 ${sqlite3.version.libVersion}');
	final cache = DbCache(sqlite3.open(Config.path_cache_db));
	final db    = DbFts(sqlite3.open('database.sqlite3'));

	// Ensure existing notes database
	db.ensure_setup();

	// Get changed notes in Cache
	initializeDateFormatting('en_GB', null);
	List<Note> new_notes = [];
	for (var result in cache.select_updated()) { new_notes.add(Note(result)); }
	cache.dispose();

	// Delete existing versions of updated notes
	db.delete_notes(new_notes.map((e) => e.filename));
	db.insert_notes(new_notes);

	db.dispose();
}