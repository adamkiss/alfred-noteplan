const {join} = require('path');
const config = require('./config');
const {createNoteEntry} = require('./create');
const {getWorkflowDatabase} = require('./database');
const { createOpenNoteUrl, createCalendarNoteUrl } = require('./noteplan-urls');
const respond = require('./respond')

module.exports = function(query = '') {
    const preparedQuery = query
        .replace('/[^\p{L}\s\d]/', '') // Remove everything except numbers, letters and spaces
        .replace('/\s+/', ' ') // compress spaces
        .trim()
        .replace(' ', '* ') // word => word*
        + '*';

    const db = getWorkflowDatabase();
    const results = db.prepare(`
    SELECT
        snippet(notes, 1, '›', '‹', '…', 20) as title,
        path,
        type,
        snippet(notes, 2, '›', '‹', '…', 5) as snippet
    FROM
        notes('title:${preparedQuery} OR body:${preparedQuery}')
    ORDER BY
        rank
    LIMIT
        20
    `).all()
    
    const resultsFormatted = results.map(r => ({
        title: r.title,
        subtitle: r.type === 'note'
            ? `${r.path} • ${r.snippet.replace(/\n/g, '↩')}`
            : r.snippet.replace(/\n/g, '↩'),
        arg: r.type === 'note'
            ? createOpenNoteUrl(r.path)
            : createCalendarNoteUrl(r.path),
        mods: {
            cmd: {
                valid: true,
                arg: r.type === 'note'
                    ? createOpenNoteUrl(r.path)
                    : createCalendarNoteUrl(r.path),
                subtitle: 'Open the note in a new Noteplan window'
            }
        },
        icon: {path: `icons/icon-${r.type}.icns`},
        quicklookurl: join(config.np_root, r.type === 'note' ? 'Notes' : 'Calendar', r.path)
    }))

    resultsFormatted.push(createNoteEntry(query))
    
    respond(resultsFormatted)
}