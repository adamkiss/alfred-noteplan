import 'package:alfred_noteplan_fts_refresh/date_utils.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';


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

	group('Tuple date movement', () {
		test('Fails for weekly', () {
			Tuple3<NoteType, int, int> t = Tuple3(NoteType.weekly, 2023, 1);
			expect(() => t.shift(10), throwsStateError);
			expect(() => t.shift(-10), throwsStateError);
			expect(() => t.shift(0), throwsStateError);
		});
		test('Monthly', () {
			Tuple3<NoteType, int, int> t = Tuple3(NoteType.monthly, 2023, 1);
			expect(t.shift(5).item3, 6);

			expect(t.shift(12).item3, 1);
			expect(t.shift(12).item2, 2024);

			expect(t.shift(-2).item3, 11);
			expect(t.shift(-2).item2, 2022);

			expect(t.shift(-23).item3, 2);
			expect(t.shift(-23).item2, 2021);
		});

		test('Quarterly', () {
			Tuple3<NoteType, int, int> t = Tuple3(NoteType.quarterly, 2023, 1);
			expect(t.shift(5).item3, 2);

			expect(t.shift(12).item3, 1);
			expect(t.shift(12).item2, 2026);

			expect(t.shift(-2).item3, 3);
			expect(t.shift(-2).item2, 2022);

			expect(t.shift(-23).item3, 2);
			expect(t.shift(-23).item2, 2017);
		});

		test('Yearly', () {
			Tuple3<NoteType, int, int> t = Tuple3(NoteType.yearly, 2023, 1);
			expect(t.shift(5).item2, 2028);

			expect(t.shift(12).item3, 1);
			expect(t.shift(12).item2, 2035);

			expect(t.shift(-2).item3, 1);
			expect(t.shift(-2).item2, 2021);

			expect(t.shift(-23).item3, 1);
			expect(t.shift(-23).item2, 2000);
		});
	});

	group('Noteplan naming + movement >', () {
		DateTime now = DateTime(2023, 1, 11);

		test('Fails correctly', () {
			expect(() => Tuple3(NoteType.note, 2023, 1).toNoteplanDateString(), throwsArgumentError);
			expect(() => Tuple3(NoteType.daily, 2023, 1).toNoteplanDateString(), throwsArgumentError);
			expect(() => now.toNoteplanDateString(NoteType.note), throwsArgumentError);
		});

		DateTime dt;
		test('Daily', () {
			expect(now.toNoteplanDateString(NoteType.daily),              '20230111');
			dt = now.subtract(Duration(days: 20));
			expect(dt.toNoteplanDateString(NoteType.daily), '20221222');
			expect(dt.toNoteplanDateString(NoteType.daily, shift: -200), '20220625');
			expect(dt.toNoteplanDateString(NoteType.daily, shift:   20), '20230131');
			expect(dt.toNoteplanDateString(NoteType.daily, shift:   21), '20230201');
			expect(dt.toNoteplanDateString(NoteType.daily, shift:  200), '20230730');
		});
		test('Weekly (Monday)', () {
			expect(now.toNoteplanDateString(NoteType.weekly),             '2023-W02');
			expect(dt.toNoteplanDateString(NoteType.weekly, shift: -20), '2022-W34');
			expect(dt.toNoteplanDateString(NoteType.weekly, shift: -47), '2022-W07');
			expect(dt.toNoteplanDateString(NoteType.weekly, shift:  20), '2023-W22');
			expect(dt.toNoteplanDateString(NoteType.weekly, shift:  21), '2023-W23');
			expect(dt.toNoteplanDateString(NoteType.weekly, shift:  67), '2024-W17');
		});
		test('Weekly (Sunday)', () {
			expect(now.toNoteplanDateString(NoteType.weekly),             '2023-W02');
			expect(now.toNoteplanDateString(NoteType.weekly, shift: -20), '2022-W34');
			expect(now.toNoteplanDateString(NoteType.weekly, shift: -47), '2022-W07');
			expect(now.toNoteplanDateString(NoteType.weekly, shift:  20), '2023-W22');
			expect(now.toNoteplanDateString(NoteType.weekly, shift:  21), '2023-W23');
			expect(now.toNoteplanDateString(NoteType.weekly, shift:  67), '2024-W17');
		});
		test('Monthly', () {
			expect(now.toNoteplanDateString(NoteType.monthly),              '2023-01');
			expect(now.toNoteplanDateString(NoteType.monthly, shift:  -20), '2021-05');
			expect(now.toNoteplanDateString(NoteType.monthly, shift: -200), '2006-05');
			expect(now.toNoteplanDateString(NoteType.monthly, shift:   20), '2024-09');
			expect(now.toNoteplanDateString(NoteType.monthly, shift:   21), '2024-10');
			expect(now.toNoteplanDateString(NoteType.monthly, shift:  200), '2039-09');
		});
		test('Quarterly', () {

			expect(now.toNoteplanDateString(NoteType.quarterly),             '2023-Q1');
			expect(now.toNoteplanDateString(NoteType.quarterly, shift:   2), '2023-Q3');
			expect(now.toNoteplanDateString(NoteType.quarterly, shift:  -2), '2022-Q3');
			expect(now.toNoteplanDateString(NoteType.quarterly, shift:  20), '2028-Q1');
			expect(now.toNoteplanDateString(NoteType.quarterly, shift: -20), '2018-Q1');
		});
		test('Yearly', () {
			expect(now.toNoteplanDateString(NoteType.yearly),                 '2023');
			expect(now.toNoteplanDateString(NoteType.yearly, shift:  2),    '2025');
			expect(now.toNoteplanDateString(NoteType.yearly, shift: -2),    '2021');
			expect(now.toNoteplanDateString(NoteType.yearly, shift: -2020), '0003');
		});
	});
}