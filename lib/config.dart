import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/strings.dart';
import 'package:path/path.dart';

class Config {
	static String noteplan_root = '';

	static String path_cache_db = join(Config.noteplan_root, 'Caches', 'sync-cache.db');

	static int ts() => DateTime.now().millisecondsSinceEpoch;

	static void init() {
		// runtime dependencies
		if (!Platform.environment.containsKey('user_np_root')) {
			Config.error(str_error_missing_root);
		}

		noteplan_root = Platform.environment['user_np_root']!;
	}

	static void error(String err) {
		print(str_usage);
		print('Error: ${err}');
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