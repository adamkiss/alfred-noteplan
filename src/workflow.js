const config = require('./config')
const { getAllFolderEntries } = require('./create')
const { ensureWorkflowDatabaseExists } = require('./database')
const {refreshAction, refreshResponse} = require('./refresh')
const search = require('./search')

// 0 - bin, 1 - workflow, 2 - query
const $bin = process.argv[0]
const $query = process.argv[2]

// Ensure database exists
ensureWorkflowDatabaseExists()

// Special cases
if ($query === '-r') { refreshResponse($bin); }
if ($query === '--refresh') { return refreshAction($bin); }
if ($query.startsWith('New: ')) { return getAllFolderEntries($query.split('New: ').pop())}

// Else search
search($query)