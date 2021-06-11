package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview" // https://pkg.go.dev/github.com/rivo/tview
)

func main() {

	app := tview.NewApplication()

	mainView := tview.NewTextView().
		SetTextAlign(tview.AlignLeft).
		SetText("Hello World")

	commandField := tview.NewInputField().
		SetLabel("> ").
		SetFieldWidth(0).
		SetFieldBackgroundColor(tcell.NewHexColor(0)).
		SetChangedFunc(func(text string) {
			if text == "exit" {
				app.Stop()
				return
			}
			mainView.SetText(text)
		}).
		SetDoneFunc(func(key tcell.Key) {

		})

	grid := tview.NewGrid().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(mainView, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)

	if err := app.SetRoot(grid, true).SetFocus(grid).Run(); err != nil {
		panic(err)
	}
}
