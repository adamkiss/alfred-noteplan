package commands

import (
	"fmt"
	"time"

	"github.com/adamkiss/alfred-noteplan/utils"
)

func HandleTest(params []string) {

	start := time.Now()

	str := "+d+m+w+2d"
	fmt.Println(utils.MatchQueryToDate(str))

	fmt.Println(time.Since(start))
}
