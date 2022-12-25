/**
 * CONFIG with some dev shortcuts
 */
module.exports = {
    // set cwd to env
    cwd: process.env.DEV ?? process.cwd(),
    
    // get alfred np_root setting or default to SetApp version for testing
    np_root: process.env.user_np_root ?? '/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp'
}