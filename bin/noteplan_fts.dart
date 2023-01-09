import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/about.dart';
import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_cache.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:alfred_noteplan_fts_refresh/note_match.dart';
import 'package:alfred_noteplan_fts_refresh/refresh.dart';
import 'package:alfred_noteplan_fts_refresh/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

bool _last_update_more_than(int last_update, {int compare = 10}) {
	return DateTime.now().millisecondsSinceEpoch > (last_update + compare);
}

void main (List<String> arguments) {
	final int run_start = Config.ts();
	Config.init();

	if (arguments.isEmpty) {
		Config.error(str_error_missing_command);
	}

	final String command = arguments.first;
	final String query = arguments.sublist(1).join(' ').trim();

	final db = DbFts(sqlite3.open(join(Config.workflow_root(), 'database.sqlite3')));
	db.ensure_setup();

	// Refresh & Exit
	if (command == 'refresh') {
		final int update_count = refresh(db, force: query == 'force');
		print(alf_to_results([
			alf_valid_item(
				"Updated ${update_count} items in ${Config.ts() - run_start}ms",
				str_update_subtitle,
				arg: '🎉',
				variables: {'action': 'close'}
			)
		]));
		exit(0);
	}

	// About
	if (command == 'debug') {
		final about = About();
		print(about.to_alfred());

		db.dispose();
		exit(0);
	}

	// From now on, we totally need query, so die if it's empty
	if (query.isEmpty) {
		Config.error(str_error_missing_args);
	}

	// Create new note
	if (command == 'create') {
		final cache = DbCache(sqlite3.open(Config.path_cache_db));
		print(cache.select_folders());

		cache.dispose();
		db.dispose();
		exit(0);
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	// Date parsing
	if (command == 'date') {
		final String? to_parse = RegExp(r'^>\s*(.*?)$').stringMatch(query);
		if (to_parse == null) {
			Config.error(str_error_date_unparsable);
		}
	}

	// Finally: Full-text search
	List<NoteMatch> found = db.search(query);
	print(alf_to_results(
		found
			.map((e) => e.to_alfred_result())
			.toList()
			..add(alf_create_item(query))
	));

	// DISPOSE
	db.dispose();
}