import 'package:alfred_noteplan/note_type.dart';
import 'package:alfred_noteplan/int_padding.dart';
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

	static DateTime firstWeekStart(int year, [int weekStartsOn = DateTime.monday]) {
		DateTime d = DateTime(year, 1, 1);
		while (d.adjustedWeekOfYear(weekStartsOn) == 1 || d.adjustedWeekOfYear(weekStartsOn) > 50) {
			d = d.add(Duration(days: 1));
		} // repeat until adjusted week is a first day of week 2
		return d.subtract(Duration(days: 7)); // return the "previous week" first day
	}

	/// Convert [DateTime] to [Tuple3<type, year, ??>] based on [NoteType]
	Tuple3<NoteType, int, int> toTuple3(NoteType type, {int weekStartsWith = DateTime.monday}) {
		if (! NoteType.convertableToTuple3.contains(type)) {
			throw ArgumentError('DateTime.toTuple3: can\'t convert ${type} to Tuple3');
		}

		switch (type) {
			case NoteType.weekly:
				final int rweek = adjustedWeekOfYear(weekStartsWith);
				int ryear = year;
				if (month == 1 && rweek > 50) { ryear -= 1; }
				if (month == 12 && rweek < 3) { ryear += 1;}
				return Tuple3(type, ryear, rweek);
			case NoteType.monthly: return Tuple3(type, year, month);
			case NoteType.quarterly: return Tuple3(type, year, quarter);
			default: return Tuple3(type, year, 1);
		}
	}

	/// Get a Noteplan note name ([String]) from a [DateTime]
	String toNoteplanDateString (NoteType type) {
		if (type == NoteType.note) {
			throw ArgumentError('DateTime.toNoteplanDateString: can\'t convert ${type} to filename.');
		}

		switch (type) {
			case NoteType.daily:
				return [
					year.padLeft(4),
					month.padLeft(2),
					day.padLeft(2)
				].join();
			default:
				return toTuple3(type).toNoteplanDateString();
		}
	}

	/// Convert to a user-formatted note title
	String toNoteplanTitle (NoteType type) {
		switch (type) {
			case NoteType.daily:
			case NoteType.monthly:
				return type.formatTitleDate(this);
			case NoteType.weekly:
			case NoteType.quarterly:
			case NoteType.yearly:
				final t3 = toTuple3(type);
				return type.formatTitleWithValues(t3.item2, t3.item3);
		  	default:
		  		throw ArgumentError('DateTime.toNoteplanTitle: can\'t convert ${type} to filename.');
		}
	}

	/// Returns a [Tuple2<title, datestring>] for a given date
	Tuple2<String, String> toNoteplan(NoteType type) {
		return Tuple2(
			toNoteplanTitle(type),
			toNoteplanDateString(type)
		);
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
