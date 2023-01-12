class Noteplan {
	static String _url({
		String method = 'openNote',
		Map<String, dynamic>? params
	}) {
		final String query_params = params?.keys.map((key) => '${key}=${params[key]}').join('&') ?? '';
		final String url = 'noteplan://x-callback-url/${method}?${query_params}';
		return Uri.encodeFull(url); // Fucking spaces again.
	}

	/// Creates a Noteplan URL for a note of type calendar (daily, weekly, monthly, …)
	static String openCalendarUrl(String bname, {bool sameWindow = true}) => _url(
		params: {
			'noteDate': bname,
			'useExistingSubWindow': sameWindow ? 'yes' : 'no'
		}
	);

	/// Creates a Noteplan URL for a normal note
	static String openNoteUrl(String filename, {bool sameWindow = true}) => _url(
		params: {
			'filename': filename,
			'useExistingSubWindow': sameWindow ? 'yes' : 'no'
		}
	);

	/// Creates a note creation URL. Title is expected to be a part of the body
	static String addNoteUrl(String folder, String body, {bool sameWindow = true}) => _url(
		method: 'addNote',
		params: {
			'text': body,
			'folder': folder,
			'useExistingSubWindow': sameWindow ? 'yes' : 'no',
			'openNote': 'yes'
		}
	);
}
