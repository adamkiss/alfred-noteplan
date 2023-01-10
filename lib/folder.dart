import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/noteplan.dart';
import 'package:alfred_noteplan_fts_refresh/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class Folder {
	late final String filename;
	final String note_title;

	Folder (Row row, String with_title):
		filename = row['filename'],
		note_title = with_title
	;

	String _basename() => basename(filename);

	Map<String, dynamic> to_alfred() => alf_item(
		_basename(),
		str_create_folder_result_subtitle(filename, note_title),
		icon: {'path': 'icons/icon-create.icns'},
		arg: create_url(filename, Config.template.replaceAll('TITLE', note_title))
	);
}