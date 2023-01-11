
import 'package:alfred_noteplan_fts_refresh/note_type.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

extension DateUtils on DateTime {
	/// Shift a [Tuple2<year, x>] forward or backward
	/// Universal private method used by shift_month and shift_quarter
	static Tuple2<int, int> _shift(
		Tuple2<int, int> year_x, int max_x,
		{int change = 0}
	) {
		int y = year_x.item1;
		int x = year_x.item2 + change;
		while (x > max_x) { x -= max_x; y += 1; }
		while (x < 1)     { x += max_x; y -= 1; }
		return Tuple2(y, x);
	}

	int get quarter => int.parse(DateFormat('Q').format(this), radix: 10);
	int get dayOfYear => int.parse(DateFormat('D').format(this), radix: 10);
	int get weekOfYear => ((dayOfYear - day + 10) / 7).floor();

	/// Convert [DateTime] to [Tuple2<year, ??>] based on [NoteType]
	Tuple2<int, int> toTuple2(NoteType type) {
		if ([NoteType.daily, NoteType.note].contains(type)) {
			throw ArgumentError('DateTime.toTuple2: can\'t convert ${type} to Tuple2');
		}

		switch (type) {
			case NoteType.weekly: return Tuple2(year, weekOfYear);
			case NoteType.monthly: return Tuple2(year, month);
			case NoteType.quarterly: return Tuple2(year, quarter);
			default: return Tuple2(year, 1);
		}
	}

	/// Get a Noteplan note name ([String]) from a [DateTime]
	String noteplan_filename (NoteType type, {int change = 0}) {
		if (type == NoteType.note) {
			throw ArgumentError('DateTime.noteplan_filename: can\'t convert ${type} to filename.');
		}

		switch (type) {
			case NoteType.daily:
				return '';
			default: /// NoteType.yearly
				return '';
		}
	}
}

extension Tuple2Utils on Tuple2 {

	/// Get a Noteplan note name from [Tuple2<year, ??>]
	String noteplan_filename(NoteType type) {
		if ([NoteType.daily, NoteType.note].contains(type)) {
			throw ArgumentError(
				'Tuple2.noteplan_filename: '
				'can\'t create ${type} from a '
				'Tuple2<${item1}, ${item2}>.'
			);
		}

		switch (type) {
			case NoteType.weekly: return '${item1}-W${item2}.md';
			case NoteType.monthly: return '${item1}-${item2}.md';
			case NoteType.quarterly: return '${item1}-Q${item2}.md';
			default: return '${item1}.md';
		}
	}

}
