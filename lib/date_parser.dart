import 'dart:collection';

import 'package:intl/intl.dart';

class DateParser {
	late final String query;

	DateParser(String q) {
		RegExp query_check = RegExp(r'^[:>]\s*?(.*)$');
		if (! query_check.hasMatch(q)) {
			throw ArgumentError('Date query "${query}" does not match required format.');
		}

		// hasMatch before means… it has match and one matched group
		query = query_check.firstMatch(q)!.group(1)!.trim();
	}

	String to_filename() {
		return '${DateFormat('yMMdd').format(_find_match())}.md';
	}

	static final LinkedHashMap<RegExp, DateTime Function(RegExpMatch)> _matchers = LinkedHashMap.from({
		RegExp(r'^(?:t|tod|toda|today)$'):
			(RegExpMatch m) => DateTime.now()
	});

	DateTime _find_match() {
		for (var matcher in _matchers.keys) {
			if (matcher.hasMatch(query)) {
				final RegExpMatch fm = matcher.firstMatch(query)!;
				return _matchers[matcher]!(fm);
			}
		}

		throw ArgumentError('Date query "${query}" invalid.');
	}
}