const { createAddNoteUrl } = require("./noteplan-urls")

const noteTemplate = title => `---
title: ${title}
date: {date:short}
---

`

const createNoteEntry = title => ({
    title: `Create "${title}"`,
    subtitle: `Creates a new note • You'll be asked for location in the next step`,
    icon: {path: 'icons/icon-create.icns'},
    arg: `--create ${title}`
})

const createNoteInFolderEntry = (title, folder) => ({
    title: folder,
    subtitle: `Creates note '${title}' in folder '${folder}'`,
    icon: {path: 'icons/icon-create.icns'},
    arg: createAddNoteUrl({title, folder, body: noteTemplate(title)})
})

module.exports = {noteTemplate, createNoteEntry, createNoteInFolderEntry}