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
                    title,
                    body,
                    path UNINDEXED,
                    type UNINDEXED,
                    prefix='2 3 4'
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
            "INSERT INTO notes (file, title, body, path, type) VALUES " .
            implode(',', array_map(fn($n) => '(?, ?, ?, ?, ?)', $notes))
        );
        $values = array_reduce($notes, function($carry, $note) {
            return array_merge($carry, [
                /*'file'  =>*/ $note->get('filename'),
                /*'title' =>*/ $note->title,
                /*'body'  =>*/ $note->content,
                /*'path'  =>*/ $note->path,
                /*'type'  =>*/ $note->getTypeString(),
            ]);
        }, []);
        $insert->execute($values);
    }
}