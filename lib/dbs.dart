import 'package:alfred_noteplan/bookmark.dart';
import 'package:alfred_noteplan/config.dart';
import 'package:alfred_noteplan/folder.dart';
import 'package:alfred_noteplan/note.dart';
import 'package:alfred_noteplan/note_match.dart';
import 'package:alfred_noteplan/snippet.dart';
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
			CREATE VIRTUAL TABLE IF NOT EXISTS main.bookmarks USING fts5(
				filename UNINDEXED,
				title,
				url,
				description,
				prefix='2 3 4'
			);
			CREATE VIRTUAL TABLE IF NOT EXISTS main.snippets USING fts5(
				filename UNINDEXED,
				language,
				title,
				content,
				prefix='2 3 4'
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

	void insert_bookmarks(List<Note> notes) {
		List<Bookmark> bookmarks = [];
		for (var note in notes) {
			bookmarks.addAll(note.bookmarks);
		}

		_db.prepare('''
			INSERT INTO main.bookmarks (filename, title, url)
			VALUES ${bookmarks.map((_) => '(?, ?, ?)').join(',')}
		''').execute(
			bookmarks.map((e) => [
				e.filename,
				e.title,
				e.url
			]).expand((e) => e).toList(growable: false)
		);
	}

	void insert_snippets(List<Note> notes) {
		List<Snippet> snippets = [];
		for (var note in notes) {
			snippets.addAll(note.snippets);
		}

		_db.prepare('''
			INSERT INTO main.snippets (filename, language, title, content)
			VALUES ${snippets.map((_) => '(?, ?, ?, ?)').join(',')}
		''').execute(
			snippets.map((e) => [
				e.filename,
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

	String _query_to_fts_query(String query) {
		return '${query
			.replaceAll(RegExp(r'[^\p{L}\s\d]', unicode: true), '')
			.replaceAll(RegExp(r'\s+'), ' ')
			.trim()
			.replaceAll(' ', '* ')}'
			'*';
	}

	List<NoteMatch> search(String query) {
		final String preparedQuery = _query_to_fts_query(query);
		final ResultSet results = _db.select('''
			SELECT
				filename,
				title,
				type,
				snippet(notes, 2, '›', '‹', '…', 5) as snippet
			FROM
				main.notes('${preparedQuery}')
			ORDER BY
				rank
			LIMIT
				18
		''');

		return results.map((Row row) => NoteMatch(row)).toList(growable: false);
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