const Database = require("better-sqlite3");

const getWorkflowDatabasePath = _ => `${process.cwd()}/database.sqlite3`

/**
 * Connects to the Noteplan cache database
 */
const getCacheDatabase = () => {
    // return new Database()
}

/**
 * Connects to the fts database
 * 
 * @returns Database
 */
const getWorkflowDatabase = () => {
    return new Database(getWorkflowDatabasePath())
}

/**
 * Creates the database for the workflow
 */
const createWorkflowDatabase = () => {
    const db = getWorkflowDatabase();
    try {
        db.pragma('journal_mode = wal');
        db.exec(`
            DROP TABLE IF EXISTS notes;
            DROP TABLE IF EXISTS metadata;
            CREATE VIRTUAL TABLE notes USING fts5(
                file,
                title,
                body,
                path UNINDEXED,
                type UNINDEXED,
                callback UNINDEXED,
                prefix='2 3 4'
            );
            CREATE TABLE metadata (
                key TEXT PRIMARY KEY,
                value TEXT
            );
            INSERT INTO metadata VALUES ('last-run', 0);
        `);
        db.close();
    } catch (error) {
        console.log(error)
    }
}

module.exports = {
    getWorkflowDatabasePath,
    getCacheDatabase, getWorkflowDatabase,
    createWorkflowDatabase
}