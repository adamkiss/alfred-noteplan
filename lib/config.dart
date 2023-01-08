import 'dart:io';

import 'package:path/path.dart';

class Config {
	static String noteplan_root = '';

	static String path_cache_db = join(Config.noteplan_root, 'Caches', 'sync-cache.db');

	static int ts() => DateTime.now().millisecondsSinceEpoch;

	static void init() {
		noteplan_root = '/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp';
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