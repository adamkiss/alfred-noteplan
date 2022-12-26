const createNote = title => `---
title: ${title}
date: {date:short}
---

`

const noteEntry = title => ({
    title: `Create "${title}"`,
    subtitle: `Creates a new note • You'll be asked for location in the next step`,
    icon: {path: 'icons/icon-create.icns'}
})

module.exports = {createNote, noteEntry}