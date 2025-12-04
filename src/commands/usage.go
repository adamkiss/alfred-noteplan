package commands

import "fmt"

func HandleUsage() {
	fmt.Println("Noteplan for Alfred v4 CLI tool")
	fmt.Println("This tool isn't meant to be run directly, but through alfred workflows, therefore the output is in the Alfred JSON format.")
	fmt.Println()
	fmt.Println("Usage: ancli <command> [options]")
	fmt.Println("Commands:")
	fmt.Println("  search      Search through all of your notes")
	fmt.Println("  codebit     Search through your code bits")
	fmt.Println("  hyperlink   Search through your links")
	fmt.Println("  new         Create a new note")
	fmt.Println("  refresh     Refresh the search index")
	fmt.Println("  usage       Show help information")
}
