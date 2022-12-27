<?php

namespace Adamkiss\NoteplanFTS;

use PDO;

class Database {
    /**
     * Singleton instance
     */
    static $instance;

    /**
     * PDO Connection
     *
     * @var PDO
     */
    public $pdo;

    /**
     * Creates the database and sets up tables if the file doesn't exist
     *
     * @return void
     */
    static function ensureExistence()
    {
        if (! file_exists(config('root') . '/database.sqlite3')) {
            $db = self::instance();

            // Setup tables
            $db->pdo->exec(<<<SQL
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
            
            // Insert the "last-run" counter
            $db->pdo
                ->prepare("INSERT INTO counter VALUES ('last-run', ?)")
                ->execute([0]);
        }
    }

    /**
     * Return the singular running instance (initiated if it hasn't been yet)
     *
     * @return self
     */
    static function instance(): self {
        if (is_null(self::$instance)) {
            self::$instance = new Database();
        }

        return self::$instance;
    }

    /**
     * Constructor - initiates the PDO connection
     */
    public function __construct() {
        $root = config('root');
        
        $this->pdo = new PDO("sqlite:{$root}/database.sqlite3");
    }
}