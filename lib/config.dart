import 'package:path/path.dart';

class Config {
	static String root = '';

	static String path_cache_db = join(Config.root, 'Caches', 'sync-cache.db');

	static int ts() => DateTime.now().millisecondsSinceEpoch;

	static void init() {
		root = '/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp';
	}
}