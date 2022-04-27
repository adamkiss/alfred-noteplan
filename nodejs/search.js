const Database = require("better-sqlite3");
const {resolve} = require('path');
const {ray} = require("node-ray");

const db = new Database('db2.sqlite3');

const results = db.prepare(`
SELECT
    snippet(notes, 1, '›', '‹', '…', 20) as title,
    path,
    type,
    callback,
    snippet(notes, 2, '›', '‹', '…', 5) as snippet
FROM
    notes('title:${process.argv[2]} OR body:${process.argv[2]}')
ORDER BY
    rank
LIMIT
    20
`).all()

const resultsFormatted = results.map(r => ({
    title: r.title,
    subtitle: r.path ? `${r.path} • ${r.snippet.replace(/\n/g, '↩')}` : r.snippet.replace(/\n/g, '↩'),
    arg: r.callback,
    icon: {path: "icons/noteplan-calendar.png"}
}))

console.log(JSON.stringify({items: resultsFormatted}))