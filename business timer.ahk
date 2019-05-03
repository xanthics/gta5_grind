#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

; upper left x, y location
overlay_x := 1 ; 2561
overlay_y := 100

; timers to create.  key, Name, tick time(minutes), max count
; supported keys are altnum/, altnum*, altnum-
; / and * will reset count and timer(best for bunker and MC cocaine), - will only reset count(best for nightclub)
; AHK v1 does not like multiline variables
timerarr := [["altnum/", "Bunker", 7, 20],["altnum-", "NC_Cash", 30, 40],["altnum-", "NC_Sport", 40, 100],["altnum-", "NC_Cargo", 70, 50],["altnum-", "NC_Meth", 60, 20],["altnum-", "NC_Coke", 120, 10]]


; Shouldn't need to edit below this line.
last_reset := A_TickCount

maketimers()
SetTimer, update_gta5_clock, 250
return

maketimers()
{
	global
	local idx = 0
	local overlay_color = 000000
	local mytime = A_TickCount
	Gui, Color, %overlay_color%
	Gui, 1:Margin , 0, 0
	Gui, Font, s10 bold, fontin
	For, Each, Row in timerarr
	{
		Row.5 := 0
		Row.6 := mytime + Row.3 * 60000
;		MsgBox % Row.5
		Gui, Add, Text, % "x1 y"idx*15 " w60" " v"Row.2 "1 cc49964 BackgroundTrans", % Row.2
		Gui, Add, Text, % "x60 y"idx*15 " w60 v"Row.2 "2 cc49964 BackgroundTrans", % Row.5 "/" Row.4
		Gui, Add, Text, % "x120 y"idx*15 " w60 v"Row.2 "3 cc49964 BackgroundTrans", % format_elapsed(Row.6 - mytime) ;
		GuiControl, +cGreen, % Row.2 "1"
;		GuiControl, +cGreen, Clock2
		idx += 1
	}
	Gui +lastFound +AlwaysOnTop +ToolWindow -Border -Caption +E0x20 ; E0x20 is clickthrough
	Gui, Show, % "x"overlay_x " y"overlay_y " h"idx*16 " w"180 " NoActivate", Mission Timer
}

format_elapsed(time) {
	time /= 1000
    seconds := mod(floor(time), 60)
    if seconds < 10
        return floor(time/60) ":0" seconds
    return floor(time/60) ":" seconds
}

; Update all business timers
update_gta5_clock:
{
	mytime := A_TickCount
	For, Each, Row in timerarr
	{
		if (Row.5 < Row.4) {
			seconds := Row.6 - mytime
			if (seconds <= 0) {
				Row.5 += 1
				GuiControl,, % Row.2 "2", % Row.5 "/" Row.4
				Row.6 := mytime + Row.3 * 60000
			}
			fmttime := format_elapsed(seconds)
			GuiControl,, % Row.2 "3", %fmttime%
		}
	}
	return
}

; bunker supplies arrive, resets everything
^NumpadDiv::
{
	mytime := A_TickCount
	For, Each, Row in timerarr
	{
		if (Row.1 == "altnum/") {
			Row.6 := mytime + Row.3 * 60000
			Row.5 := 0
			GuiControl,, % Row.2 "2", % Row.5 "/" Row.4
		}
	}
	return
}
; Bunker supplies ordered, resets everything and adds the 10 minute timer
^NumpadMult::
{
	mytime := A_TickCount
	For, Each, Row in timerarr
	{
		if (Row.1 == "altnum/") {
			Row.6 := mytime + (Row.3 + 10) * 60000
			Row.5 := 0
			GuiControl,, % Row.2 "2", % Row.5 "/" Row.4
		}
	}
	return
}
; nightclub delivery
^NumpadSub::
{
	mytime := A_TickCount
	For, Each, Row in timerarr
	{
		if (Row.1 == "altnum-") {
			Row.5 := 0
			GuiControl,, % Row.2 "2", % Row.5 "/" Row.4
		}
	}
	
	return
}
; start zoning
^NumpadAdd::
{
	SetTimer, update_gta5_clock, OFF
	return
}
; end zoning
^NumpadEnter::
{
	SetTimer, update_gta5_clock, 250
	mytime := A_TickCount
	For, Each, Row in timerarr
	{
		Row.6 := mytime + Row.3 * 60000
		fmttime := format_elapsed(Row.3 * 60000)
		GuiControl,, % Row.2 "3", %fmttime%
	}
	return
}
