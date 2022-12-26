const createUrl = (method = 'addNote', params = {}) => {
    const url = [
        'noteplan://x-callback-url/',
        method,
        '?',
        ...Object.keys(params).map(k => `${k}=${params[k]}`)
    ].join('')
    return encodeURI(url)
}

/**
 * Generates an openNote callback for the calendar type notes
 * 
 * @param {String} filename format `YYYYmmdd.md` or alternative
 * @param {Boolean} sameWindow use the already open noteplan window?
 * @returns string
 */
const createCalendarNoteUrl = (filename, sameWindow = true) => {
    return createUrl('openNote', {
        noteDate: filename.split('.').shift(),
        useExistingSubWindow: sameWindow ? 'yes' : 'no'
    })
}

/**
 * Generates an openNote callback for the note notes
 * 
 * @param {String} filename format `YYYYmmdd.md` or alternative
 * @param {Boolean} sameWindow use the already open noteplan window?
 * @returns string
 */
const createOpenNoteUrl = (filename, sameWindow = true) => {
    return createUrl('openNote', {
        filename: filename,
        useExistingSubWindow: sameWindow ? 'yes' : 'no'
    })    
}
const createAddNoteUrl = ({folder, body}) => {
    return createUrl('addNote', {
        text: body,
        folder,
        useExistingSubWindow: 'yes'
    })
}

module.exports = {
    createUrl,
    createCalendarNoteUrl, createOpenNoteUrl,
    createAddNoteUrl
}