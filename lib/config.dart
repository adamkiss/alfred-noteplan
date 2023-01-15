import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/strings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';

class Config {
	static String noteplan_root = '';
	static String locale = 'en_GB';
	static String template = ''
		'---''\n'
		'title: TITLE''\n'
		'---''\n'
		'\n';
	static List<String> ignore = [];
	static int week_starts_on = DateTime.monday;
	static bool parse_exact_date_with_space_with_day_first = false;

	static String path_cache_db = join(Config.noteplan_root, 'Caches', 'sync-cache.db');

	static int ts() => DateTime.now().millisecondsSinceEpoch;

	static const String titleFormatDaily = 'dd.MM.y, EEEE'; // datetime
	static const String titleFormatWeekly = 'Week %w %y';
	static const String titleFormatMonthly = 'MMMM y'; // datetime
	static const String titleFormatQuarterly = "Q%q %y";
	static const String titleFormatYearly = '%y';

	static void init() {
		// runtime dependencies
		if (!Platform.environment.containsKey('user_np_root')) {
			Config.error(str_error_missing_root);
		}

		noteplan_root = Directory(Platform.environment['user_np_root']!).absolute.path;
		locale = Platform.environment['user_locale'] ?? locale;
		template = Platform.environment['user_new_note_template'] ?? template;
		ignore = (Platform.environment['user_ignore_files'] ?? '')
			.trim().split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty)
			.toList(growable: false);
		week_starts_on = int.tryParse(Platform.environment['user_week_starts_on'] ?? '1', radix: 10) ?? week_starts_on;
		parse_exact_date_with_space_with_day_first = int.tryParse(Platform.environment['user_exact_day_first'] ?? '0', radix: 10) == 1;

		initializeDateFormatting(locale, null);
	}

	static void error(String err) {
		print(alf_to_results([
			alf_item(
				err,
				'There has been an error in the noteplan_fts binary',
				valid: false,
				icon: {'path': 'icons/icon-error.icns'}
			)
		]));
		exit(1);
	}

	static final bool _current_contains_info_plist = Directory('.').listSync().map((e) => basename(e.path)).contains('info.plist');
	static Directory workflow_root_as_directory() {
		return _current_contains_info_plist
			? Directory('.')
			: Directory('./workflow');
	}
	static String workflow_root() {
		return normalize(workflow_root_as_directory().absolute.path);
	}
}