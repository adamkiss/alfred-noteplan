import 'dart:io';

import 'package:alfred_noteplan/about.dart';
import 'package:alfred_noteplan/alfred.dart';
import 'package:alfred_noteplan/config.dart';
import 'package:alfred_noteplan/date_parser.dart';
import 'package:alfred_noteplan/dbs.dart';
import 'package:alfred_noteplan/note_match.dart';
import 'package:alfred_noteplan/noteplan.dart';
import 'package:alfred_noteplan/refresh.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:tuple/tuple.dart';

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

	final db = Dbs();

	// Refresh & Exit
	if (command == 'refresh') {
		final int update_count = refresh(db, force: query == 'force');
		print(alf_to_results([
			alf_item(
				"${query == 'force' ? 'Force updated' : 'Updated'} ${update_count} items in ${Config.ts() - run_start}ms",
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
		print(alf_to_results(
			db.cache_list_folders(query)
				.map((e) => e.to_alfred())
				.toList(growable: false)
		));

		db.dispose();
		exit(0);
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	// Bookmarks
	if (command == 'hyperlinks') {
		print(alf_to_results(db.search_hyperlinks(query)));
    db.dispose();
		exit(0);
	}

	// Snippets
	if (command == 'code_bits') {
		print(alf_to_results(db.search_code_bits(query)));
    db.dispose();
		exit(0);
	}

	// Date parsing
	if (command == 'date') {
		try {
			final DateParser parsed = DateParser(query);
			final Tuple2 np = parsed.toNoteplan();

			alf_exit([
				alf_item(
					np.item1,
					'Open or create a ${parsed.type!.value} note named "${np.item2}.md"',
					arg: Noteplan.openCalendarUrl(np.item2),
					valid: true,
					variables: {'action':'open'},
					mods: {
						'cmd': {
							'subtitle': str_fts_result_arg_cmd_subtitle,
							'arg': Noteplan.openCalendarUrl(np.item2, sameWindow: false)
						}
					}
				)
			]);
		} catch (e) {
			alf_exit([
				alf_item('…', 'Waiting for a valid query', valid: false)
			]);
		}
	}

	// Finally: Full-text search
	List<NoteMatch> found = db.search_notes(query);
	print(alf_to_results(
		found
			.map((e) => e.to_alfred_result())
			.toList()
			..add(alf_create_item(query))
	));

	// DISPOSE
	db.dispose();
}