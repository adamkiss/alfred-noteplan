const {existsSync} = require('fs')

const matter = require('gray-matter')

const {createWorkflowDatabase, getWorkflowDatabase, getCacheDatabase, getWorkflowDatabasePath } = require('./database')
const { createOpenNoteUrl } = require('./noteplan-urls')
const respond = require('./respond')

// Refresh response to 'n -r'
module.exports.refreshResponse = $bin => {
    return respond([{
        title: "Refresh the database",
        subtitle: "Includes a setup, if needed",
        arg: `${$bin} --refresh`
    }])
}

// Refresh action, called by alfred as `$binary --refresh`
module.exports.refreshAction = function ($bin) {
    const start = new Date().getTime()
    const db = existsSync(getWorkflowDatabasePath())
        ? getWorkflowDatabase()
        : createWorkflowDatabase();
    const np = getCacheDatabase();

    try {
        const lastRun = parseInt(
            db.prepare('SELECT value FROM counter WHERE key = ?').get('last-run').value,
            10
        );

        const notes = np
            .prepare('SELECT filename, content, modified, note_type FROM metadata WHERE is_directory = 0 AND LENGTH(content) AND note_type < 2 AND modified > ?')
            .all(lastRun);

        const processed = notes.map(note => {
            let type, title, body;
            const content = note.content.toString('utf-8').trim()

            if (content.startsWith('---')) {
                // has frontmatter
                try {
                    const {content, data: frontmatter} = matter(content)
                    title = frontmatter.title
                    body = content
                } catch (error) {
                    // error in yaml, probably, parse manually
                    // we capture title and content, throw away front matter
                    const [_, mTitle, mContent] = content.match(/^---.*?title\:\s*?(.*?)\n.*?---(.*)/is)
                    title = mTitle.trim()
                    body = mContent.trim()
                }
            } else {
                // doesn't have frontmatter
                // older style, or has no heading
                const titleParse = content.match(/^#\s*(.*)(?:\n|\s---)/)
                if (titleParse) {
                    title = titleParse[1]
                } else {
                    title = note.filename.split('/').slice(-1)[0].split('.md')[0]
                }
                body = content
            }

            switch (true) {
                case note.note_type == '1':
                    type = 'note';
                break;
                case note.filename.includes('W'):
                    [_, year, week] = note.filename.match(/(\d+)-[A-Z](\d+)/)
                    title = `${year} Week ${week}`
                    type = 'weekly';
                break;
                case note.filename.includes('M'):
                    [_, year, month] = note.filename.match(/(\d+)-[A-Z](\d+)/)
                    title = `${year} Month ${month}`
                    type = 'monthly';
                break;
                case note.filename.includes('Q'):
                    [_, year, quarter] = note.filename.match(/(\d+)-[A-Z](\d+)/)
                    title = `${year} Quarter ${quarter}`
                    type = 'quarterly';
                break;
                case note.filename.includes('Y'):
                    [_, year, year] = note.filename.match(/(\d+)-[A-Z](\d+)/)
                    title = `${year} Year ${year}`
                    type = 'yearly';
                break;
                default:
                    [_, year, month, day] = note.filename.match(/(\d{4})(\d{2})(\d{2})/)
                    title = `${day}.${month}.${year}`
                    type = 'daily';
                break;
            }

            const path = note.filename;

            // further body modification lifted from the original PHP version
            body = body
                .replace('/^#*\s*?/m', '') // remove markdown headers
                .replace('/^\s*?\-{3,}\s*?$/m', '') // remove markdown hr
                .replace('/^\s*?[\*>-]\s*?/m', '') // remove bullets & quotes
                .replace('/^\s*?[*-]?\s*?\[.?\]\s*?/m', '') // remove tasks
                .replace('/[*_]/m', '') // remove markdown styling
                .replace('/\s+/', ' ') // collapse whitespace
                .trim() // trim

            return {
                file: note.filename,
                title,
                body,
                type,
                path,
            }
        });

        if (processed.length > 0) {
            const deleteStmt = db.prepare(`
                DELETE FROM notes
                WHERE file IN (${processed.map(f => '?').join(', ')})
            `).run(...processed.map(p => p.file));
    
            const updateStmt = db.prepare(`
                INSERT INTO notes (file, title, body, path, type, callback)
                VALUES ${processed.map(f => '(?, ?, ?, ?, ?, ?)').join(', ')}
            `).run(...processed.map(p => [p.file, p.title, p.body, p.path, p.type, p.callback]))
        }

        db.prepare(`
            UPDATE counter
            SET value = ?
            WHERE key = 'last-run'
        `).run(Math.floor(new Date().getTime()))

        const duration = Math.round(new Date().getTime() - start)
        console.log(`Updated ${notes.length} notes in ${duration} ms`);
    } catch (error) {
        console.error(error);
    } finally {
        np.close();
        db.close();
    }
}