BIN="./noteplan_fts-$(uname -m)"

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

case "$1" in
    "!")
        info
        ;;
    "!!")
        $BIN debug
        ;;
    "!r")
        $BIN refresh
        ;;
    "!rf")
        $BIN refresh-force
        ;;
esac