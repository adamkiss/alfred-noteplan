import 'package:alfred_noteplan/note.dart';

class Snippet {
	final Note note;
	final String language;
	final String title;
	final String content;

	Snippet(
		this.note,
		this.language,
		this.title,
		this.content,
	);
}