# Noteplan Full-text Search for Alfred 2

![OG Social image](social.jpg)

Search, open, and create Noteplan notes with Alfred.

---

## Usage
- `n [Search phrase]` - Full text search. If there isn't any note available, "Create new note" command is the only result
- `n >[date phrase]` - Very simple natural date parser
- `n +[Title of the note]`, `nn [Title of the note]` - Creates a new note, in the folder of your choice
- `n !r` - Refresh note database
- `n !rf` - Force refresh every note in the database

### Natural date parser
- `t … today` - today's note
- `y … yesterday` - yesterday's note
- `tom … tomorrow` - tomorrow's note
- `[-+] [number] [dwm]` - relative date, number of days/weeks/months back and forward. spaces are optional
- `[wmq]` - this week's (month's, quarter's) note
- `[wmq] [-+] [number]` - relative week's (month's, quarter's) note (spaces optional)
- `yr|year` - this year's note
- `yr|year [-+] [number]` - relative year (spaces optional)

## Installation
1. Download and import the workflow
2. Configure it to your taste
    - the most important and required part is the **Noteplan root folder**
    - get it through `Noteplan Options` > `Sync` > `'Advanced' for your active Sync option` > `Open local database`
    - this will open a Finder window
    - in this window, with **nothing selected**, press <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>C</kbd> to copy the pathname 
    - paste that into the workflow import window
3. Run `n ` - macos will warn you that this app is unsigned and you can move it to bin or cancel
4. Open **System Settings** > **Privacy & Security**, scroll down, and click "Allow Anyway"
5. Run `n ` - macos will warn you that this app was downloaded from the internet nad might not be safe. Click 'open'
6. Profit!
7. You can now do a search, date query or add a new note

### Why all the warnings?
To have macos accept your app as safe, the developer needs to cryptographically sign it. That requires a $99/year Apple Developer Program, which I currently don't need for anything else.

### Wasn't there a refresh command?
There was. But with the new version, the workflow refreshes only changed notes since last update, and that's often a tiny number, so the databse is updated every time this workflow is run (with a timeout ~10 seconds, so when you're constructing your query, it runs only on the first letter).

## License
MIT License

## Other software used

---

© 2022 Adam Kiss