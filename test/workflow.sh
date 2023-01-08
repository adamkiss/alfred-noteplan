function info {
cat <<- JSON
{"items": [
    {
        "title": "!! - Debug",
        "subtitle": "Show & copy debugging information (versions, architecture)",
        "valid": false,
        "autocomplete": "!!"
    },
    {
        "title": "!r - Refresh",
        "subtitle": "Refresh the database (since the last update)",
        "valid": false,
        "autocomplete": "!r"
    },
    {
        "title": "!rf - Refresh (Force)",
        "subtitle": "Force full refresh of the database",
        "valid": false,
        "autocomplete": "!r"
    }
]}
JSON
}

function debug {
    $BIN debug
}

BIN="./noteplan_fts-$(uname -m)"

# autocomplete: ! help
[[ "$1" == "!" ]] && info
[[ "$1" == "!!" ]] && debug