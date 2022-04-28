# Noteplan FTS for Alfred

![OG Social image](social.jpg)

Noteplan full-text search for Alfred - some assembly required. Work in progress, mostly working.

---

## Usage
- `n [Search phrase]` - Full text search. If there isn't any note available, "Create new note" command is the only result
- `nn Title of the note` - Creates a new note, in the folder of your choice
- `nref` - Refresh SQLite database

## Requirements
- PHP install available in CLI
- SQLite with fts5 enabled (available by default in the SQLite "amalgamation" build bundled with Homebrew PHP)

## Installation
1. Clone this repository to your alfred workflows folder (or elsewhere and symlink it)
2. Create `_config.php`, which at minimum contains absolute path to your noteplan document root
	- You can find it in Settings: Settings → Sync → [Sync method] → Advanced → Open Local Database Folder
	- "root" is the folder that containes all your things - Backups, Notes, Calendar items, templates. Everything.
3. Run `nref` in the Alfred to generate your sqlite cache for the first time

## Minimal `_config.php` example:
``` php
<?php 
return [
  'noteplan_root' => '/absolute/path/to/noteplan/'
];
?>
```

## This repository also contains
- experimental `ripgrep` version - databaseless version of full-text search: PHP parses input, prepares ripgrep search, and then formats the results. Available via command `nrg`, which will be removed in future updates. 
- experimental `nodejs` version - this one is super dirty/simple testing version, where I tried if it would be possible to do the sqlite access/formatting via packaged, standalone nodejs script for users with no programming experience. It is possible, but due to requirements like codesigning (Apple Developer Program yearly licenses, etc.), will probably not be developed further. Rough testing search version available as `njs`.

## License
MIT License

---

© 2022 Adam Kiss