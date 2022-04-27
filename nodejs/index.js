import Database from "better-sqlite3";
import FastGlob from "fast-glob";
import dayjs from "dayjs";

import {readFile} from 'fs/promises'
import {readFileSync} from 'fs'
import {join} from 'path'

import { ray } from "node-ray";

import noteplan_root from "./config.js";


const db = new Database("db2.sqlite3");

db.pragma('journal_mode = wal');
db.exec(`CREATE VIRTUAL TABLE IF NOT EXISTS notes USING fts5(
    file,
    title,
    body,
    path UNINDEXED,
    type UNINDEXED,
    callback UNINDEXED,
    prefix='2 3 4'
)`);
db.exec('DELETE FROM notes');

const calendarEntries = FastGlob.sync(['Calendar/***.md'], {
    cwd: noteplan_root,
    stats: true
}).map(f => Object.assign(f, {
    content: readFileSync(join(noteplan_root, f.path), 'utf8')
})).filter(f => f.content.length)
// .slice(0, 2)
.map(f => {
    const [,year,month,day] = f.name.match(/^(\d{4})(\d{2})(\d{2})/);
    const date = new Date(year, month-1, day);

    return {
        file: f.path,
        title: dayjs(f.name.slice(0,8), "YYYYMMDD").format('DD.MM.YYYY'),
        body: f.content,
        path: null,
        type: 'calendar',
        callback: null
    }
})

const massInsert = `INSERT INTO NOTES (file, title, body, path, type, callback) VALUES ${calendarEntries.map(f => `(?, ?, ?, ?, ?, ?)`).join(', ')}`;
const stmt = db.prepare(massInsert);
stmt.run(...calendarEntries.map(f => [f.file, f.title, f.body, f.path, f.type, f.callback]));

db.close();