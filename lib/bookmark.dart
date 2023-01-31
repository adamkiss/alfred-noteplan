class Bookmark {
	final String filename;
	final String url;
	final String title;
	String? description; // currently noop

	Bookmark(
		this.filename,
		this.title,
		this.url,
		{this.description}
	);
}