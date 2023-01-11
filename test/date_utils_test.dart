import 'package:alfred_noteplan_fts_refresh/date_utils.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';


void main() {
	test('Week of the year: Adjusting from ISO 8601 to Noteplan', () {
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.monday),    52, reason: '2023 - wk starts on: monday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.tuesday),   52, reason: '2023 - wk starts on: tuesday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.wednesday), 53, reason: '2023 - wk starts on: wednesday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.thursday),  1,  reason: '2023 - wk starts on: thursday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.friday),    1,  reason: '2023 - wk starts on: friday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.saturday),  1,  reason: '2023 - wk starts on: saturday');
		expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.sunday),    1,  reason: '2023 - wk starts on: sunday');

		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.monday),    1,  reason: '2015 - wk starts on: monday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.tuesday),   1,  reason: '2015 - wk starts on: tuesday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.wednesday), 1,  reason: '2015 - wk starts on: wednesday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.thursday),  1,  reason: '2015 - wk starts on: thursday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.friday),    52, reason: '2015 - wk starts on: friday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.saturday),  52, reason: '2015 - wk starts on: saturday');
		expect(DateTime(2015, 1, 1).adjustedWeekOfYear(DateTime.sunday),    53, reason: '2015 - wk starts on: sunday');
	});

	group('Date Utils', () {
		test('Day of the year', () {
			expect(DateTime(2023, 1, 1).dayOfYear,   1);
			expect(DateTime(2023, 4, 1).dayOfYear,   91);
			expect(DateTime(2023, 7, 1).dayOfYear,   182);
			expect(DateTime(2023, 10, 1).dayOfYear,  274);
			expect(DateTime(2023, 1, 31).dayOfYear,  31);
			expect(DateTime(2023, 4, 30).dayOfYear,  120);
			expect(DateTime(2023, 7, 31).dayOfYear,  212);
			expect(DateTime(2023, 10, 31).dayOfYear, 304);
			expect(DateTime(2023, 2, 29).dayOfYear,  60); // 1.3.
		});
		test('Week of the year: ISO 8601', () {
			expect(DateTime(2023, 1, 1).weekOfYear,   52);
			expect(DateTime(2023, 4, 1).weekOfYear,   13);
			expect(DateTime(2023, 7, 1).weekOfYear,   26);
			expect(DateTime(2023, 10, 1).weekOfYear,  39);
			expect(DateTime(2023, 1, 31).weekOfYear,   5);
			expect(DateTime(2023, 4, 30).weekOfYear,  17);
			expect(DateTime(2023, 7, 31).weekOfYear,  31);
			expect(DateTime(2023, 10, 31).weekOfYear, 44);
			expect(DateTime(2023, 2, 29).weekOfYear,   9); // 1.3.
		});
		test('Week of the year: Week starts with Sunday', () {
			expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.sunday),    1);
			expect(DateTime(2023, 4, 1).adjustedWeekOfYear(DateTime.sunday),   13);
			expect(DateTime(2023, 7, 1).adjustedWeekOfYear(DateTime.sunday),   26);
			expect(DateTime(2023, 10, 1).adjustedWeekOfYear(DateTime.sunday),  40);
			expect(DateTime(2023, 1, 31).adjustedWeekOfYear(DateTime.sunday),   5);
			expect(DateTime(2023, 4, 30).adjustedWeekOfYear(DateTime.sunday),  18);
			expect(DateTime(2023, 7, 31).adjustedWeekOfYear(DateTime.sunday),  31);
			expect(DateTime(2023, 10, 31).adjustedWeekOfYear(DateTime.sunday), 44);
			expect(DateTime(2023, 2, 29).adjustedWeekOfYear(DateTime.sunday),   9); // 1.3.
		});
		test('Week of the year: Week starts with Wednesday', () { //checked with noteplan
			expect(DateTime(2023, 1, 1).adjustedWeekOfYear(DateTime.wednesday),   53);
			expect(DateTime(2023, 4, 1).adjustedWeekOfYear(DateTime.wednesday),   13);
			expect(DateTime(2023, 7, 1).adjustedWeekOfYear(DateTime.wednesday),   26);
			expect(DateTime(2023, 10, 1).adjustedWeekOfYear(DateTime.wednesday),  39);
			expect(DateTime(2023, 1, 31).adjustedWeekOfYear(DateTime.wednesday),   4);
			expect(DateTime(2023, 4, 30).adjustedWeekOfYear(DateTime.wednesday),  17);
			expect(DateTime(2023, 7, 31).adjustedWeekOfYear(DateTime.wednesday),  30);
			expect(DateTime(2023, 10, 31).adjustedWeekOfYear(DateTime.wednesday), 43);
			expect(DateTime(2023, 2, 29).adjustedWeekOfYear(DateTime.wednesday),   9); // 1.3.
		});
		test('Quarter', () {
			expect(DateTime(2023, 1, 1).quarter,   1);
			expect(DateTime(2023, 4, 1).quarter,   2);
			expect(DateTime(2023, 7, 1).quarter,   3);
			expect(DateTime(2023, 10, 1).quarter,  4);
			expect(DateTime(2023, 1, 31).quarter,  1);
			expect(DateTime(2023, 4, 30).quarter,  2);
			expect(DateTime(2023, 7, 31).quarter,  3);
			expect(DateTime(2023, 10, 31).quarter, 4);
			expect(DateTime(2023, 2, 29).quarter,  1); //1.3
			expect(DateTime(2023, 3, 38).quarter,  2); //7.4
		});
	});

}