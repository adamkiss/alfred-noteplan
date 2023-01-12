
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:alfred_noteplan_fts_refresh/int_padding.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

extension DateUtils on DateTime {
	int get quarter => int.parse(DateFormat('Q').format(this), radix: 10);
	int get dayOfYear => int.parse(DateFormat('D').format(this), radix: 10);

	/// Shift actual weekday to fake weekday based on "week starts on"
	///
	/// ```
	/// Example: Week starts on sunday
	/// shifter: WEEK_START - MONDAY (so monday has no change)
	/// shifted = weekday - shifter
	/// ensure positive by (shifted + 7) % 7       => 1 2 3 4 5 6 0 repeated
	/// decrease before modulo by 1 to shift range => 0 1 2 3 4 5 6 repeated
	/// increase after to correspond with weekday r=> 1 2 3 4 5 6 7 repeated
	/// ```
	int _weekdayShift ([int weekStartsOn = DateTime.monday]) {
		int shiftWeek = weekStartsOn - 1; // how much we shift week against ISO 8601
		return ((weekday - shiftWeek + (7-1)) % 7) + 1;
	}
	int _weekOfYearBase([int weekStartsOn = DateTime.monday]) => (
		(dayOfYear - _weekdayShift(weekStartsOn) + 10)
	/ 7).floor();
	int _calculateWeekOfYear([int weekStartsOn = DateTime.monday]) {
		int woy = _weekOfYearBase(weekStartsOn);
		if (woy < 1) { return DateUtils.numberOfWeeks(year - 1, weekStartsOn); }
		if (woy > DateUtils.numberOfWeeks(year, weekStartsOn)) { return 1; }
		return woy;
	}

	static int numberOfWeeks(
		int year,
		[int weekStartsOn = DateTime.monday]
	) => DateTime(year, 12, 28)._weekOfYearBase(weekStartsOn);

	int get yearWeeks => DateUtils.numberOfWeeks(year);
	int adjustedYearWeeks(int weekStartsOn) => DateUtils.numberOfWeeks(year, weekStartsOn);

	int get weekOfYear => _calculateWeekOfYear();
	int adjustedWeekOfYear(int weekStartsOn) => _calculateWeekOfYear(weekStartsOn);

	/// Convert [DateTime] to [Tuple3<type, year, ??>] based on [NoteType]
	Tuple3<NoteType, int, int> toTuple3(NoteType type, {int weekStartsWith = DateTime.monday}) {
		if (! NoteType.convertableToTuple3.contains(type)) {
			throw ArgumentError('DateTime.toTuple3: can\'t convert ${type} to Tuple3');
		}

		switch (type) {
			case NoteType.weekly: return Tuple3(type, year, adjustedWeekOfYear(weekStartsWith));
			case NoteType.monthly: return Tuple3(type, year, month);
			case NoteType.quarterly: return Tuple3(type, year, quarter);
			default: return Tuple3(type, year, 1);
		}
	}

	/// Get a Noteplan note name ([String]) from a [DateTime] and options shift by [int]
	String toNoteplanDateString (NoteType type, {int shift = 0}) {
		if (type == NoteType.note) {
			throw ArgumentError('DateTime.toNoteplanDateString: can\'t convert ${type} to filename.');
		}

		switch (type) {
			case NoteType.daily:
				DateTime actual = add(Duration(days: shift));
				return [
					actual.year.padLeft(4),
					actual.month.padLeft(2),
					actual.day.padLeft(2)
				].join();
			case NoteType.weekly:
				DateTime actual = add(Duration(days: shift * 7));
				int week = actual.adjustedWeekOfYear(Config.week_starts_on);
				int year = actual.year;
				if (actual.month == 1 && week > 50) { year -= 1; }
				if (actual.month == 12 && week < 3) { year += 1;}

				return Tuple3(type, year, week).toNoteplanDateString();
			default:
				return toTuple3(type).shift(shift).toNoteplanDateString();
		}
	}
}

extension Tuple3Utils on Tuple3<NoteType, int, int> {
	/// shift the 'month/quarter/year' by [int] units
	Tuple3<NoteType, int, int> shift(int change) {
		if (! NoteType.shiftable.contains(item1)) {
			throw StateError('Tuple3.shift unsupported for NoteType.weekly');
		}
		int max = {
			NoteType.monthly: 12,
			NoteType.quarterly: 4,
			NoteType.yearly: 1
		}[item1]!;
		int y = item2;
		int x = item3 + change;
		while (x > max) { x -= max; y += 1; }
		while (x < 1)     { x += max; y -= 1; }
		return Tuple3(item1, y, x);
	}

	/// Get a Noteplan note name from [Tuple3<type, year, ??>]
	String toNoteplanDateString() {
		if ([NoteType.daily, NoteType.note].contains(item1)) {
			throw ArgumentError(
				'Tuple3.toNoteplanDateString: wrong NoteType in Tuple3<${item1}, ${item2}, ${item3}>'
			);
		}

		switch (item1) {
			case NoteType.weekly: return '${item2.padLeft(4)}-W${item3.padLeft(2)}';
			case NoteType.monthly: return '${item2.padLeft(4)}-${item3.padLeft(2)}';
			case NoteType.quarterly: return '${item2.padLeft(4)}-Q${item3}';
			default: return item2.padLeft(4);
		}
	}
}
