<?php

namespace Adamkiss\AlfredNoteplanFTS;

use PDO;

class Database {
    /** @var PDO */
    static $pdo = null;

    /**
     * Get a Singleton connection to a SQLite Database
     *
     * @return PDO
     */
    private static function getPDO(): PDO {
        if (is_null(self::$pdo)) {
            $cacheDatabase = config('noteplan_root') . '/Caches/sync-cache.db';
            self::$pdo = new PDO('sqlite:' . config('root') . '/database.sqlite3');
        }

        return self::$pdo;
    }

    /**
     * Creates the database and sets up tables if the file doesn't exist
     *
     * @return void
     */
    static function ensureExistence()
    {
        if (! file_exists(config('root') . '/database.sqlite3')) {
            $db = self::getPDO();

            // Setup tables
            $db->exec(<<<SQL
                DROP TABLE IF EXISTS notes;
                DROP TABLE IF EXISTS counter;
                CREATE VIRTUAL TABLE notes USING fts5(
                    file,
                    type UNINDEXED,
                    pathinfo UNINDEXED,
                    title,
                    body,
                    prefix='3 4'
                );
                CREATE TABLE counter (
                    key TEXT PRIMARY KEY,
                    value INTEGER
                );
            SQL);

            // Reset "last-run" counter
            Database::setLastRun();
        }
    }

    /**
     * Get the timestamp of the last run from the table
     *
     * @return integer
     */
    static function getLastRun(): int
    {
        return self::getPDO()
            ->query("SELECT value FROM counter WHERE key IS 'last-run'", PDO::FETCH_COLUMN, 0)
            ->fetch() ?: 0;
    }

    /**
     * Set the timestamp of last run (or a reset if no value is given)
     *
     * @param integer $timestamp
     * @return void
     */
    static function setLastRun(int $timestamp = 0)
    {
        self::getPDO()
            ->prepare(<<<SQL
                INSERT INTO counter VALUES ('last-run', ?)
                ON CONFLICT(key) DO UPDATE SET value = excluded.value
            SQL)
            ->execute([$timestamp]);
    }

    /**
     * Update fts5 index with given files
     *
     * @param array $notes
     * @return void
     */
    static function updateIndex(array $notes = [])
    {
        if (empty($notes)) return;

        $db = self::getPDO();

        // Delete old notes
        $delete = $db->prepare(
            "DELETE FROM notes WHERE file IN ("
            . implode(",", array_map(fn($n) => '?', $notes))
            . ")"
        )->execute(array_map(fn($n) => $n->get('filename'), $notes));

        // Insert new versions
        $insert = $db->prepare(
            "INSERT INTO notes (file, type, pathinfo, title, body) VALUES " .
            implode(',', array_map(fn($n) => '(?, ?, ?, ?, ?)', $notes))
        );
        $values = array_reduce($notes, function($carry, $note) {
            return array_merge($carry, [
                /*'file'      =>*/ $note->get('filename'),
                /*'type'      =>*/ $note->getTypeString(),
                /*'pathinfo'  =>*/ serialize($note->pathinfo),
                /*'title'     =>*/ $note->title,
                /*'body'      =>*/ $note->content,
            ]);
        }, []);
        $insert->execute($values);
    }

	static function search(string $query): array
	{
		// Remove everything except numbers, letters and spaces
		$query = preg_replace('/[^\p{L}\s\d]/u', '', $query);
		// trim, collapse spaces and append '*' to each word
		$query = implode('* ', preg_split('/\s+/', trim($query))) . '*';

		// prepare subfunctions
		$c = fn($g) => Config::get($g);
		$join_snippet_matches = sprintf(
			'/\%s([\s\-\+\_\!\?\.\,]+?)\%s/i',
			$c('sql_end'), $c('sql_start')
		);

		$db = self::getPDO();
		$search = $db->query(<<<SQL
			SELECT
				file,
				pathinfo,
				type,
				snippet(
					notes, 3,
					'{$c('sql_start')}', '{$c('sql_end')}',
					'{$c('sql_more')}',
					{$c('sql_title_tokens')}
				) as title,
				snippet(
					notes, 4,
					'{$c('sql_start')}', '{$c('sql_end')}',
					'{$c('sql_more')}',
					{$c('sql_snippet_tokens')}
				) as snippet
			FROM
				notes('title: {$query} OR body: {$query}')
			ORDER BY
				rank
			LIMIT
				20
		SQL);
		$notes = $search->fetchAll(
			PDO::FETCH_FUNC,
			function(
				string $file, string $pathinfo, string $type, string $title, string $snippet
			) use ($join_snippet_matches) {
				$pathinfo = unserialize($pathinfo);
				$snippet = str_replace("\n", '↩', $snippet);
				$snippet = preg_replace($join_snippet_matches, '$1', $snippet);
				$title = preg_replace($join_snippet_matches, '$1', $title);

				return Alfred::item(
					title: $title,
					subtitle: $type === 'note'
						? "[{$pathinfo['dirname']}] {$snippet}"
						: $snippet,
					arg: $type === 'note'
						? NoteplanCallback::openNote($file)
						: NoteplanCallback::openCalendar($pathinfo['filename']),
					mods: [
						'cmd' => [
							'valid' => true,
							'arg' => $type === 'note'
								? NoteplanCallback::openNote($file, false)
								: NoteplanCallback::openCalendar($pathinfo['filename'], false),
							'subtitle' => 'Open the note in a new Noteplan window'
						]
					],
					icon: [
						'path' => "icons/icon-{$type}.icns",
					],
					quicklookurl: implode('/', [
						Config::get('noteplan_root'),
						$type === 'note' ? 'Notes' : 'Calendar',
						$file
					])
				);
			}
		);

		return $notes;
	}
}
