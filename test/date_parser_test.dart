import 'package:alfred_noteplan_fts_refresh/date_parser.dart';
import 'package:alfred_noteplan_fts_refresh/date_utils.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

String date_to_daily(
	DateTime d, {String fmt = 'yMMdd'}
) => '${DateFormat(fmt, 'en_GB').format(d)}.md';

Tuple2<int, int> shift_month(Tuple2<int, int> year_month, {int change = 0}) {
	int year = year_month.item1;
	int month = year_month.item2;
	while (month > 12 || month < 1) {
		if (month > 12) { month -= 12; year += 1; }
		if (month < 1) { month += 12; year -= 1; }
	}
	return Tuple2(year, month);
}
Tuple2<int, int> shift_quarter(Tuple2<int, int> year_quarter, {int change = 0}) {
	int year = year_quarter.item1;
	int month = year_quarter.item2;
	while (month > 4 || month < 1) {
		if (month > 4) { month -= 4; year += 1; }
		if (month < 1) { month += 4; year -= 1; }
	}
	return Tuple2(year, month);
}

final DateTime _now = DateTime.now();

String dpfn(String query, {bool raw = false}) => DateParser(raw ? query : '> ${query}').to_filename();

void main() {
	initializeDateFormatting('en_GB', null);

	test('query start formats', () {
		expect(dpfn('>today', raw: true),  date_to_daily(_now));
		expect(dpfn('> today', raw: true), date_to_daily(_now));
		expect(dpfn(':today', raw: true),  date_to_daily(_now));
		expect(dpfn(': today', raw: true), date_to_daily(_now));
	});

	group('daily: words', () {
		test('today', () {
			expect(dpfn('t'),           date_to_daily(_now));
			expect(dpfn('tod'),         date_to_daily(_now));
			expect(dpfn('toda'),        date_to_daily(_now));
			expect(dpfn('today'),       date_to_daily(_now));
			expect(() => dpfn('to'),    throwsArgumentError);
		});
		test('tomorrow', () {
			expect(dpfn('tom'),         date_to_daily(_now.add(Duration(days: 1))));
			expect(dpfn('tomor'),       date_to_daily(_now.add(Duration(days: 1))));
			expect(dpfn('tomorr'),      date_to_daily(_now.add(Duration(days: 1))));
			expect(dpfn('tomorrow'),    date_to_daily(_now.add(Duration(days: 1))));
		});
		test('yesterday', () {
			expect(dpfn('yes'),         date_to_daily(_now.subtract(Duration(days: 1))));
			expect(dpfn('yest'),        date_to_daily(_now.subtract(Duration(days: 1))));
			expect(dpfn('yester'),      date_to_daily(_now.subtract(Duration(days: 1))));
			expect(dpfn('yesterday'),   date_to_daily(_now.subtract(Duration(days: 1))));
		});
	});

	group('daily: exact', () {
		test('Ymd', () {
			expect(dpfn('20221211'),    DateTime(2022, 12, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('20220711'),    DateTime(2022, 07, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('20230101'),    DateTime(2023, 01, 01).noteplan_filename(NoteType.daily));
			expect(dpfn('20200209'),    DateTime(2020, 02, 29).noteplan_filename(NoteType.daily));
			expect(() => dpfn('20230229'),    throwsArgumentError);
			expect(() => dpfn('20220229'),    throwsArgumentError);
			expect(() => dpfn('20230432'),    throwsArgumentError);
		});
		test('short Ymd', () {
			expect(dpfn('221211'),    DateTime(2022, 12, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('220611'),    DateTime(2022, 06, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('230101'),    DateTime(2023, 01, 01).noteplan_filename(NoteType.daily));
			expect(dpfn('200209'),    DateTime(2020, 02, 29).noteplan_filename(NoteType.daily));
			expect(() => dpfn('230229'),    throwsArgumentError);
			expect(() => dpfn('220229'),    throwsArgumentError);
			expect(() => dpfn('210432'),    throwsArgumentError);
		});
		test('month/day only', () {
			expect(dpfn('1211'),    DateTime(2023, 12, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('0411'),    DateTime(2023, 04, 11).noteplan_filename(NoteType.daily));
			expect(dpfn('0101'),    DateTime(2023, 01, 01).noteplan_filename(NoteType.daily));
			expect(() => dpfn('0229'),    throwsArgumentError);
			expect(() => dpfn('0432'),    throwsArgumentError);
		});
	});

	group('daily: movement', () {
		test('days', () {
			expect(dpfn('+2d'),      _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('+ 2d'),     _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('2d'),       _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('+2 d'),     _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('+ 2 d'),    _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('2 d'),      _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn(' 2 d'),     _now.add(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('+ 14 d'),   _now.add(Duration(days: 14)).noteplan_filename(NoteType.daily));
			expect(dpfn('+12 d'),    _now.add(Duration(days: 12)).noteplan_filename(NoteType.daily));
			expect(dpfn('-3d'),      _now.subtract(Duration(days: 3)).noteplan_filename(NoteType.daily));
			expect(dpfn('- 1d'),     _now.subtract(Duration(days: 1)).noteplan_filename(NoteType.daily));
			expect(dpfn('- 4 d'),    _now.subtract(Duration(days: 4)).noteplan_filename(NoteType.daily));
			expect(dpfn('-2 d'),     _now.subtract(Duration(days: 2)).noteplan_filename(NoteType.daily));
			expect(dpfn('- 10d'),    _now.subtract(Duration(days: 10)).noteplan_filename(NoteType.daily));
		});
		test('weeks', () {
			expect(dpfn('+2w'),      _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('+ 2w'),     _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('2w'),       _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('+2wk'),     _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('+ 2wk'),    _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('2wk'),      _now.add(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('-3w'),      _now.subtract(Duration(days: 3 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('- 1w'),     _now.subtract(Duration(days: 1 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('-4wk'),     _now.subtract(Duration(days: 4 * 7)).noteplan_filename(NoteType.daily));
			expect(dpfn('- 2wk'),    _now.subtract(Duration(days: 2 * 7)).noteplan_filename(NoteType.daily));
		});
	});

	group('other', () {
		test('week', () {
			expect(dpfn('w'),      	  _now.noteplan_filename(NoteType.weekly));
			expect(dpfn('wk'),        _now.noteplan_filename(NoteType.weekly));
			expect(dpfn('week'),      _now.noteplan_filename(NoteType.weekly));
			expect(dpfn('w +'),        _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('w +1'),       _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('w + 2'),      _now.noteplan_filename(NoteType.weekly, change: 2));
			expect(dpfn('w+ 23'),      _now.noteplan_filename(NoteType.weekly, change: 23));
			expect(dpfn('w-'),         _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('w -1'),       _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('w - 2'),      _now.noteplan_filename(NoteType.weekly, change: -2));
			expect(dpfn('w- 23'),      _now.noteplan_filename(NoteType.weekly, change: -23));
			expect(dpfn('wk +'),        _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('wk +1'),       _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('wk + 2'),      _now.noteplan_filename(NoteType.weekly, change: 2));
			expect(dpfn('wk+ 23'),      _now.noteplan_filename(NoteType.weekly, change: 23));
			expect(dpfn('wk-'),         _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('wk -1'),       _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('wk - 2'),      _now.noteplan_filename(NoteType.weekly, change: -2));
			expect(dpfn('wk- 23'),      _now.noteplan_filename(NoteType.weekly, change: -23));
			expect(dpfn('week +'),        _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('week +1'),       _now.noteplan_filename(NoteType.weekly, change: 1));
			expect(dpfn('week + 2'),      _now.noteplan_filename(NoteType.weekly, change: 2));
			expect(dpfn('week+ 23'),      _now.noteplan_filename(NoteType.weekly, change: 23));
			expect(dpfn('week-'),         _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('week -1'),       _now.noteplan_filename(NoteType.weekly, change: -1));
			expect(dpfn('week - 2'),      _now.noteplan_filename(NoteType.weekly, change: -2));
			expect(dpfn('week- 23'),      _now.noteplan_filename(NoteType.weekly, change: -23));
		});
		test('month', () {
			expect(dpfn('m'),          _now.noteplan_filename(NoteType.monthly));
			expect(dpfn('m +'),        _now.noteplan_filename(NoteType.monthly, change: 1));
			expect(dpfn('m +1'),       _now.noteplan_filename(NoteType.monthly, change: 1));
			expect(dpfn('m + 2'),      _now.noteplan_filename(NoteType.monthly, change: 2));
			expect(dpfn('m+ 23'),      _now.noteplan_filename(NoteType.monthly, change: 23));
			expect(dpfn('m-'),         _now.noteplan_filename(NoteType.monthly, change: -1));
			expect(dpfn('m -1'),       _now.noteplan_filename(NoteType.monthly, change: -1));
			expect(dpfn('m - 2'),      _now.noteplan_filename(NoteType.monthly, change: -2));
			expect(dpfn('m- 23'),      _now.noteplan_filename(NoteType.monthly, change: -23));
		});
		test('quarter', () {
			expect(dpfn('q'),           _now.noteplan_filename(NoteType.quarterly));
			expect(dpfn('q +'),         _now.noteplan_filename(NoteType.quarterly, change: 1));
			expect(dpfn('q +1'),        _now.noteplan_filename(NoteType.quarterly, change: 1));
			expect(dpfn('q + 2'),       _now.noteplan_filename(NoteType.quarterly, change: 2));
			expect(dpfn('q+ 23 '),      _now.noteplan_filename(NoteType.quarterly, change: 23));
			expect(dpfn('q -'),         _now.noteplan_filename(NoteType.quarterly, change: -1));
			expect(dpfn('q -1'),        _now.noteplan_filename(NoteType.quarterly, change: -1));
			expect(dpfn('q - 2'),       _now.noteplan_filename(NoteType.quarterly, change: -2));
			expect(dpfn('q- 23 '),      _now.noteplan_filename(NoteType.quarterly, change: -23));
		});
		test('year', () {
			expect(dpfn('yr'),         _now.noteplan_filename(NoteType.yearly));
			expect(dpfn('year'),       _now.noteplan_filename(NoteType.yearly));
			expect(dpfn('yr+'),        _now.noteplan_filename(NoteType.yearly, change: 1));
			expect(dpfn('yr +1'),      _now.noteplan_filename(NoteType.yearly, change: 1));
			expect(dpfn('yr + 2'),     _now.noteplan_filename(NoteType.yearly, change: 2));
			expect(dpfn('yr+ 23'),     _now.noteplan_filename(NoteType.yearly, change: 23));
			expect(dpfn('yr-'),        _now.noteplan_filename(NoteType.yearly, change: -1));
			expect(dpfn('yr -1'),      _now.noteplan_filename(NoteType.yearly, change: -1));
			expect(dpfn('yr - 2'),     _now.noteplan_filename(NoteType.yearly, change: -2));
			expect(dpfn('yr- 23'),     _now.noteplan_filename(NoteType.yearly, change: -23));
		});
	});

}