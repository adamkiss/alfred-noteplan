package utils

import (
	"testing"
	"time"
)

func TestFirstQueryParser_ExactYMD(t *testing.T) {
	tests := []struct {
		name      string
		input     string
		wantYear  int
		wantMonth time.Month
		wantDay   int
		wantMatch bool
	}{
		// Full 4-digit year with dashes
		{"yyyy-mm-dd", "2024-01-15", 2024, time.January, 15, true},
		{"yyyy-mm-dd single digit month/day", "2024-1-5", 2024, time.January, 5, true},

		// Full 4-digit year with slashes
		{"yyyy/mm/dd", "2024/01/15", 2024, time.January, 15, true},
		{"yyyy/mm/dd single digit", "2024/1/5", 2024, time.January, 5, true},

		// 2-digit year with dashes
		{"yy-mm-dd", "24-01-15", 2024, time.January, 15, true},
		{"yy-mm-dd single digit", "24-1-5", 2024, time.January, 5, true},

		// 2-digit year with slashes
		{"yy/mm/dd", "24/01/15", 2024, time.January, 15, true},
		{"yy/mm/dd single digit", "24/1/5", 2024, time.January, 5, true},

		// Edge cases
		{"end of year", "2024-12-31", 2024, time.December, 31, true},
		{"leap year date", "2024-02-29", 2024, time.February, 29, true},
		{"year 2000", "00-01-01", 2000, time.January, 1, true},
		{"year 2099", "99-12-31", 2099, time.December, 31, true},

		// Non-matching cases
		{"no match - text", "abc", 0, 0, 0, false},
		{"no match - incomplete", "2024-01", 0, 0, 0, false},
		{"no match - 3 digit year", "202-01-15", 0, 0, 0, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			date, noteType, matched := MatchQueryToDate(tt.input)

			if matched != tt.wantMatch {
				t.Errorf("MatchQueryToDate(%q) matched = %v, want %v", tt.input, matched, tt.wantMatch)
				return
			}

			if !tt.wantMatch {
				return
			}

			if noteType != NoteTypeDaily {
				t.Errorf("MatchQueryToDate(%q) noteType = %v, want NoteTypeDaily", tt.input, noteType)
			}

			if date.Year() != tt.wantYear {
				t.Errorf("MatchQueryToDate(%q) year = %d, want %d", tt.input, date.Year(), tt.wantYear)
			}

			if date.Month() != tt.wantMonth {
				t.Errorf("MatchQueryToDate(%q) month = %v, want %v", tt.input, date.Month(), tt.wantMonth)
			}

			if date.Day() != tt.wantDay {
				t.Errorf("MatchQueryToDate(%q) day = %d, want %d", tt.input, date.Day(), tt.wantDay)
			}
		})
	}
}
