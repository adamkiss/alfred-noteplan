import 'dart:convert';
import 'dart:developer';

import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tuple/tuple.dart';

class Note {
	final String filename;
	final String content_raw;
	final int modified;
	late final NoteType type;

	late final String title;
	late final String content;
	Map<String, dynamic> data = {};

	Note(Row record):
		filename = record['filename'],
		content_raw = utf8.decode(record['content']).trim(),
		modified = record['modified']
	{
		final note_type = record['note_type'];
		final bname = basenameWithoutExtension(filename);

		/** NOTES */
		if (note_type == 1) {
			type = NoteType.note;

			final parsed_content = content_raw.startsWith('---')
				? _parse_frontmatter(content_raw)
				: _parse_markdown(content_raw, bname);

			title = parsed_content.item1;
			content = _fts_clean(parsed_content.item2);
			return;
		}

		/** CALENDAR */
		content = _fts_clean(content_raw);

		if (bname.contains('W')) { // Week
			type = NoteType.weekly;

		} else if (bname.contains('Q')) { // Quarter
			type = NoteType.quarterly;

		} else if (RegExp(r'^(\d{4})-(\d{2})$').hasMatch(bname)) { // Month
			type = NoteType.monthly;

		} else if (RegExp(r'^(\d{4})$').hasMatch(bname)) { // Week
			type = NoteType.yearly;

		} else {
			type = NoteType.daily;
		}

		title = type.formatBasename(bname);

	}

	Tuple2 _parse_frontmatter(String raw) {
		final fm = RegExp(
			r'^---.*?title\:\s*?(.*?)\n.*?---(.*)',
			caseSensitive: false,
			dotAll: true
		);

		final match = fm.firstMatch(raw);
		return Tuple2(
			match!.group(1)!.trim(), // title
			match.group(2)!.trim() // content
		);
	}

	Tuple2 _parse_markdown(String raw, String bname) {
		final h1 = RegExp(r'^#\s*(.*)(?:\n|\s---)');
		late String title;
		late String content;

		if (h1.hasMatch(raw)) { // has h1 as the first line
			final match = h1.firstMatch(raw);
			title = match!.group(1)!.trim();
			content = raw.replaceFirst(match.group(0)!, '').trim();
		} else {
			title = bname;
			content = raw;
		}

		return Tuple2(title, content);
	}

	String _fts_clean(String body) {
		return body
			// remove markdown headers
			.replaceAll(RegExp(r'^#*\s*?', multiLine: true), '')
			// remove markdown hr
			.replaceAll(RegExp(r'^\s*?\-{3,}\s*?$', multiLine: true), '')
			// remove bullets & quotes
			.replaceAll(RegExp(r'^\s*?[\*>-]\s*?', multiLine: true), '')
			// remove tasks
			.replaceAll(RegExp(r'^\s*?[*-]?\s*?\[.?\]\s*?', multiLine: true), '')
			// remove markdown styling
			.replaceAll(RegExp(r'[*_]'), '')
			// collapse whitespace
			.replaceAll(RegExp(r'\s+/'), ' ')
			.trim() // trim
		;
	}
}