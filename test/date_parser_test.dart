import 'package:alfred_noteplan_fts_refresh/date_parser.dart';
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

String to_weekly ({int change = 0}) {
	// final DateTime dt = _now.copyWith(day: 1);
	// @todo Dart doesn't understand weeks of year
	// add code, e.g.: https://stackoverflow.com/a/51122613/240239
	return '';
}
String to_monthly ({int change = 0}) {
	final DateTime dt = _now.copyWith(day: 1);
	final d = shift_month(Tuple2(dt.year, dt.month), change: change);
	return '${d.item1}-${d.item2}.md';
}
String to_quarterly ({int change = 0}) {
	final DateTime dt = _now.copyWith(day: 1);
	final d = shift_quarter(Tuple2(dt.year, (dt.month / 4).ceil()), change: change);
	return '${d.item1}-${d.item2}.md';
}
String to_yearly ({int change = 0}) {
	final DateTime dt = _now.copyWith(day: 1);
	int year = dt.year + change;
	return '${year}.md';
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
			expect(dpfn('20221211'),    date_to_daily(DateTime(2022, 12, 11)));
			expect(dpfn('20220711'),    date_to_daily(DateTime(2022, 07, 11)));
			expect(dpfn('20230101'),    date_to_daily(DateTime(2023, 01, 01)));
			expect(dpfn('20200209'),    date_to_daily(DateTime(2020, 02, 29)));
			expect(() => dpfn('20230229'),    throwsArgumentError);
			expect(() => dpfn('20220229'),    throwsArgumentError);
			expect(() => dpfn('20230432'),    throwsArgumentError);
		});
		test('short Ymd', () {
			expect(dpfn('221211'),    date_to_daily(DateTime(2022, 12, 11)));
			expect(dpfn('220611'),    date_to_daily(DateTime(2022, 06, 11)));
			expect(dpfn('230101'),    date_to_daily(DateTime(2023, 01, 01)));
			expect(dpfn('200209'),    date_to_daily(DateTime(2020, 02, 29)));
			expect(() => dpfn('230229'),    throwsArgumentError);
			expect(() => dpfn('220229'),    throwsArgumentError);
			expect(() => dpfn('210432'),    throwsArgumentError);
		});
		test('month/day only', () {
			expect(dpfn('1211'),    date_to_daily(DateTime(2023, 12, 11)));
			expect(dpfn('0411'),    date_to_daily(DateTime(2023, 04, 11)));
			expect(dpfn('0101'),    date_to_daily(DateTime(2023, 01, 01)));
			expect(() => dpfn('0229'),    throwsArgumentError);
			expect(() => dpfn('0432'),    throwsArgumentError);
		});
	});

	group('daily: movement', () {
		test('days', () {
			expect(dpfn('+2d'),      date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('+ 2d'),     date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('2d'),       date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('+2 d'),     date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('+ 2 d'),    date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('2 d'),      date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn(' 2 d'),     date_to_daily(_now.add(Duration(days: 2))));
			expect(dpfn('+ 14 d'),   date_to_daily(_now.add(Duration(days: 14))));
			expect(dpfn('+12 d'),    date_to_daily(_now.add(Duration(days: 12))));
			expect(dpfn('-3d'),      date_to_daily(_now.subtract(Duration(days: 3))));
			expect(dpfn('- 1d'),     date_to_daily(_now.subtract(Duration(days: 1))));
			expect(dpfn('- 4 d'),    date_to_daily(_now.subtract(Duration(days: 4))));
			expect(dpfn('-2 d'),     date_to_daily(_now.subtract(Duration(days: 2))));
			expect(dpfn('- 10d'),    date_to_daily(_now.subtract(Duration(days: 10))));
		});
		test('weeks', () {
			expect(dpfn('+2w'),      date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('+ 2w'),     date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('2w'),       date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('+2wk'),     date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('+ 2wk'),    date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('2wk'),      date_to_daily(_now.add(Duration(days: 2 * 7))));
			expect(dpfn('-3w'),      date_to_daily(_now.subtract(Duration(days: 3 * 7))));
			expect(dpfn('- 1w'),     date_to_daily(_now.subtract(Duration(days: 1 * 7))));
			expect(dpfn('-4wk'),     date_to_daily(_now.subtract(Duration(days: 4 * 7))));
			expect(dpfn('- 2wk'),    date_to_daily(_now.subtract(Duration(days: 2 * 7))));
		});
	});

	group('other', () {
		// test('week', () {
		// 	expect(dpfn('w'),      to_weekly());
		// 	expect(dpfn('wk'),      to_weekly());
		// 	expect(dpfn('week'),      to_weekly());
		// });
		test('month', () {
			expect(dpfn('m'),      to_monthly());
			expect(dpfn('m +'),      to_monthly(change: 1));
			expect(dpfn('m +1'),      to_monthly(change: 1));
			expect(dpfn('m + 2'),      to_monthly(change: 2));
			expect(dpfn('m+ 23'),      to_monthly(change: 23));
			expect(dpfn('m-'),      to_monthly(change: -1));
			expect(dpfn('m -1'),      to_monthly(change: -1));
			expect(dpfn('m - 2'),      to_monthly(change: -2));
			expect(dpfn('m- 23'),      to_monthly(change: -23));
		});
		test('quarter', () {
			expect(dpfn('q'),      to_quarterly());
			expect(dpfn('q +'),      to_quarterly(change: 1));
			expect(dpfn('q +1'),      to_quarterly(change: 1));
			expect(dpfn('q + 2'),      to_quarterly(change: 2));
			expect(dpfn('q+ 23 '),      to_quarterly(change: 23));
			expect(dpfn('q -'),      to_quarterly(change: -1));
			expect(dpfn('q -1'),      to_quarterly(change: -1));
			expect(dpfn('q - 2'),      to_quarterly(change: -2));
			expect(dpfn('q- 23 '),      to_quarterly(change: -23));
		});
		test('year', () {
			expect(dpfn('yr'),      to_yearly());
			expect(dpfn('year'),     to_yearly());
			expect(dpfn('yr+'),     to_yearly(change: 1));
			expect(dpfn('yr +1'),     to_yearly(change: 1));
			expect(dpfn('yr + 2'),     to_yearly(change: 2));
			expect(dpfn('yr+ 23'),     to_yearly(change: 23));
			expect(dpfn('yr-'),     to_yearly(change: -1));
			expect(dpfn('yr -1'),     to_yearly(change: -1));
			expect(dpfn('yr - 2'),     to_yearly(change: -2));
			expect(dpfn('yr- 23'),     to_yearly(change: -23));
		});
	});

}