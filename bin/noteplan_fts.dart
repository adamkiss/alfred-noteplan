import 'dart:convert';
import 'dart:io';

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
		String workflow_version = Process.runSync('defaults', ['read', join(Config.workflow_root(), 'info'), 'version']).stdout.trim();
		String macos_version = Process.runSync('sw_vers', ['-productVersion']).stdout.trim();
		String macos_architecture = Process.runSync('uname', ['-m']).stdout.trim();

		final copy_to_clipboard =
			'Workflow version: ${workflow_version}\n'
			'SQLite3 version: ${sqlite3.version.toString()}\n'
			'macOS: ${macos_version} / ${macos_architecture}'
		;

		print(alf_to_results([
			alf_valid_item('Workflow information', 'Copy to clipboard', variables: {
				'information': copy_to_clipboard
			}),
			alf_invalid_item(workflow_version, 'Workflow version', text: {'copy': workflow_version}),
			alf_invalid_item(sqlite3.version.toString(), 'SQLite3 version', text: {'copy': sqlite3.version.toString()}),
			alf_invalid_item(macos_version, 'macOS version', text: {'copy': macos_version}),
			alf_invalid_item(macos_architecture, 'mac architecture', text: {'copy': macos_architecture}),
		]));
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	print('noop');

	// print('Using sqlite3 ${sqlite3.version.libVersion}');
	db.dispose();
}