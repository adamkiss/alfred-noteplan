import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tuple/tuple.dart';

enum NoteType {
	note,
	daily,
	weekly,
	monthly,
	quarterly,
	yearly
}

class Note {
	static const String fmtDaily = 'dd.MM.y, EEEE'; // datetime
	static const String fmtWeekly = 'Week %w %y';
	static const String fmtMonthly = 'MMMM y'; // datetime
	static const String fmtQuarterly = "Q%q %y";
	static const String fmtYearly = '%y';

	final String filename;
	final String content_raw;
	final int modified;
	late final NoteType type;

	late final String title;
	late final String content;
	late final String path;

	Note(Row record):
		filename = record['filename'],
		content_raw = utf8.decode(record['content']).trim(),
		modified = record['modified']
	{
		final note_type = record['note_type'];
		final bname = basenameWithoutExtension(filename);
		var rmatch; // Re-assignable utility

		path = dirname(filename);

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
			rmatch = RegExp(r'(\d+)-[A-Z](\d+)').firstMatch(bname);
			title = fmtWeekly
				.replaceAll('%w', rmatch.group(2)!)
				.replaceAll('%y', rmatch.group(1)!);
			type = NoteType.weekly;
			return;
		}
		if (bname.contains('Q')) { // Quarter
			rmatch = RegExp(r'(\d+)-[A-Z](\d+)').firstMatch(bname);
			title = fmtQuarterly
				.replaceAll('%q', rmatch.group(2)!)
				.replaceAll('%y', rmatch.group(1)!);
			type = NoteType.quarterly;
			return;
		}

		RegExp match_month = RegExp(r'^(\d{4})-(\d{2})$');
		if (match_month.hasMatch(bname)) { // Month
			rmatch = match_month.firstMatch(bname);
			var first_of = DateTime(
				int.parse(rmatch.group(1)!, radix: 10),
				int.parse(rmatch.group(2)!, radix: 10)
			);
			title = DateFormat(fmtMonthly, 'en_GB').format(first_of);
			type = NoteType.monthly;
			return;
		}

		RegExp match_year = RegExp(r'^(\d{4})$');
		if (match_year.hasMatch(bname)) { // Week
			rmatch = match_year.firstMatch(bname);
			title = fmtYearly.replaceAll('%y', rmatch.group(1)!);
			type = NoteType.yearly;
			return;
		}

		// Now it's a dailynote
		rmatch = RegExp(r'^(\d{4})(\d{2})(\d{2})').firstMatch(bname);
		inspect(bname);
		var dt = DateTime(
			int.parse(rmatch.group(1)!, radix: 10),
			int.parse(rmatch.group(2)!, radix: 10),
			int.parse(rmatch.group(3)!, radix: 10)
		);
		title = DateFormat(fmtDaily, 'en_GB').format(dt);
		type = NoteType.daily;
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