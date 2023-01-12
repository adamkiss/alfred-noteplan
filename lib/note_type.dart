import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:intl/intl.dart';

enum NoteType {
	note      ,
	daily     ,
	weekly    ,
	monthly   ,
	quarterly ,
	yearly    ;

	static List<NoteType> shiftable = [
		NoteType.monthly,
		NoteType.quarterly,
		NoteType.yearly
	];
	static List<NoteType> convertableToTuple3 = [
		NoteType.weekly,
		NoteType.monthly,
		NoteType.quarterly,
		NoteType.yearly
	];

	String get value {
		switch (this) {
			case NoteType.note: return 'note';
			case NoteType.daily: return 'daily';
			case NoteType.weekly: return 'weekly';
			case NoteType.monthly: return 'monthly';
			case NoteType.quarterly: return 'quarterly';
			case NoteType.yearly: return 'yearly';
			default: return ''; // won't happen
		}
	}

	static NoteType create_from_string(String from) {
		switch (from) {
			case 'note': return NoteType.note;
			case 'daily': return NoteType.daily;
			case 'weekly': return NoteType.weekly;
			case 'monthly': return NoteType.monthly;
			case 'quarterly': return NoteType.quarterly;
			case 'yearly': return NoteType.yearly;
			default: throw Exception("This doesn't make sense.");
		}
	}

	String get np_folder {
		return this == NoteType.note
			? 'Notes'
			: 'Calendar';
	}

	String formatBasename(String bname) {
		// ignore: prefer_typing_uninitialized_variables
		var  rmatch; // Re-assignable utility

		switch (this) {
			case NoteType.daily:
				rmatch = RegExp(r'^(\d{4})(\d{2})(\d{2})').firstMatch(bname);
				var dt = DateTime(
					int.parse(rmatch.group(1)!, radix: 10),
					int.parse(rmatch.group(2)!, radix: 10),
					int.parse(rmatch.group(3)!, radix: 10)
				);
				return DateFormat(Config.titleFormatDaily, Config.locale).format(dt);
			case NoteType.weekly:
				rmatch = RegExp(r'(\d+)-[A-Z](\d+)').firstMatch(bname);
				return Config.titleFormatWeekly
					.replaceAll('%w', rmatch.group(2)!)
					.replaceAll('%y', rmatch.group(1)!);
			case NoteType.monthly:
				rmatch = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(bname);
				var dt = DateTime(
					int.parse(rmatch.group(1)!, radix: 10),
					int.parse(rmatch.group(2)!, radix: 10)
				);
				return DateFormat(Config.titleFormatMonthly, Config.locale).format(dt);
			case NoteType.quarterly:
				rmatch = RegExp(r'(\d+)-[A-Z](\d+)').firstMatch(bname);
				return Config.titleFormatQuarterly
					.replaceAll('%q', rmatch.group(2)!)
					.replaceAll('%y', rmatch.group(1)!);
			case NoteType.yearly:
				rmatch = RegExp(r'^(\d{4})$').firstMatch(bname);
				return Config.titleFormatYearly.replaceAll('%y', rmatch.group(1)!);


			default: throw StateError("NoteType: Can't reformat 'note' type of note.");
		}
	}
}
