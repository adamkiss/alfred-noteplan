import 'package:alfred_noteplan/note.dart';
class Bookmark {
	final Note note;
	final String url;
	final String title;
	String? description; // currently noop

	Bookmark(
		this.note,
		this.title,
		this.url,
		{this.description}
	);
}