enum NoteType {
	note      ,
	daily     ,
	weekly    ,
	monthly   ,
	quarterly ,
	yearly    ;

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

	String get np_folder {
		return this == NoteType.note
			? 'Notes'
			: 'Calendar';
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
}
