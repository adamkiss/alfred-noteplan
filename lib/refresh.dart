import 'package:alfred_noteplan/dbs.dart';
import 'package:alfred_noteplan/note.dart';

int refresh(Dbs db, {bool force = false}) {
	// Delete missing notes
	db.delete_missing_notes();

	// Get changed notes in Cache
	List<Note> new_notes = [];
	for (var result in db.cache_get_updated(since: force ? 0 : db.get_last_update())) { new_notes.add(Note.fromRow(result)); }

	// Delete/reinsert the notes
	if (new_notes.isNotEmpty) {
		db.delete_notes_to_update(new_notes.map((e) => e.filename));
		db.insert_notes(new_notes);
	}

	// Save the last update and cleanup
	db.set_last_update();

	// return number of updates
	return new_notes.length;
}