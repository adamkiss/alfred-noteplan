import 'dart:developer';

import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:alfred_noteplan_fts_refresh/note.dart';

void refresh({bool force = false}) {
	// print('Using sqlite3 ${sqlite3.version.libVersion}');
	inspect(Config.path_cache_db);
	final cache = sqlite3.open(Config.path_cache_db);
	final db    = sqlite3.open('database.sqlite3');

	// Ensure existing notes database
	db.execute('''
		DROP TABLE IF EXISTS notes;
		DROP TABLE IF EXISTS counter;
		CREATE VIRTUAL TABLE notes USING fts5(
			file,
			title,
			content,
			type UNINDEXED,
			prefix='2 3 4'
		);
		CREATE TABLE counter (
			key TEXT PRIMARY KEY,
			value INTEGER DEFAULT 0
		);
	''');

	// Get changed notes in Cache
	final ResultSet updated = cache.select('''
		SELECT filename, content, modified, note_type
		FROM metadata
		WHERE
			is_directory = 0
		AND LENGTH(content)
		AND note_type < 2
		AND modified > 0
	''');
	initializeDateFormatting('en_GB', null);
	List<Note> new_notes = [];
	for (var result in updated) { new_notes.add(Note(result)); }

	// Delete existing versions of updated notes
	db.prepare('''
		DELETE FROM notes
		WHERE file IN (${new_notes.map((_) => '?').join(',')})
	''').execute(new_notes.map((e) => e.filename).toList(growable: false));

	// Prepare massive update
	db.prepare('''
		INSERT INTO notes (file, title, content, type)
		VALUES ${new_notes.map((_) => '(?, ?, ?, ?)').join(',')}
	''').execute(
		new_notes.map((e) => [
			e.filename,
			e.title,
			e.content,
			e.type.toString()
		]).expand((e) => e).toList(growable: false)
	);
//
// 	// Create a table and insert some data
// 	db.execute('''
// 		CREATE TABLE artists (
// 			id INTEGER NOT NULL PRIMARY KEY,
// 			name TEXT NOT NULL
// 		);
// 	''');
//
// 	// Prepare a statement to run it multiple times:
// 	final stmt = db.prepare('INSERT INTO artists (name) VALUES (?)');
// 	stmt
// 		..execute(['The Beatles'])
// 		..execute(['Led Zeppelin'])
// 		..execute(['The Who'])
// 		..execute(['Nirvana']);
//
// 	// Dispose a statement when you don't need it anymore to clean up resources.
// 	stmt.dispose();
//
// 	// You can run select statements with PreparedStatement.select, or directly
// 	// on the database:
// 	final ResultSet resultSet =
// 			db.select('SELECT * FROM artists WHERE name LIKE ?', ['The %']);
//
// 	// You can iterate on the result set in multiple ways to retrieve Row objects
// 	// one by one.
// 	for (final Row row in resultSet) {
// 		print('Artist[id: ${row['id']}, name: ${row['name']}]');
// 	}
//
// 	// Register a custom function we can invoke from sql:
// 	db.createFunction(
// 		functionName: 'dart_version',
// 		argumentCount: const AllowedArgumentCount(0),
// 		function: (args) => Platform.version,
// 	);
// 	print(db.select('SELECT dart_version()'));
//
// 	// Don't forget to dispose the database to avoid memory leaks
	db.dispose();
	cache.dispose();
}