import 'package:alfred_noteplan/alfred.dart';
import 'package:alfred_noteplan/note.dart';
import 'package:alfred_noteplan/note_type.dart';
import 'package:alfred_noteplan/noteplan.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class Hyperlink{
	final Note note;
	final String url;
	final String title;
	String? description; // currently noop

	Hyperlink(
		this.note,
		this.title,
		this.url,
		{this.description}
	);

	/// alfred result formatter working on raw SQL data
	static Map<String, dynamic> to_alfred_result(Row result) => alf_item(
		result['title'],
		'${basenameWithoutExtension(result['filename'])} ✱ ${result['url']}',
		arg: result['url'],
		icon: {'path': 'icons/icon-hyperlink.icns'},
		variables: {'action': 'open'},
		mods: {
			'cmd': {
				'valid': true,
				'arg': NoteType.create_from_string(result['note_type']) == NoteType.note
					? Noteplan.openNoteUrl(result['filename'])
					: Noteplan.openCalendarUrl(basenameWithoutExtension(result['filename'])),
				'subtitle': str_bookmark_open_note
			},
			'shift': {
				'valid': true,
				'subtitle': str_bookmark_copy,
				'variables': {'action': 'copy-to-clipboard'}
			},
			'cmd+shift': {
				'valid': true,
				'subtitle': str_bookmark_copy_paste,
				'variables': {'action': 'copy-paste'}
			},
		}
	);
}