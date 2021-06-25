package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview" // https://pkg.go.dev/github.com/rivo/tview
)

func makeListFromStringsWithInputFieldEcho(application *tview.Application, inputField *tview.InputField, strs []string) *tview.List {
	list := tview.NewList().
		ShowSecondaryText(false)
	for _, str := range strs {
		list.AddItem(str, "", 0, func() {
			inputField.SetText(str) // Todo: has no effect
			application.SetFocus(inputField)
		})
	}
	return list
}

func renderScreenText(application *tview.Application, grid *tview.Grid, textView *tview.TextView, commandField *tview.InputField) {
	grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(textView, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)
	application.SetFocus(textView)
}

func renderScreenList(application *tview.Application, grid *tview.Grid, list *tview.List, commandField *tview.InputField) {
	grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(list, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)
	application.SetFocus(list)
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

	// ----------------------------------------------
	// Elements

	application := tview.NewApplication()
	grid := tview.NewGrid()
	textView1 := makeTextViewFromStrings([]string{"Hello World"}, -1)
	commandField := tview.NewInputField()

	// ----------------------------------------------
	// Elements behaviour

	commandField.
		SetLabel("> ").
		SetFieldWidth(0).
		SetFieldBackgroundColor(tcell.NewHexColor(0)).
		SetChangedFunc(func(text string) {
			if text == "exit" {
				application.Stop()
			}
		}).
		SetDoneFunc(func(key tcell.Key) {
			text := commandField.GetText()
			list := makeListFromStringsWithInputFieldEcho(application, commandField, []string{"Pascal", "default", text})
			renderScreenList(application, grid, list, commandField)
		})

	// ----------------------------------------------
	// Initialization

	grid.
		Clear().
		SetRows(-1, 1).
		SetColumns(-1).
		SetBorders(true).
		AddItem(textView1, 0, 0, 1, 1, 0, 0, false).
		AddItem(commandField, 1, 0, 1, 1, 0, 0, true)

	application.
		SetRoot(grid, true).
		SetFocus(commandField)

	if err := application.Run(); err != nil {
		panic(err)
	}
}
