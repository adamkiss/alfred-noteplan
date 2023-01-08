import 'package:sqlite3/sqlite3.dart';

class DbCache {
	final Database _db;

	DbCache(Database db):
		_db = db
	;

	void dispose() => _db.dispose();

	ResultSet select_updated({int since = 0}) {
		return _db.select('''
			SELECT filename, content, modified, note_type
			FROM metadata
			WHERE
				is_directory = 0
			AND LENGTH(content)
			AND note_type < 2
			AND modified > ?
		''', [since]);
	}
}