import Database from "better-sqlite3";
const db = new Database("db2.sqlite3");
import { ray } from "node-ray";
import {dirname, resolve} from "path";
import {fileURLToPath} from 'url';

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

const __dirname = dirname(fileURLToPath(import.meta.url));

const resultsFormatted = results.map(r => ({
    title: r.title,
    subtitle: r.path ? `${r.path} • ${r.snippet.replace(/\n/g, '↩')}` : r.snippet.replace(/\n/g, '↩'),
    arg: r.callback,
    icon: {path: resolve(__dirname, "../icons/noteplan-calendar.png")}
}))

ray(resultsFormatted[0].icon)

console.log(JSON.stringify({items: resultsFormatted}))