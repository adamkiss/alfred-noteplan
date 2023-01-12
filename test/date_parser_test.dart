import 'package:alfred_noteplan_fts_refresh/date_parser.dart';
import 'package:alfred_noteplan_fts_refresh/date_utils.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

final DateTime _now = DateTime.now();

String dpfn(String query, {bool raw = false}) => DateParser(raw ? query : '> ${query}').toDateString();

void main() {
	initializeDateFormatting('en_GB', null);

	test('query start formats', () {
		expect(dpfn('>today',  raw: true), _now.toNoteplanDateString(NoteType.daily));
		expect(dpfn('> today', raw: true), _now.toNoteplanDateString(NoteType.daily));
		expect(dpfn(':today',  raw: true), _now.toNoteplanDateString(NoteType.daily));
		expect(dpfn(': today', raw: true), _now.toNoteplanDateString(NoteType.daily));
	});

	group('daily: words', () {
		test('today', () {
			expect(dpfn('t'),        _now.toNoteplanDateString(NoteType.daily));
			expect(dpfn('tod'),      _now.toNoteplanDateString(NoteType.daily));
			expect(dpfn('toda'),     _now.toNoteplanDateString(NoteType.daily));
			expect(dpfn('today'),    _now.toNoteplanDateString(NoteType.daily));
			expect(() => dpfn('to'), throwsArgumentError);
		});
		test('tomorrow', () {
			expect(dpfn('tom'),      _now.add(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('tomor'),    _now.add(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('tomorr'),   _now.add(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('tomorrow'), _now.add(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
		});
		test('yesterday', () {
			expect(dpfn('yes'),         _now.subtract(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('yest'),        _now.subtract(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('yester'),      _now.subtract(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('yesterday'),   _now.subtract(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
		});
	});

	group('daily: exact', () {
		test('Ymd', () {
			expect(dpfn('20221211'),    DateTime(2022, 12, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20220711'),    DateTime(2022, 07, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20230101'),    DateTime(2023, 01, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20200229'),    DateTime(2020, 02, 29).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20230229'),    DateTime(2023, 03, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20220229'),    DateTime(2022, 03, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('20230432'),    DateTime(2023, 05, 02).toNoteplanDateString(NoteType.daily));
		});
		test('short Ymd', () {
			expect(dpfn('221211'),    DateTime(2022, 12, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('220611'),    DateTime(2022, 06, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('230101'),    DateTime(2023, 01, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('200229'),    DateTime(2020, 02, 29).toNoteplanDateString(NoteType.daily));
			expect(dpfn('230229'),    DateTime(2023, 03, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('220229'),    DateTime(2022, 03, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('210432'),    DateTime(2021, 05, 02).toNoteplanDateString(NoteType.daily));
		});
		test('month/day only', () {
			expect(dpfn('1211'),    DateTime(2023, 12, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('0411'),    DateTime(2023, 04, 11).toNoteplanDateString(NoteType.daily));
			expect(dpfn('0101'),    DateTime(2023, 01, 01).toNoteplanDateString(NoteType.daily));
			expect(dpfn('0229'),    DateTime(DateTime.now().year, 02, 29).toNoteplanDateString(NoteType.daily));
			expect(dpfn('0432'),    DateTime(DateTime.now().year, 05, 02).toNoteplanDateString(NoteType.daily));
		});
	});

	group('daily: movement', () {
		test('days', () {
			expect(dpfn('+2d'),      _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+ 2d'),     _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('2d'),       _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+2 d'),     _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+ 2 d'),    _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('2 d'),      _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn(' 2 d'),     _now.add(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+ 14 d'),   _now.add(Duration(days: 14)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+12 d'),    _now.add(Duration(days: 12)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('-3d'),      _now.subtract(Duration(days: 3)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('- 1d'),     _now.subtract(Duration(days: 1)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('- 4 d'),    _now.subtract(Duration(days: 4)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('-2 d'),     _now.subtract(Duration(days: 2)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('- 10d'),    _now.subtract(Duration(days: 10)).toNoteplanDateString(NoteType.daily));
		});
		test('weeks', () {
			expect(dpfn('+2w'),      _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+ 2w'),     _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('2w'),       _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+2wk'),     _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('+ 2wk'),    _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('2wk'),      _now.add(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('-3w'),      _now.subtract(Duration(days: 3 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('- 1w'),     _now.subtract(Duration(days: 1 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('-4wk'),     _now.subtract(Duration(days: 4 * 7)).toNoteplanDateString(NoteType.daily));
			expect(dpfn('- 2wk'),    _now.subtract(Duration(days: 2 * 7)).toNoteplanDateString(NoteType.daily));
		});
	});

	DateTime dt;
	group('other', () {
		test('week', () {
			expect(dpfn('w'),        _now.toNoteplanDateString(NoteType.weekly), reason: 'w');
			expect(dpfn('wk'),       _now.toNoteplanDateString(NoteType.weekly), reason: 'wk');
			expect(dpfn('week'),     _now.toNoteplanDateString(NoteType.weekly), reason: 'week');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('w +'),      dt.toNoteplanDateString(NoteType.weekly), reason: 'w +');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('w +1'),     dt.toNoteplanDateString(NoteType.weekly), reason: 'w +1');
			dt = _now.add(Duration(days: 2 * 7));
			expect(dpfn('w + 2'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'w + 2');
			dt = _now.add(Duration(days: 23 * 7));
			expect(dpfn('w+ 23'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'w+ 23');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('w-'),       dt.toNoteplanDateString(NoteType.weekly), reason: 'w-');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('w -1'),     dt.toNoteplanDateString(NoteType.weekly), reason: 'w -1');
			dt = _now.add(Duration(days: -2 * 7));
			expect(dpfn('w - 2'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'w - 2');
			dt = _now.add(Duration(days: -23 * 7));
			expect(dpfn('w- 23'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'w- 23');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('wk +'),     dt.toNoteplanDateString(NoteType.weekly), reason: 'wk +');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('wk +1'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'wk +1');
			dt = _now.add(Duration(days: 2 * 7));
			expect(dpfn('wk + 2'),   dt.toNoteplanDateString(NoteType.weekly), reason: 'wk + 2');
			dt = _now.add(Duration(days: 23 * 7));
			expect(dpfn('wk+ 23'),   dt.toNoteplanDateString(NoteType.weekly), reason: 'wk+ 23');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('wk-'),      dt.toNoteplanDateString(NoteType.weekly), reason: 'wk-');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('wk -1'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'wk -1');
			dt = _now.add(Duration(days: -2 * 7));
			expect(dpfn('wk - 2'),   dt.toNoteplanDateString(NoteType.weekly), reason: 'wk - 2');
			dt = _now.add(Duration(days: -23 * 7));
			expect(dpfn('wk- 23'),   dt.toNoteplanDateString(NoteType.weekly), reason: 'wk- 23');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('week +'),   dt.toNoteplanDateString(NoteType.weekly), reason: 'week +');
			dt = _now.add(Duration(days: 1 * 7));
			expect(dpfn('week +1'),  dt.toNoteplanDateString(NoteType.weekly), reason: 'week +1');
			dt = _now.add(Duration(days: 2 * 7));
			expect(dpfn('week + 2'), dt.toNoteplanDateString(NoteType.weekly), reason: 'week + 2');
			dt = _now.add(Duration(days: 23 * 7));
			expect(dpfn('week+ 23'), dt.toNoteplanDateString(NoteType.weekly), reason: 'week+ 23');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('week-'),    dt.toNoteplanDateString(NoteType.weekly), reason: 'week-');
			dt = _now.add(Duration(days: -1 * 7));
			expect(dpfn('week -1'),  dt.toNoteplanDateString(NoteType.weekly), reason: 'week -1');
			dt = _now.add(Duration(days: -2 * 7));
			expect(dpfn('week - 2'), dt.toNoteplanDateString(NoteType.weekly), reason: 'week - 2');
			dt = _now.add(Duration(days: -23 * 7));
			expect(dpfn('week- 23'), dt.toNoteplanDateString(NoteType.weekly), reason: 'week- 23');
		});
		test('month', () {
			expect(dpfn('m'),          _now.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  1, _now.day);
			expect(dpfn('m +'),        dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  1, _now.day);
			expect(dpfn('m +1'),       dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  2, _now.day);
			expect(dpfn('m + 2'),      dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  23, _now.day);
			expect(dpfn('m+ 23'),      dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  -1, _now.day);
			expect(dpfn('m-'),         dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  -1, _now.day);
			expect(dpfn('m -1'),       dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  -2, _now.day);
			expect(dpfn('m - 2'),      dt.toNoteplanDateString(NoteType.monthly));
			dt = DateTime(_now.year, _now.month +  -23, _now.day);
			expect(dpfn('m- 23'),      dt.toNoteplanDateString(NoteType.monthly));
		});
		test('quarter', () {
			expect(dpfn('q'),           _now.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*1, _now.day);
			expect(dpfn('q +'),         dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*1, _now.day);
			expect(dpfn('q +1'),        dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*2, _now.day);
			expect(dpfn('q + 2'),       dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*23, _now.day);
			expect(dpfn('q+ 23 '),      dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*-1, _now.day);
			expect(dpfn('q -'),         dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*-1, _now.day);
			expect(dpfn('q -1'),        dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*-2, _now.day);
			expect(dpfn('q - 2'),       dt.toNoteplanDateString(NoteType.quarterly));
			dt = DateTime(_now.year, _now.month + 3*-23, _now.day);
			expect(dpfn('q- 23 '),      dt.toNoteplanDateString(NoteType.quarterly));
		});
		test('year', () {
			expect(dpfn('yr'),         _now.toNoteplanDateString(NoteType.yearly));
			expect(dpfn('year'),       _now.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  1, _now.month, _now.day);
			expect(dpfn('yr+'),        dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  1, _now.month, _now.day);
			expect(dpfn('yr +1'),      dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  2, _now.month, _now.day);
			expect(dpfn('yr + 2'),     dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  23, _now.month, _now.day);
			expect(dpfn('yr+ 23'),     dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  -1, _now.month, _now.day);
			expect(dpfn('yr-'),        dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  -1, _now.month, _now.day);
			expect(dpfn('yr -1'),      dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  -2, _now.month, _now.day);
			expect(dpfn('yr - 2'),     dt.toNoteplanDateString(NoteType.yearly));
			dt = DateTime(_now.year +  -23, _now.month, _now.day);
			expect(dpfn('yr- 23'),     dt.toNoteplanDateString(NoteType.yearly));
		});
	});

}