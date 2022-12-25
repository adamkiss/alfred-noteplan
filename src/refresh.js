const {existsSync} = require('fs')
const { createWorkflowDatabase, getWorkflowDatabasePath } = require('./database')
const respond = require('./respond')

// Refresh response to 'n -r'
module.exports.refreshResponse = $bin => {
    return respond([{
        title: "Refresh the database",
        subtitle: "Includes a setup, if needed",
        arg: `${$bin} --refresh`
    }])
}

// Refresh action, called by alfred as `$binary --refresh`
module.exports.refreshAction = function ($bin) {
    if (!existsSync(getWorkflowDatabasePath())) {
        console.log('c')
        createWorkflowDatabase();
    }
    
    console.log('Refreshed');
}