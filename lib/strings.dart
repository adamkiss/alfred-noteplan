// ignore_for_file: constant_identifier_names

import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:intl/intl.dart';

const str_usage = ''
	'Usage: noteplan_fts-[arch] [command] [arguments] \n'
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

extension StringCasingExtension on String { // source: https://stackoverflow.com/a/29629114/240239
	String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
	String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

	String splitFormatAndCapitalize(DateTime d) => split(' ')
		.map((part) => DateFormat(part, Config.locale).format(d))
		.map((part) => part.toCapitalized())
		.join(' ');
}