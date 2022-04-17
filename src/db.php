<?php

/**
 * Open or create fts index database
 *
 * @return SQLite3
 */
function db_connect(): SQLite3 {
    return new SQLite3(__DIR__ . '/../db.sqlite3');
}

/**
 * Set WAL mode and create table if it doesn't exist
 */
function db_ensure_exists(SQLite3 $db) {
    $db->exec('PRAGMA journal_mode = wal;');
    $db->exec('CREATE VIRTUAL TABLE IF NOT EXISTS notes USING fts5(
        file,
        title,
        body,
        path UNINDEXED,
        type UNINDEXED,
        callback UNINDEXED,
        prefix=\'2 3 4\'
    )');
}

/**
 * Remove all notes from the database
 * @todo implement mtime diffing in the future for the speed-up?
 *
 * @param SQLite3 $db
 * @return void
 */
function db_clean(SQLite3 $db) {
    $db->exec('DELETE FROM notes');
}

/**
 * Prepare and execute the insert statement for a noteplan note
 *
 * @param SQLite3 $db
 * @param array $note
 * @return bool true on success, false on failure
 */
function db_insert(SQLite3 $db, array $note): SQLite3Result {
    $stmt = $db->prepare(<<<SQL
        INSERT INTO notes (file, title, body, path, type, callback)
            VALUES (:file, :title, :body, :path, :type, :callback);
    SQL);

    $stmt->bindValue(':file', $note['file']);
    $stmt->bindValue(':title', $note['title']);
    $stmt->bindValue(':body', $note['body']);
    $stmt->bindValue(':path', $note['path']);
    $stmt->bindValue(':type', $note['type']);
    $stmt->bindValue(':callback', noteplan_callback_url($note['callback']['method'], $note['callback']['params']));

    return $stmt->execute();
}

function db_query_fts(SQLite3 $db, string $query, array $config): SQLite3Result {
    return $db->query(
        sprintf(<<<SQL
                SELECT
                    snippet(notes, 1, '%2\$s', '%3\$s', '%4\$s', %5\$u) as title,
                    path,
                    type,
                    callback,
                    snippet(notes, 2, '%2\$s', '%3\$s', '%4\$s', %6\$u) as snippet
                FROM
                    notes('title:%1\$s OR body:%1\$s')
                ORDER BY
                    rank
                LIMIT
                    20
            SQL,
            $query,
            $config['snippet_match_start'],
            $config['snippet_match_end'],
            $config['snippet_match_ellipsis'],
            $config['snippet_title_tokens'],
            $config['snippet_body_tokens']
        )
    );
}