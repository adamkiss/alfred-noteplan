String _create_noteplan_url({
	String method = 'openNote',
	Map<String, dynamic>? params
}) {
	final String query_params = params?.keys.map((key) => '${key}=${params[key]}').join('&') ?? '';
	final String url = 'noteplan://x-callback-url/${method}?${query_params}';
	return Uri.encodeFull(url); // Fucking spaces again.
}

String calendar_url(String bname, {bool sameWindow = true}) {
	return _create_noteplan_url(params: {
		'noteDate': bname,
		'useExistingSubWindow': sameWindow ? 'yes' : 'no'
	});
}

String note_url(String filename, {bool sameWindow = true}) {
	return _create_noteplan_url(
		params: {
			'filename': filename,
			'useExistingSubWindow': sameWindow ? 'yes' : 'no'
		}
	);
}

String create_url(
	String folder,
	String body,
	{bool sameWindow = true}
) => _create_noteplan_url(
	method: 'addNote',
	params: {
		'text': body,
		'folder': folder,
		'useExistingSubWindow': sameWindow ? 'yes' : 'no',
		'openNote': 'yes'
	}
);
