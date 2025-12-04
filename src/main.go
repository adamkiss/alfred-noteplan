package main

import (
	"fmt"
	"os"

	"github.com/adamkiss/alfred-noteplan/commands"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("MISSING COMMAND")
		fmt.Println()
		commands.HandleUsage()
		return
	}

	command := os.Args[1]
	var params []string
	if len(os.Args) == 2 {
		params = []string{}
	} else {
		params = os.Args[2:]
	}

	switch command {
	case "test":
		commands.HandleTest(params)
	case "help":
		commands.HandleHelp()
	default:
		fmt.Println("UNKNOWN COMMAND:", command)
		fmt.Println()
		commands.HandleUsage()
	}
}
