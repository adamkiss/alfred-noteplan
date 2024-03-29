// ignore_for_file: constant_identifier_names

import 'package:alfred_noteplan/config.dart';
import 'package:intl/intl.dart';

const str_usage = ''
	'Usage: noteplan-[arch] [command] [arguments] \n'
	'Commands: \n'
	' - refresh <force?> - force is optional \n'
	' - debug \n'
	' - create <title> - required\n'
	' - date <query> - required, begins with ">"\n'
	' - search <query> - required\n'
;
const str_error_missing_command = 'Command required.';
const str_error_missing_root = 'No Noteplan root set. Did you import the workflow correctly?';
const str_error_missing_args = "Commands 'create', 'date' and 'search' require arguments.";
const str_error_date_unparsable = "Command 'date' expects argument in the form '><\\s>*?<query>";

const str_update_subtitle = 'The database was refreshed. You can close this prompt.';
const str_fts_result_arg_cmd_subtitle = 'Open the note in a new Noteplan window';
const str_create_result_subtitle = 'Create a new note ✱ You\'ll be asked for location in the next step';
str_create_folder_result_subtitle(String f, String t) => 'Create note "${t}" in folder "${f}"';

const str_bookmark_open_note = 'Open the note the bookmark was found in';
const str_bookmark_copy = 'Copy the URL to clipboard';
const str_bookmark_copy_paste = 'Copy the URL to clipboard and paste to frontmost app';

const str_snippet_open_note = 'Open the note the snippet was found in';
const str_snippet_copy = 'Copy the snippet to clipboard without pasting';

const str_open_snippet = '‹';
const str_close_snippet = '›';

extension StringExtensions on String {
	// source: https://stackoverflow.com/a/29629114/240239
	String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
	String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

	String splitFormatAndCapitalize(DateTime d) => split(' ')
		.map((part) => DateFormat(part, Config.locale).format(d))
		.map((part) => part.toCapitalized())
		.join(' ');

	String unindent() {
		String? first_line_whitespace = RegExp(r'^(\s*)').firstMatch(this)?.group(0);
		if (first_line_whitespace == null || first_line_whitespace.isEmpty) {
			return this;
		}

		return replaceAll(RegExp('^${first_line_whitespace}', multiLine: true), '');
	}

	// ignore: unnecessary_this
	String cleanForFts() => this
		// remove markdown headers
		.replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
		// remove markdown hr
		.replaceAll(RegExp(r'^\s*?\-{3,}\s*$', multiLine: true), '')
		// remove bullets & quotes
		.replaceAll(RegExp(r'^\s*?[\*>-]\s*', multiLine: true), '')
		// remove tasks
		.replaceAll(RegExp(r'^\s*?[*-]?\s*?\[.?\]\s*?', multiLine: true), '')
		// remove markdown styling
		.replaceAll(RegExp(r'[*_]'), '')
		// collapse whitespace
		.replaceAll(RegExp(r'\s+/'), ' ')
		.trim() // trim
	;

	String toFtsQuery() =>
		'${replaceAll(RegExp(r'[^\p{L}\s\d]', unicode: true), '')
		.replaceAll(RegExp(r'\s+'), ' ')
		.trim()
		.replaceAll(' ', '* ')}'
		'*'
	;
}