const config = require('./config')
const {refreshAction, refreshResponse} = require('./refresh')

// 0 - bin, 1 - workflow, 2 - query
const $bin = process.argv[0]
const $query = process.argv[2]

// Special cases
if ($query === '-r') { refreshResponse($bin); }
if ($query === '--refresh') { return refreshAction($bin); }
if ($query.startsWith('--create ')) {}

// Else search