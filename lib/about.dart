import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/config.dart';
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
}