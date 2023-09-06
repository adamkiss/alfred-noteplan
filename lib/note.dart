import 'dart:convert';

import 'package:alfred_noteplan/hyperlink.dart';
import 'package:alfred_noteplan/note_type.dart';
import 'package:alfred_noteplan/code_bit.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class Note {
	final String filename;
	final String content_raw;
	final int modified;
	late final NoteType type;

	late final String title;
	late final String content;
	Map<String, dynamic> data = {};

	late final List<Hyperlink> hyperlinks;
	late final List<CodeBit> code_bits;

	Note(
		this.filename,
		this.content_raw,
		this.modified,
		final int note_type
	){
		final bname = basenameWithoutExtension(filename);

		/** NOTES */
		if (note_type == 1) {
			type = NoteType.note;

			final parsed_content = content_raw.startsWith('---')
				? _parse_frontmatter(content_raw)
				: _parse_markdown(content_raw, bname);

			title = parsed_content.$1;
			content = parsed_content.$2.cleanForFts();
			hyperlinks = _parse_hyperlinks(parsed_content.$2);
			code_bits = _parse_code_bits(parsed_content.$2);
			return;
		}

		/** CALENDAR */
		content = content_raw.cleanForFts();
		hyperlinks = _parse_hyperlinks(content_raw);
		code_bits = _parse_code_bits(content_raw);


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

	/// Prepare [Row] as arguments for constructor and return new [Note]
	static Note fromRow(Row record) {
		return Note(
			record['filename'],
			utf8.decode(record['content']).trim(),
			record['modified'],
			record['note_type']
		);
	}

	(String, String) _parse_frontmatter(String raw) {
		final fm = RegExp(
			r'^---.*?title\:\s*?(.*?)\n.*?---(.*)',
			caseSensitive: false,
			dotAll: true
		);

		final match = fm.firstMatch(raw);
		return (
			match!.group(1)!.trim(), // title
			match.group(2)!.trim() // content
		);
	}

	(String, String) _parse_markdown(String raw, String bname) {
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

		return (title, content);
	}

	List<Hyperlink> _parse_hyperlinks(String? body) {
		body ??= content;
		final RegExp bookmark_re = RegExp(r'\[(?<title>[^\[\]]*?)\]\((?<url>[^\[\]]*?)\)');
		final Iterable<RegExpMatch> matches = bookmark_re.allMatches(body);

		if (matches.isEmpty) {
			return [];
		}

		return matches
			.map((RegExpMatch i) {
				// Discard probably Noteplan files/images
				if (
					i.namedGroup('title')! == 'file' ||
					i.namedGroup('title')! == 'image'
				) {
					return null;
				}

				return Hyperlink(this, i.namedGroup('title')!, i.namedGroup('url')!);
			})
			.where((e) => e != null)
			.toList(growable: false)
			.cast<Hyperlink>();
	}

	List<CodeBit> _parse_code_bits(String? body) {
		body ??= content;

		final RegExp snippet_re = RegExp(r'^```(?<language>.*?)\s*\((?<title>.*?)\)?$\n(?<content>[\s\S]*?)^```', multiLine: true);
		final Iterable<RegExpMatch> matches = snippet_re.allMatches(body);

		if (matches.isEmpty) {
			return [];
		}

		return matches
			.map((RegExpMatch m) => CodeBit(
				this,
				m.namedGroup('language')!.trim(),
				m.namedGroup('title')!.trim(),
				m.namedGroup('content')!.trim(),
			))
			.toList(growable: false)
			.cast<CodeBit>();
	}
}