import 'dart:io';

import 'package:alfred_noteplan/alfred.dart';
import 'package:alfred_noteplan/config.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

class About {
	late final String version;
	late final String macos_version;
	late final String macos_arch;
	late final String sqlite_version;

	String _r(String command, List<String> args) {
		final capture = Process.runSync(command, args).stdout;
		return capture.trim();
	}

	About () {
		version = _r('defaults', ['read', join(Config.workflow_root(), 'info'), 'version']);
		sqlite_version = sqlite3.version.libVersion;
		macos_version = _r('sw_vers', ['-productVersion']);
		macos_arch = _r('uname', ['-m']);
	}

	String for_clipboard() => ''
		'Workflow version: ${version}\n'
		'SQLite3 version: ${sqlite_version}\n'
		'macOS: ${macos_version} / ${macos_arch}';

	String to_alfred() => alf_to_results([
			alf_item(
				'Workflow information', 'Copy to clipboard',
				arg: for_clipboard(),	variables: {'action':'copy-to-clipboard'}
			),
			alf_item(
				version, 'Workflow version',
				valid: false, text: {'copy': version}
			),
			alf_item(
				sqlite_version, 'SQLite3 version',
				valid: false, text: {'copy': sqlite_version}
			),
			alf_item(
				macos_version, 'macOS version',
				valid: false, text: {'copy': macos_version}
			),
			alf_item(
				macos_arch, 'mac architecture',
				valid: false, text: {'copy': macos_arch}
			),
			alf_item(
				Config.noteplan_root, 'NotePlan root directory',
				valid: false, text: {'copy': Config.noteplan_root}
			),
	]);
}