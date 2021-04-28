package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
)

func main() {

	app := tview.NewApplication()

	main := tview.NewTextView().
			SetTextAlign(tview.AlignLeft).
			SetText("Hello World")

	commandField := tview.NewInputField().
		SetLabel("> ").
		SetFieldWidth(0).
		SetFieldBackgroundColor(tcell.NewHexColor(0)).
		SetChangedFunc(func(text string) {
			
		}).
		SetDoneFunc(func(key tcell.Key) {

		})

	grid := tview.NewGrid().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(main, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)

	if err := app.SetRoot(grid, true).SetFocus(grid).Run(); err != nil {
		panic(err)
	}
}