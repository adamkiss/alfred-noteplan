import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:alfred_noteplan_fts_refresh/refresh.dart';
import 'package:sqlite3/sqlite3.dart';

bool _last_update_more_than(int last_update, {int compare = 10}) {
	return DateTime.now().millisecondsSinceEpoch > (last_update + compare);
}

void main(List<String> arguments) {
	final int run_start = Config.ts();
	Config.init();

	final String command = arguments.isEmpty ? 'top' : arguments[0];
	final List<String> args = arguments.length > 1 ? arguments.sublist(1) : [];

	final db    = DbFts(sqlite3.open('database.sqlite3'));
	db.ensure_setup();

	// Refresh & Exit
	if (command == 'refresh') {
		final int update_count = refresh(db, force: args.isNotEmpty && args.first == 'force');
		print('Updated ${update_count} items in ${Config.ts() - run_start}ms');
		exit(0);
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	print('noop');

	// print('Using sqlite3 ${sqlite3.version.libVersion}');
	db.dispose();
}