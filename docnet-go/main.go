package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview" // https://pkg.go.dev/github.com/rivo/tview
)

func updateGridContents(grid *tview.Grid, mainElement tview.Primitive, commandField tview.Primitive) {
	grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(mainElement, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)
}

func main() {

	app := tview.NewApplication()

	grid := tview.NewGrid()

	textView := tview.NewTextView().
		SetTextAlign(tview.AlignLeft).
		SetText("Hello World")

	list := tview.NewList().
		AddItem("List item 1", "Some explanatory text", 'a', nil).
		AddItem("List item 2", "Some explanatory text", 'b', nil).
		AddItem("List item 3", "Some explanatory text", 'c', nil).
		AddItem("List item 4", "Some explanatory text", 'd', nil).
		AddItem("Quit", "Press to exit", 'q', func() {
			app.Stop()
		})

	commandField := tview.NewInputField()

	commandField.
		SetLabel("> ").
		SetFieldWidth(0).
		SetFieldBackgroundColor(tcell.NewHexColor(0)).
		SetChangedFunc(func(text string) {
			if text == "exit" {
				app.Stop()
				return
			}
			if text == "list" {
				updateGridContents(grid, list, commandField)
				return
			}
			updateGridContents(grid, textView, commandField)
			textView.SetText(text)
		}).
		SetDoneFunc(func(key tcell.Key) {

		})

	updateGridContents(grid, textView, commandField)

	if err := app.SetRoot(grid, true).SetFocus(grid).Run(); err != nil {
		panic(err)
	}
}
