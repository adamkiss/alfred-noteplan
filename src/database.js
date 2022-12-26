const Database = require("better-sqlite3");
const config = require('./config')

/**
 * Path for the cache database Noteplan has
 * @returns string
 */
const getCacheDatabasePath = () => `${config.np_root}/Caches/sync-cache.db`

/**
 * Path for the full-text database
 * @returns string
 */
const getWorkflowDatabasePath = () => `${config.cwd}/database.sqlite3`

/**
 * Connects to the Noteplan cache database
 */
const getCacheDatabase = () => {
    return new Database(getCacheDatabasePath())
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
    try {
        const db = getWorkflowDatabase();
        
        db.exec(`
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
        `);
        db.prepare(`INSERT INTO counter VALUES ('last-run', ?)`).run(0);

        return db;
    } catch (error) {
        console.log(error)
    }
}

module.exports = {
    getCacheDatabasePath, getWorkflowDatabasePath,
    getCacheDatabase, getWorkflowDatabase,
    createWorkflowDatabase
}