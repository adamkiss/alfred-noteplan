import 'package:alfred_noteplan/alfred.dart';
import 'package:alfred_noteplan/note.dart';
import 'package:alfred_noteplan/note_type.dart';
import 'package:alfred_noteplan/noteplan.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class CodeBit {
	final Note note;
	final String language;
	final String title;
	final String content;

	CodeBit(
		this.note,
		this.language,
		this.title,
		this.content,
	);

	/// alfred result formatter working on raw SQL data
	static Map<String, dynamic> to_alfred_result(Row result) => alf_item(
		result['title'],
		'${result['language']} ✱ ${basenameWithoutExtension(result['filename'])}',
		arg: result['content'],
		icon: {'path': 'icons/icon-code-bit.icns'},
		variables: {'action': 'copy-paste'},
		mods: {
			'cmd': {
				'valid': true,
				'arg': NoteType.create_from_string(result['note_type'] ?? result['type']) == NoteType.note
					? Noteplan.openNoteUrl(result['filename'])
					: Noteplan.openCalendarUrl(basenameWithoutExtension(result['filename'])),
				'subtitle': str_snippet_open_note,
				'variables': {'action': 'open'}
			},
			'shift': {
				'valid': true,
				'subtitle': str_bookmark_copy,
				'variables': {'action': 'copy-to-clipboard'}
			},
		}
	);

}