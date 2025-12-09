package utils

import (
	"regexp"
	"strconv"
	"time"

	"github.com/adamkiss/alfred-noteplan/utils/isoweek"
)

type QueryParser struct {
	Regexp      *regexp.Regexp
	MatchToDate func([]string) time.Time
	NoteType    NoteType
}

func CreateQueryParser(
	re string,
	datefunc func([]string) time.Time,
	nt NoteType,
) QueryParser {
	return QueryParser{
		Regexp:      regexp.MustCompile(re),
		MatchToDate: datefunc,
		NoteType:    nt,
	}
}

func zerodate(y int, m time.Month, d int) time.Time {
	return time.Date(y, m, d, 0, 0, 0, 0, time.Local)
}

var FreeformInnerPattern = regexp.MustCompile(`([-+]?)\s*(\d*)\s*(d|w|m|q|y)`)

var QueryParsers = []QueryParser{
	// exact ymd/Ymd/y-m-d/Y-m-d
	CreateQueryParser(
		`^(\d\d|\d\d\d\d)[-\/](\d{1,2})[-\/](\d{1,2})$`,
		func(m []string) time.Time {
			year, _ := strconv.Atoi(m[1])
			if year < 100 {
				year += 2000
			}
			month, _ := strconv.Atoi(m[2])
			day, _ := strconv.Atoi(m[3])
			return zerodate(year, time.Month(month), day)
		},
		NoteTypeDaily,
	),

	// m/d, m/d/y, m/d/Y
	CreateQueryParser(
		`^(\d{1,2})/(\d{1,2})(?:/(\d{2}|\d{4}))?$`,
		func(m []string) time.Time {
			var month, day int
			month, _ = strconv.Atoi(m[1])
			day, _ = strconv.Atoi(m[2])
			year := time.Now().Year()
			if m[3] != "" {
				year, _ = strconv.Atoi(m[3])
				if year < 100 {
					year += 2000
				}
			}
			return zerodate(year, time.Month(month), day)
		},
		NoteTypeDaily,
	),

	// exact d.m.?yy?yy?
	CreateQueryParser(
		`^(\d{1,2})[.](\d{1,2})(?:[.](\d{2}|\d{4}))?$`,
		func(m []string) time.Time {
			day, _ := strconv.Atoi(m[1])
			month, _ := strconv.Atoi(m[2])
			year := time.Now().Year()
			if m[3] != "" {
				year, _ = strconv.Atoi(m[3])
				if year < 100 {
					year += 2000
				}
			}
			return zerodate(year, time.Month(month), day)
		},
		NoteTypeDaily,
	),

	// exact dm with space
	CreateQueryParser(
		`^(\d{1,2}) +(\d{1,2})$`,
		func(m []string) time.Time {
			day, _ := strconv.Atoi(m[1])
			month, _ := strconv.Atoi(m[2])
			return zerodate(time.Now().Year(), time.Month(month), day)
		},
		NoteTypeDaily,
	),

	// daily shift: freeform
	CreateQueryParser(
		`^([-+]?\s*\d*\s*[dwmqy]{1})+$`,
		func(m []string) time.Time {
			now := time.Now()
			// parse freeform
			parts := FreeformInnerPattern.FindAllStringSubmatch(m[0], -1)
			if parts == nil {
				return now
			}
			for _, part := range parts {
				add := 1
				if part[1] == "-" {
					add = -1
				}
				num := 1
				if part[2] != "" {
					num, _ = strconv.Atoi(part[2])
				}
				switch part[3] {
				case "d":
					now = now.AddDate(0, 0, add*num)
				case "w":
					now = now.AddDate(0, 0, add*num*7)
				case "m":
					now = now.AddDate(0, add*num, 0)
				case "q":
					now = now.AddDate(0, add*num*3, 0)
				case "y":
					now = now.AddDate(add*num, 0, 0)
				}
			}
			return zerodate(now.Year(), now.Month(), now.Day())
		},
		NoteTypeDaily,
	),

	// week: exact, or (+/-)n weeks
	CreateQueryParser(
		`^w\s*[-+]?\s*(\d+)$`,
		func(match []string) time.Time {
			shift := match[1] != ""
			weeks, _ := strconv.Atoi(match[2])
			iy, iw := time.Now().Year(), weeks
			var y, d int
			var m time.Month

			if shift {
				add := 1
				if match[1][0] == '-' {
					add = -1
				}
				_, ciw := time.Now().Local().ISOWeek()
				iw = ciw + add*weeks
			}

			y, m, d = isoweek.StartDate(iy, iw)

			return zerodate(y, m, d)
		},
		NoteTypeWeekly,
	),

	// month: exact, or (+/-)n months
	// quarter: exact, or (+/-)n quarters
	// year: exact, or (+/-)n years
}

func MatchQueryToDate(query string) (time.Time, NoteType, bool) {
	for _, parser := range QueryParsers {
		if matches := parser.Regexp.FindStringSubmatch(query); matches != nil {
			return parser.MatchToDate(matches), parser.NoteType, true
		}
	}
	return time.Time{}, NoteTypeNote, false
}
