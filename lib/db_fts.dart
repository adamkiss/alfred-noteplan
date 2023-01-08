import 'package:alfred_noteplan_fts_refresh/note.dart';
import 'package:sqlite3/sqlite3.dart';

class DbFts {
	final Database _db;

	DbFts(Database db):
		_db = db
	;

	void dispose() => _db.dispose();

	void ensure_setup() {
		_db.execute('''
			CREATE VIRTUAL TABLE IF NOT EXISTS notes USING fts5(
				file,
				title,
				content,
				type UNINDEXED,
				prefix='1 2 3'
			);
			CREATE TABLE IF NOT EXISTS counter (
				filename TEXT PRIMARY KEY,
				value INTEGER DEFAULT 0
			);
			INSERT INTO counter(filename, value)
			VALUES ('__last_refresh', 0)
			ON CONFLICT(filename) DO NOTHING;
		''');
	}

	void delete_notes(Iterable<String> notes) {
		_db.prepare('''
			DELETE FROM notes
			WHERE file IN (${List.filled(notes.length, '?').join(',')})
		''').execute(notes.toList(growable: false));
	}

	void insert_notes(List<Note> notes) {
		_db.prepare('''
			INSERT INTO notes (file, title, content, type)
			VALUES ${notes.map((_) => '(?, ?, ?, ?)').join(',')}
		''').execute(
			notes.map((e) => [
				e.filename,
				e.title,
				e.content,
				e.type.toString()
			]).expand((e) => e).toList(growable: false)
		);
	}

	int get_last_update() {
		return _db.select('SELECT value FROM counter WHERE filename == "__last_refresh" limit 1;').first['value'];
	}

	void set_last_update({int? timestamp}) {
		_db.prepare('''
			INSERT INTO counter(filename, value)
			VALUES('__last_refresh', ?)
			ON CONFLICT(filename) DO
			UPDATE SET value = excluded.value
		''').execute([timestamp ?? DateTime.now().millisecondsSinceEpoch]);
	}
}