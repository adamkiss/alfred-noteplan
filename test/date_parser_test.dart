import 'package:alfred_noteplan_fts_refresh/date_parser.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

String date_to_daily(DateTime d, {String fmt = 'yMMdd'}) => '${DateFormat(fmt, 'en_GB').format(d)}.md';

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
}