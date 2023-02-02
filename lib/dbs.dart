import 'package:alfred_noteplan/hyperlink.dart';
import 'package:alfred_noteplan/config.dart';
import 'package:alfred_noteplan/folder.dart';
import 'package:alfred_noteplan/note.dart';
import 'package:alfred_noteplan/note_match.dart';
import 'package:alfred_noteplan/code_bit.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class Dbs {
	late final Database _db;

	Dbs() {
		_db = sqlite3.open(join(Config.workflow_root(), 'database.sqlite3'));
		attach_db(Config.path_cache_db);
		ensure_setup();
	}

	void dispose() => _db.dispose();

	void attach_db(String path) {
		_db.execute('''
			ATTACH DATABASE '${path}' AS cache;
		''');
	}

	void ensure_setup() {
		_db.execute('''
			CREATE VIRTUAL TABLE IF NOT EXISTS main.notes USING fts5(
				filename,
				title,
				content,
				type UNINDEXED,
				prefix='1 2 3'
			);
			CREATE VIRTUAL TABLE IF NOT EXISTS main.hyperlinks USING fts5(
				filename UNINDEXED,
				note_type UNINDEXED,
				title,
				url,
				description,
				prefix='3 4 5'
			);
			CREATE VIRTUAL TABLE IF NOT EXISTS main.code_bits USING fts5(
				filename UNINDEXED,
				note_type UNINDEXED,
				language,
				title,
				content,
				prefix='3 4 5'
			);
			CREATE TABLE IF NOT EXISTS main.counter (
				filename TEXT PRIMARY KEY,
				value INTEGER DEFAULT 0
			);
			INSERT INTO main.counter(filename, value)
			VALUES ('__last_refresh', 0)
			ON CONFLICT(filename) DO NOTHING;
		''');
	}

	void delete_where_filename_in(String table, Iterable<String> notes) {
		_db.prepare('''
			DELETE FROM main.${table}
			WHERE filename IN (${List.filled(notes.length, '?').join(',')})
		''').execute(notes.toList(growable: false));
	}

	void delete_missing_notes() {
		_db.execute('''
			WITH deleted as (
				SELECT
					main.notes.filename as filename,
					cache.metadata.filename as c
				FROM
					main.notes
				LEFT JOIN cache.metadata USING(filename)
				WHERE c IS null
			)
			DELETE FROM main.notes
			WHERE main.notes.filename IN (SELECT filename FROM deleted);
		''');
	}

	void insert_notes(List<Note> notes) {
		_db.prepare('''
			INSERT INTO main.notes (filename, title, content, type)
			VALUES ${notes.map((_) => '(?, ?, ?, ?)').join(',')}
		''').execute(
			notes.map((e) => [
				e.filename,
				e.title,
				e.content,
				e.type.value
			]).expand((e) => e).toList(growable: false)
		);
	}

	void insert_hyperlinks(List<Note> notes) {
		List<Hyperlink> hyperlinks = [];
		for (var note in notes) {
			hyperlinks.addAll(note.hyperlinks);
		}

		_db.prepare('''
			INSERT INTO main.hyperlinks (filename, note_type, title, url)
			VALUES ${hyperlinks.map((_) => '(?, ?, ?, ?)').join(',')}
		''').execute(
			hyperlinks.map((e) => [
				e.note.filename,
				e.note.type.value,
				e.title,
				e.url
			]).expand((e) => e).toList(growable: false)
		);
	}

	void insert_code_bits(List<Note> notes) {
		List<CodeBit> code_bits = [];
		for (var note in notes) {
			code_bits.addAll(note.code_bits);
		}

		_db.prepare('''
			INSERT INTO main.code_bits (filename, note_type, language, title, content)
			VALUES ${code_bits.map((_) => '(?, ?, ?, ?, ?)').join(',')}
		''').execute(
			code_bits.map((e) => [
				e.note.filename,
				e.note.type.value,
				e.language,
				e.title,
				e.content,
			]).expand((e) => e).toList(growable: false)
		);
	}

	int get_last_update() {
		return _db.select('SELECT value FROM main.counter WHERE filename == "__last_refresh" limit 1;').first['value'];
	}

	void set_last_update({int? timestamp}) {
		_db.prepare('''
			INSERT INTO main.counter(filename, value)
			VALUES('__last_refresh', ?)
			ON CONFLICT(filename) DO
			UPDATE SET value = excluded.value
		''').execute([timestamp ?? DateTime.now().millisecondsSinceEpoch]);
	}

	List<NoteMatch> search_notes(String query, {int limit = 18}) {
		final String preparedQuery = query.toFtsQuery();
		final ResultSet results = _db.select('''
			SELECT
				filename,
				title,
				type,
				snippet(notes, 2, '${str_open_snippet}', '${str_close_snippet}', '…', 5) as snippet
			FROM
				main.notes('${preparedQuery}')
			ORDER BY
				rank
			LIMIT
				${limit}
		''');

		return results.map((Row row) => NoteMatch(row)).toList(growable: false);
	}

	List<Map<String, dynamic>> search_hyperlinks(String query, {int limit = 18}) {
		final String preparedQuery = query.toFtsQuery();
		final ResultSet results = _db.select('''
			SELECT
				filename,
				note_type,
				title,
				url
			FROM
				main.hyperlinks('${preparedQuery}')
			ORDER BY
				rank
			LIMIT
				${limit}
		''');

		return results.map((Row result) => Hyperlink.to_alfred_result(result)).toList(growable: false);
	}

	List<Map<String, dynamic>> search_code_bits(String query, {int limit = 18}) {
		final String preparedQuery = query.toFtsQuery();
		final ResultSet results = _db.select('''
			SELECT
				filename,
				note_type,
				language,
				title,
				content
			FROM
				main.code_bits('${preparedQuery}')
			ORDER BY
				rank
			LIMIT
				${limit}
		''');

		return results.map((Row result) => CodeBit.to_alfred_result(result)).toList(growable: false);
	}

	List<Map<String, dynamic>> search_all(String query) {
		final String preparedQuery = query.toFtsQuery();
		final ResultSet results = _db.select('''
			SELECT
				'note' as result_type,
				filename,
				title,
				type,
				snippet(notes, 2, '${str_open_snippet}', '${str_close_snippet}', '…', 5) as content,
				rank
			FROM
				main.notes('${preparedQuery}')
			UNION
			SELECT
				'hyperlink' as result_type,
				filename,
				title,
				note_type,
				url,
				rank
			FROM
				main.hyperlinks('${preparedQuery}')
			UNION
			SELECT
				'code bit' as result_type,
				filename,
				title,
				note_type,
				content,
				rank
			FROM
				main.code_bits('${preparedQuery}')
			ORDER BY
				rank
			LIMIT
				18
		''');

		return results.map((Row result) {
			switch (result['result_type']) {
			  case 'note': return NoteMatch(result).to_alfred_result();
			  case 'hyperlink': return Hyperlink.to_alfred_result(result);
			  case 'code bit': return CodeBit.to_alfred_result(result);
			  default: throw Exception('Unknown result type: ${result['result_type']}');
			}
		}).toList(growable: false);
	}

	ResultSet cache_get_updated({int since = 0}) {
		final String ignore_condition = Config.ignore.isEmpty
			? ''
			: ' AND ${
				Config.ignore.map((e) => 'filename NOT LIKE "${e}%"').join(' AND ')
			}';

		return _db.select('''
			SELECT filename, content, modified, note_type
			FROM cache.metadata
			WHERE
				is_directory = 0
			AND LENGTH(content)
			AND note_type < 2
			AND modified > ?${ignore_condition}
		''', [since]);
	}

	List<Folder> cache_list_folders(String with_title) {
		final folders = _db.select('''
			SELECT filename
			FROM cache.metadata
			WHERE
				is_directory = 1
			AND note_type = 1
			AND filename NOT LIKE '@%'
		''');

		return folders
			.map((e) => Folder(e, with_title))
			.toList(growable: false);
	}
}