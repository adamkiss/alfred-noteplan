const { getCacheDatabase } = require("./database")
const { createAddNoteUrl } = require("./noteplan-urls")
const respond = require("./respond")

const noteTemplate = title => `---
title: ${title}
date: {date:short}
---

`

const createNoteEntry = title => ({
    title: `Create "${title}"`,
    subtitle: `Creates a new note • You'll be asked for location in the next step`,
    icon: {path: 'icons/icon-create.icns'},
    arg: `New: ${title}`
})

const createNoteInFolderEntry = (title, folder) => ({
    title: folder,
    subtitle: `Creates note '${title}' in folder '${folder}'`,
    icon: {path: 'icons/icon-create.icns'},
    arg: createAddNoteUrl({title, folder, body: noteTemplate(title)})
})

const getAllFolderEntries = (title) => {
    const np = getCacheDatabase()

    // is_directory marks directory, while note_type marks only note directories
    // because also plugins and templates have directories in the cache db
    const allFolders = np.prepare(`
        SELECT filename FROM metadata WHERE is_directory = 1 AND note_type = 1
    `).all();

    const folders = allFolders
        .map(f => f.filename)
        .filter(f => !f.startsWith('@')) // @Xyz are special Noteplan folders
        .map(f => createNoteInFolderEntry(title, f))

    return respond(folders);
}

module.exports = {noteTemplate, createNoteEntry, createNoteInFolderEntry, getAllFolderEntries}