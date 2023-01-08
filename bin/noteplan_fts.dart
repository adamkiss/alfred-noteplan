import 'dart:convert';
import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/about.dart';
import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:alfred_noteplan_fts_refresh/refresh.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

bool _last_update_more_than(int last_update, {int compare = 10}) {
	return DateTime.now().millisecondsSinceEpoch > (last_update + compare);
}

void main (List<String> arguments) {
	final int run_start = Config.ts();
	Config.init();

	final String query = (arguments.isEmpty ? '!!' : arguments.first).trim();

	final db    = DbFts(sqlite3.open(join(Config.workflow_root(), 'database.sqlite3')));
	db.ensure_setup();

	// Refresh & Exit
	if (query == '!r' || query == '!rf') {
		final int update_count = refresh(db, force: query == '!rf');
		print('Updated ${update_count} items in ${Config.ts() - run_start}ms');
		exit(0);
	}

	final List<Map> result = [];

	// About
	if (query == '!!') {
		final about = About();
		print(alf_to_results([
			alf_valid_item('Workflow information', 'Copy to clipboard', variables: {
				'information': about.for_clipboard()
			}),
			alf_invalid_item(about.version, 'Workflow version', text: {'copy': about.version}),
			alf_invalid_item(about.sqlite_version, 'SQLite3 version', text: {'copy': about.sqlite_version}),
			alf_invalid_item(about.macos_version, 'macOS version', text: {'copy': about.macos_version}),
			alf_invalid_item(about.macos_arch, 'mac architecture', text: {'copy': about.macos_arch}),
		]));
		exit(0);
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	print('noop');

	db.dispose();
}