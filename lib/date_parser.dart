import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:alfred_noteplan_fts_refresh/date_utils.dart';
import 'package:tuple/tuple.dart';

class DateParser {
	final String query;
	NoteType? type;
	DateTime? dt;

	DateParser(String q):
		query = q.trim()
	{
		for (var matcher in _matchers) {
			if (matcher.matches(query)) {
				type = matcher.t;
				dt = matcher.process(query);
				break;
			}
		}

		if (dt == null) {
			throw ArgumentError('Date query "${query}" invalid.');
		}
	}

	Tuple2<String, String> toNoteplan() => dt!.toNoteplan(type!);

	static int _maybeParse(String? parseMatch, int defaultValue) {
		return int.tryParse(parseMatch ?? '', radix: 10) ?? defaultValue;
	}

	static int  _fromSymbol(String? symbolMatch) => (symbolMatch == '-') ? -1 : 1;

	static bool _isSymbol(String? symbolMatch) => (symbolMatch == '+' || symbolMatch == '-');

	static final List<DateParserMatcher> _matchers = [

		// word today
		DateParserMatcher(
			RegExp(r'^(?:t|tod|toda|today)$'),
			(RegExpMatch m) => DateTime.now(),
			NoteType.daily
		),

		// word tomorrow
		DateParserMatcher(
			RegExp(r'^tom(?:o(?:r(?:r(?:o(?:w)?)?)?)?)?$'),
			(RegExpMatch m) => DateTime.now().add(Duration(days: 1)),
			NoteType.daily
		),


		// word yesterday
		DateParserMatcher(
			RegExp(r'^yes(?:t(?:e(?:r(?:d(?:a(?:y)?)?)?)?)?)?$'),
			(RegExpMatch m) => DateTime.now().subtract(Duration(days: 1)),
			NoteType.daily
		),

		// exact full ymd
		DateParserMatcher(
			RegExp(r'^(\d{4})(\d{2})(\d{2})$'),
			(RegExpMatch m) => DateTime(
				int.parse(m.group(1)!, radix: 10),
				int.parse(m.group(2)!, radix: 10),
				int.parse(m.group(3)!, radix: 10)
			),
			NoteType.daily
		),

		// exact short ymd
		DateParserMatcher(
			RegExp(r'^(\d{2})(\d{2})(\d{2})$'),
			(RegExpMatch m) => DateTime(
				2000 + int.parse(m.group(1)!, radix: 10),
				int.parse(m.group(2)!, radix: 10),
				int.parse(m.group(3)!, radix: 10)
			),
			NoteType.daily
		),

		// exact md
		DateParserMatcher(
			RegExp(r'^(\d{2})(\d{2})$'),
			(RegExpMatch m) => DateTime(
				DateTime.now().year,
				int.parse(m.group(1)!, radix: 10),
				int.parse(m.group(2)!, radix: 10)
			),
			NoteType.daily
		),

		// exact md
		DateParserMatcher(
			RegExp(r'^(\d{1,2})([/\.])(\d{1,2})$'),
			(RegExpMatch m) => DateTime(
				DateTime.now().year,
				int.parse(m.group(m.group(2)! == '/' ? 1 : 3)!, radix: 10),
				int.parse(m.group(m.group(2)! == '/' ? 3 : 1)!, radix: 10)
			),
			NoteType.daily
		),

		// exact md with space
		DateParserMatcher(
			RegExp(r'^(\d{1,2}) +(\d{1,2})$'),
			(RegExpMatch m) => DateTime(
				DateTime.now().year,
				int.parse(m.group(Config.parse_exact_date_with_space_with_day_first ? 2 : 1)!, radix: 10),
				int.parse(m.group(Config.parse_exact_date_with_space_with_day_first ? 1 : 2)!, radix: 10)
			),
			NoteType.daily
		),

		// daily shift: days
		DateParserMatcher(
			RegExp(r'^([-+]?)\s*?(\d*)\s*?d$'),
			(RegExpMatch m) {
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), 1);
				return DateTime.now().add(Duration(days: shift));
			},
			NoteType.daily
		),

		// daily shift: weeks
		DateParserMatcher(
			RegExp(r'^([-+]?)\s*?(\d+)\s*?wk?$'),
			(RegExpMatch m) {
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), 1);
				return DateTime.now().add(Duration(days: shift * 7));
			},
			NoteType.daily
		),

		// weekly: exact week
		DateParserMatcher(
			RegExp(r'^(?:w|wk|week)\s*?(\d+)$'),
			(RegExpMatch m) {
				final int week = int.parse(m.group(1) ?? '1', radix: 10);
				return DateUtils.firstWeekStart(DateTime.now().year, Config.week_starts_on).add(Duration(days: (week - 1) * 7));
			},
			NoteType.weekly
		),

		// weekly, optionally shifted
		DateParserMatcher(
			RegExp(r'^(?:w|wk|week)\s*?([-+]?)\s*?(\d*)$'),
			(RegExpMatch m) {
				final int defaultValue = _isSymbol(m.group(1)) ? 1 : 0;
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), defaultValue);
				return DateTime.now().add(Duration(days: shift * 7));
			},
			NoteType.weekly
		),

		// monthly, exact month
		DateParserMatcher(
			RegExp(r'^m\s*?(\d+)$'),
			(RegExpMatch m) {
				final int month = int.parse(m.group(1) ?? '1', radix: 10);
				return DateTime(DateTime.now().year, month, 1);
			},
			NoteType.monthly
		),

		// monthly, optionally shifted
		DateParserMatcher(
			RegExp(r'^m\s*?([-+]?)\s*?(\d*)$'),
			(RegExpMatch m) {
				final int defaultValue = _isSymbol(m.group(1)) ? 1 : 0;
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), defaultValue);
				return DateTime(DateTime.now().year, DateTime.now().month + shift, 1);
			},
			NoteType.monthly
		),

		// quarterly, exact quarter
		DateParserMatcher(
			RegExp(r'^q\s*?(\d+)$'),
			(RegExpMatch m) {
				final int quarter = int.parse(m.group(1) ?? '1', radix: 10);
				return DateTime(DateTime.now().year, quarter * 3, 1);
			},
			NoteType.quarterly
		),

		// quarterly, optionally shifted
		DateParserMatcher(
			RegExp(r'^q\s*?([-+]?)\s*?(\d*)$'),
			(RegExpMatch m) {
				final int defaultValue = _isSymbol(m.group(1)) ? 1 : 0;
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), defaultValue);
				return DateTime(DateTime.now().year, DateTime.now().month + (shift * 3), 1);
			},
			NoteType.quarterly
		),

		// yearly, exact year
		DateParserMatcher(
			RegExp(r'^(?:y|yr|year)\s*?(\d\d)$'),
			(RegExpMatch m) {
				final int year = 2000 + int.parse(m.group(1) ?? '1', radix: 10);
				return DateTime(year, 1, 1);
			},
			NoteType.yearly
		),

		// yearly, optionally shifted
		DateParserMatcher(
			RegExp(r'^(?:y|yr|year)\s*?([-+]?)\s*?(\d*)$'),
			(RegExpMatch m) {
				final int defaultValue = _isSymbol(m.group(1)) ? 1 : 0;
				final int shift = _fromSymbol(m.group(1)) * _maybeParse(m.group(2), defaultValue);
				return DateTime(DateTime.now().year + shift, 1, 1);
			},
			NoteType.yearly
		),
	];
}

class DateParserMatcher {
	final RegExp re;
	final Function(RegExpMatch) func;
	final NoteType t;

	DateParserMatcher(
		RegExp match,
		DateTime Function(RegExpMatch) processor,
		NoteType type
	):
		re = match,
		func = processor,
		t = type
	;

	bool matches(String input) => re.hasMatch(input);

	DateTime process(String input) => func(re.firstMatch(input)!);
}