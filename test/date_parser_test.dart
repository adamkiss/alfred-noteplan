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
		expect(dpfn('>today',  raw: true), _now.toNoteplanFilename(NoteType.daily));
		expect(dpfn('> today', raw: true), _now.toNoteplanFilename(NoteType.daily));
		expect(dpfn(':today',  raw: true), _now.toNoteplanFilename(NoteType.daily));
		expect(dpfn(': today', raw: true), _now.toNoteplanFilename(NoteType.daily));
	});

	group('daily: words', () {
		test('today', () {
			expect(dpfn('t'),        _now.toNoteplanFilename(NoteType.daily));
			expect(dpfn('tod'),      _now.toNoteplanFilename(NoteType.daily));
			expect(dpfn('toda'),     _now.toNoteplanFilename(NoteType.daily));
			expect(dpfn('today'),    _now.toNoteplanFilename(NoteType.daily));
			expect(() => dpfn('to'), throwsArgumentError);
		});
		test('tomorrow', () {
			expect(dpfn('tom'),      _now.add(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('tomor'),    _now.add(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('tomorr'),   _now.add(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('tomorrow'), _now.add(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
		});
		test('yesterday', () {
			expect(dpfn('yes'),         _now.subtract(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('yest'),        _now.subtract(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('yester'),      _now.subtract(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('yesterday'),   _now.subtract(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
		});
	});

	group('daily: exact', () {
		test('Ymd', () {
			expect(dpfn('20221211'),    DateTime(2022, 12, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('20220711'),    DateTime(2022, 07, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('20230101'),    DateTime(2023, 01, 01).toNoteplanFilename(NoteType.daily));
			expect(dpfn('20200209'),    DateTime(2020, 02, 29).toNoteplanFilename(NoteType.daily));
			expect(() => dpfn('20230229'),    throwsArgumentError);
			expect(() => dpfn('20220229'),    throwsArgumentError);
			expect(() => dpfn('20230432'),    throwsArgumentError);
		});
		test('short Ymd', () {
			expect(dpfn('221211'),    DateTime(2022, 12, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('220611'),    DateTime(2022, 06, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('230101'),    DateTime(2023, 01, 01).toNoteplanFilename(NoteType.daily));
			expect(dpfn('200209'),    DateTime(2020, 02, 29).toNoteplanFilename(NoteType.daily));
			expect(() => dpfn('230229'),    throwsArgumentError);
			expect(() => dpfn('220229'),    throwsArgumentError);
			expect(() => dpfn('210432'),    throwsArgumentError);
		});
		test('month/day only', () {
			expect(dpfn('1211'),    DateTime(2023, 12, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('0411'),    DateTime(2023, 04, 11).toNoteplanFilename(NoteType.daily));
			expect(dpfn('0101'),    DateTime(2023, 01, 01).toNoteplanFilename(NoteType.daily));
			expect(() => dpfn('0229'),    throwsArgumentError);
			expect(() => dpfn('0432'),    throwsArgumentError);
		});
	});

	group('daily: movement', () {
		test('days', () {
			expect(dpfn('+2d'),      _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+ 2d'),     _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('2d'),       _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+2 d'),     _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+ 2 d'),    _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('2 d'),      _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn(' 2 d'),     _now.add(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+ 14 d'),   _now.add(Duration(days: 14)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+12 d'),    _now.add(Duration(days: 12)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('-3d'),      _now.subtract(Duration(days: 3)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('- 1d'),     _now.subtract(Duration(days: 1)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('- 4 d'),    _now.subtract(Duration(days: 4)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('-2 d'),     _now.subtract(Duration(days: 2)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('- 10d'),    _now.subtract(Duration(days: 10)).toNoteplanFilename(NoteType.daily));
		});
		test('weeks', () {
			expect(dpfn('+2w'),      _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+ 2w'),     _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('2w'),       _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+2wk'),     _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('+ 2wk'),    _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('2wk'),      _now.add(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('-3w'),      _now.subtract(Duration(days: 3 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('- 1w'),     _now.subtract(Duration(days: 1 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('-4wk'),     _now.subtract(Duration(days: 4 * 7)).toNoteplanFilename(NoteType.daily));
			expect(dpfn('- 2wk'),    _now.subtract(Duration(days: 2 * 7)).toNoteplanFilename(NoteType.daily));
		});
	});

	group('other', () {
		test('week', () {
			expect(dpfn('w'),      	  _now.toNoteplanFilename(NoteType.weekly));
			expect(dpfn('wk'),        _now.toNoteplanFilename(NoteType.weekly));
			expect(dpfn('week'),      _now.toNoteplanFilename(NoteType.weekly));
			expect(dpfn('w +'),        _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('w +1'),       _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('w + 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: 2));
			expect(dpfn('w+ 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: 23));
			expect(dpfn('w-'),         _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('w -1'),       _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('w - 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: -2));
			expect(dpfn('w- 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: -23));
			expect(dpfn('wk +'),        _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('wk +1'),       _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('wk + 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: 2));
			expect(dpfn('wk+ 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: 23));
			expect(dpfn('wk-'),         _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('wk -1'),       _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('wk - 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: -2));
			expect(dpfn('wk- 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: -23));
			expect(dpfn('week +'),        _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('week +1'),       _now.toNoteplanFilename(NoteType.weekly, shift: 1));
			expect(dpfn('week + 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: 2));
			expect(dpfn('week+ 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: 23));
			expect(dpfn('week-'),         _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('week -1'),       _now.toNoteplanFilename(NoteType.weekly, shift: -1));
			expect(dpfn('week - 2'),      _now.toNoteplanFilename(NoteType.weekly, shift: -2));
			expect(dpfn('week- 23'),      _now.toNoteplanFilename(NoteType.weekly, shift: -23));
		});
		test('month', () {
			expect(dpfn('m'),          _now.toNoteplanFilename(NoteType.monthly));
			expect(dpfn('m +'),        _now.toNoteplanFilename(NoteType.monthly, shift: 1));
			expect(dpfn('m +1'),       _now.toNoteplanFilename(NoteType.monthly, shift: 1));
			expect(dpfn('m + 2'),      _now.toNoteplanFilename(NoteType.monthly, shift: 2));
			expect(dpfn('m+ 23'),      _now.toNoteplanFilename(NoteType.monthly, shift: 23));
			expect(dpfn('m-'),         _now.toNoteplanFilename(NoteType.monthly, shift: -1));
			expect(dpfn('m -1'),       _now.toNoteplanFilename(NoteType.monthly, shift: -1));
			expect(dpfn('m - 2'),      _now.toNoteplanFilename(NoteType.monthly, shift: -2));
			expect(dpfn('m- 23'),      _now.toNoteplanFilename(NoteType.monthly, shift: -23));
		});
		test('quarter', () {
			expect(dpfn('q'),           _now.toNoteplanFilename(NoteType.quarterly));
			expect(dpfn('q +'),         _now.toNoteplanFilename(NoteType.quarterly, shift: 1));
			expect(dpfn('q +1'),        _now.toNoteplanFilename(NoteType.quarterly, shift: 1));
			expect(dpfn('q + 2'),       _now.toNoteplanFilename(NoteType.quarterly, shift: 2));
			expect(dpfn('q+ 23 '),      _now.toNoteplanFilename(NoteType.quarterly, shift: 23));
			expect(dpfn('q -'),         _now.toNoteplanFilename(NoteType.quarterly, shift: -1));
			expect(dpfn('q -1'),        _now.toNoteplanFilename(NoteType.quarterly, shift: -1));
			expect(dpfn('q - 2'),       _now.toNoteplanFilename(NoteType.quarterly, shift: -2));
			expect(dpfn('q- 23 '),      _now.toNoteplanFilename(NoteType.quarterly, shift: -23));
		});
		test('year', () {
			expect(dpfn('yr'),         _now.toNoteplanFilename(NoteType.yearly));
			expect(dpfn('year'),       _now.toNoteplanFilename(NoteType.yearly));
			expect(dpfn('yr+'),        _now.toNoteplanFilename(NoteType.yearly, shift: 1));
			expect(dpfn('yr +1'),      _now.toNoteplanFilename(NoteType.yearly, shift: 1));
			expect(dpfn('yr + 2'),     _now.toNoteplanFilename(NoteType.yearly, shift: 2));
			expect(dpfn('yr+ 23'),     _now.toNoteplanFilename(NoteType.yearly, shift: 23));
			expect(dpfn('yr-'),        _now.toNoteplanFilename(NoteType.yearly, shift: -1));
			expect(dpfn('yr -1'),      _now.toNoteplanFilename(NoteType.yearly, shift: -1));
			expect(dpfn('yr - 2'),     _now.toNoteplanFilename(NoteType.yearly, shift: -2));
			expect(dpfn('yr- 23'),     _now.toNoteplanFilename(NoteType.yearly, shift: -23));
		});
	});

}