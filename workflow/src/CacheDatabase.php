<?php

namespace Adamkiss\AlfredNoteplanFTS;

use PDO;

class CacheDatabase {
    static $pdo = null;

    private static function getPDO() {
        if (is_null(self::$pdo)) {
            $cacheDatabase = config('noteplan_root') . '/Caches/sync-cache.db';
            self::$pdo = new PDO("sqlite:{$cacheDatabase}");
        }

        return self::$pdo;
    }

    /**
     * Get all modified notes in the Noteplan cache database
     *
     * @param integer $since timestamp
     * @return array|null
     */
    static function getNotesModifiedSince(int $since = 0): ?array
    {
        $db = self::getPDO();

        $stmt = $db->prepare(<<<SQL
                SELECT filename, content, modified, note_type
                FROM metadata
                WHERE is_directory = 0
                AND LENGTH(content)
                AND note_type < 2
                AND modified > ?
            SQL);
        $stmt->execute([$since * 1000]);

        return $stmt->fetchAll(
            PDO::FETCH_FUNC,
            fn($filename, $content, $modified, $note_type)
            => new CacheNote(compact('filename', 'content', 'modified', 'note_type'))
        );
    }

	static function getAllFolders(): array
	{
		$db = self::getPDO();

		$query = $db->query(
			'SELECT filename FROM metadata WHERE is_directory = 1 AND note_type = 1'
		);
		$folders = array_map(fn($row) => $row['filename'], $query->fetchAll());

		return array_filter($folders, fn($f) => !str_starts_with($f, '@'));
	}
}
