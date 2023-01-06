import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

String _cache_database = '/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp/Caches/sync-cache.db';

void main() {
	print('Using sqlite3 ${sqlite3.version.libVersion}');

	final db = sqlite3.open(_cache_database);

	final ResultSet updated = db.select('SELECT count(*) FROM metadata');

	print(updated[0]);

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
}