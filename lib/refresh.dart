import 'package:alfred_noteplan/dbs.dart';
import 'package:alfred_noteplan/note.dart';

int refresh(Dbs db, {bool force = false}) {
	// Delete missing notes
	db.delete_missing_notes();

	// Get changed notes in Cache
	List<Note> new_notes = [];
	for (var result in db.cache_get_updated(since: force ? 0 : db.get_last_update())) {
		try {
			new_notes.add(Note.fromRow(result));
		} catch (e) {
			// swallow not creation error and continue
			// this should skip over errors and just… not show erroneous notes
		}
	}

	// Delete/reinsert the notes
	if (new_notes.isNotEmpty) {
		final Iterable<String> notes_to_update = new_notes.map((e) => e.filename);

		db.delete_where_filename_in('notes', notes_to_update);
		db.insert_notes(new_notes);

		db.delete_where_filename_in('hyperlinks', notes_to_update);
		db.insert_hyperlinks(new_notes);

		db.delete_where_filename_in('code_bits', notes_to_update);
		db.insert_code_bits(new_notes);
	}

	// Save the last update and cleanup
	db.set_last_update();

	// return number of updates
	return new_notes.length;
}