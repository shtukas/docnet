package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview" // https://pkg.go.dev/github.com/rivo/tview
)

type DisplayConfiguration struct {
	application  *tview.Application
	grid         *tview.Grid
	mainElement  tview.Primitive
	commandField tview.Primitive
	focus        tview.Primitive
}

func makeListFromStrings(displayConfig DisplayConfiguration) *tview.List {
	list := tview.NewList().
		ShowSecondaryText(false).
		AddItem("List item 1", "", 0, func() {
			displayConfig.application.SetFocus(displayConfig.commandField)
		}).
		AddItem("List item 2", "", 0, func() {
			displayConfig.application.SetFocus(displayConfig.commandField)
		}).
		AddItem("List item 3", "", 0, func() {
			displayConfig.application.SetFocus(displayConfig.commandField)
		}).
		AddItem("List item 4", "", 0, func() {
			displayConfig.application.SetFocus(displayConfig.commandField)
		})
	return list
}

func updateGridContents(grid *tview.Grid, mainElement tview.Primitive, commandField tview.Primitive) {
	grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(mainElement, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)
}

func renderDisplayConfiguration(displayConfig DisplayConfiguration) {
	displayConfig.grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(displayConfig.mainElement, 0, 0, 1, 1, 0, 0, false).
		AddItem(displayConfig.commandField, 1, 0, 1, 1, 0, 0, true)
	displayConfig.application.SetFocus(displayConfig.focus)
}

func makeTextViewFromStrings(strs []string, selectedLineNumber int) *tview.TextView {
	// text := strings.Join(strs[:], "\n")

	text := ""
	for i, v := range strs {
		separator := "\n"
		if i == 0 {
			separator = ""
		}
		if i == selectedLineNumber {
			v = "[green:#808080:b]" + v + " (this one) [-:-:-]"
		}
		text = text + separator + v
	}

	return tview.NewTextView().
		SetDynamicColors(true).
		SetTextAlign(tview.AlignLeft).
		SetText(text)
}

func main() {

	app := tview.NewApplication()
	grid := tview.NewGrid()
	textView1 := makeTextViewFromStrings([]string{"Hello World"}, -1)
	commandField := tview.NewInputField()
	displayConfig := DisplayConfiguration{app, grid, textView1, commandField, commandField}

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
				list := makeListFromStrings(displayConfig)
				displayConfig.mainElement = list
				displayConfig.focus = list
				renderDisplayConfiguration(displayConfig)
				return
			}
			textView1.SetText(text)
			displayConfig.mainElement = textView1
			displayConfig.focus = commandField
			renderDisplayConfiguration(displayConfig)
		}).
		SetDoneFunc(func(key tcell.Key) {

		})

	renderDisplayConfiguration(displayConfig)

	app.
		SetRoot(grid, true).
		SetFocus(grid)

	if err := app.Run(); err != nil {
		panic(err)
	}
}
