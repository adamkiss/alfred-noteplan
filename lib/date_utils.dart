import 'package:alfred_noteplan/note_type.dart';
import 'package:alfred_noteplan/int_padding.dart';
import 'package:intl/intl.dart';

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

	/// Convert [DateTime] to [(type, year, ??) record] based on [NoteType]
	(NoteType, int, int) toRecord(NoteType type, {int weekStartsWith = DateTime.monday}) {
		if (! NoteType.convertableToTuple3.contains(type)) {
			throw ArgumentError('DateTime.toRecord: can\'t convert ${type} to Record');
		}

		switch (type) {
			case NoteType.weekly:
				final int rweek = adjustedWeekOfYear(weekStartsWith);
				int ryear = year;
				if (month == 1 && rweek > 50) { ryear -= 1; }
				if (month == 12 && rweek < 3) { ryear += 1;}
				return (type, ryear, rweek);
			case NoteType.monthly: return (type, year, month);
			case NoteType.quarterly: return (type, year, quarter);
			default: return (type, year, 1);
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
				return toRecord(type).toNoteplanDateString();
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
				final t3 = toRecord(type);
				return type.formatTitleWithValues(t3.$2, t3.$3);
		  	default:
		  		throw ArgumentError('DateTime.toNoteplanTitle: can\'t convert ${type} to filename.');
		}
	}

	/// Returns a [(String, String) record] for a given date
	(String, String) toNoteplan(NoteType type) {
		return (
			toNoteplanTitle(type),
			toNoteplanDateString(type)
		);
	}
}

extension RecordsUtils on (NoteType, int, int) {
	/// shift the 'month/quarter/year' by [int] units
	(NoteType, int, int) shift(int change) {
		if (! NoteType.shiftable.contains($1)) {
			throw StateError('Record.shift unsupported for NoteType.weekly');
		}
		int max = {
			NoteType.monthly: 12,
			NoteType.quarterly: 4,
			NoteType.yearly: 1
		}[$1]!;
		int y = $2;
		int x = $3 + change;
		while (x > max) { x -= max; y += 1; }
		while (x < 1)     { x += max; y -= 1; }
		return ($1, y, x);
	}

	/// Get a Noteplan note name from [Tuple3<type, year, ??>]
	String toNoteplanDateString() {
		if ([NoteType.daily, NoteType.note].contains($1)) {
			throw ArgumentError(
				'Record(NoteType, int, int).toNoteplanDateString: wrong NoteType in Record (${$1}, ${$2}, ${$3})'
			);
		}

		switch ($1) {
			case NoteType.weekly: return '${$2.padLeft(4)}-W${$3.padLeft(2)}';
			case NoteType.monthly: return '${$2.padLeft(4)}-${$3.padLeft(2)}';
			case NoteType.quarterly: return '${$2.padLeft(4)}-Q${$3}';
			default: return $2.padLeft(4);
		}
	}
}