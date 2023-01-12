import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:alfred_noteplan_fts_refresh/noteplan.dart';
import 'package:alfred_noteplan_fts_refresh/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class NoteMatch {
	final String filename;
	final String title;
	final String snippet;
	final NoteType type;

	NoteMatch(Row result):
		filename = result['filename'],
		title = result['title'],
		snippet = result['snippet'],
		type = NoteType.create_from_string(result['type'])
	;

	bool _is_note() => (type == NoteType.note);

	String _path() => dirname(filename);
	String _basename() => basenameWithoutExtension(filename);
	String _subtitle() => _is_note()
		? '${_path()} ✱ ${snippet}'
		: snippet;
	String _arg({bool sameWindow = true}) => _is_note()
		? Noteplan.openNoteUrl(filename, sameWindow: sameWindow)
		: Noteplan.openCalendarUrl(_basename(), sameWindow: sameWindow);


	Map<String, dynamic> to_alfred_result() {
		return alf_item(
			title, _subtitle(),
			arg: _arg(),
			variables: {'action': 'open'},
			mods: {
				'cmd': {
					'valid': true,
					'arg': _arg(sameWindow: false),
					'subtitle': str_fts_result_arg_cmd_subtitle
				}
			},
			icon: {'path': 'icons/icon-${type.value}.icns'},
			quicklookurl: join(Config.noteplan_root, type.np_folder, filename),
		);
	}
}