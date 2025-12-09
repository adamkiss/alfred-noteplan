package utils

import (
	"fmt"
	"time"
)

type NoteType string

const (
	NoteTypeNote      NoteType = "Note"
	NoteTypeDaily     NoteType = "Daily"
	NoteTypeWeekly    NoteType = "Weekly"
	NoteTypeMonthly   NoteType = "Monthly"
	NoteTypeQuarterly NoteType = "Quarterly"
	NoteTypeYearly    NoteType = "Yearly"
)

func (nt NoteType) GetName(t time.Time) string {
	switch nt {
	case NoteTypeDaily:
		return t.Format("2006-01-02")
	case NoteTypeWeekly:
		year, week := t.ISOWeek()
		return fmt.Sprintf("%d-W%02d", year, week)
	case NoteTypeMonthly:
		return t.Format("2006-01")
	case NoteTypeQuarterly:
		month := (t.Month()-1)/3*3 + 1
		return fmt.Sprintf("%d-Q%d", t.Year(), (month-1)/3+1)
	case NoteTypeYearly:
		return fmt.Sprintf("%d", t.Year())
	default:
		panic("GetName not supported for NoteType: " + string(nt))
	}
}

func (nt NoteType) Folder() string {
	switch nt {
	case NoteTypeNote:
		return "Notes"
	default:
		return "Calendar"
	}
}
