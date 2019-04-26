#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
overlay_x := -151 ;2561
overlay_y := 100

; average load time in seconds between missions
loadtime := 60

; Shouldn't need to edit below this line.
last_reset := A_TickCount

overlay_color = 000000
Gui, Color, %overlay_color%
Gui, 1:Margin , 0, 0
Gui, Font, s10 bold, fontin
Gui, Add, Text, x0 y0 w100 vClock cc49964 BackgroundTrans, 0:00
Gui, Add, Text, x0 y15 w100 vClock2 cc49964 BackgroundTrans, 0:00
Gui +lastFound +AlwaysOnTop +ToolWindow -Border -Caption +E0x20 ; E0x20 is clickthrough
;WinSet, TransColor, %overlay_color% 255
Gui, Show, x%overlay_x% y%overlay_y% h32 w75 NoActivate, Mission Timer

format_elapsed(time) {
    seconds := mod(floor(time), 60)
    if seconds < 10
        return floor(time/60) ":0" seconds
    return floor(time/60) ":" seconds
}

; function that calculates the mission payout given seconds taken and loadtime between missions
cal_cash(seconds) {
	global loadtime
	if (seconds <= 60) {
		return 6 / (seconds + loadtime)
	}
	else if (seconds <= 120) {
		return 15 / (seconds + loadtime)
	}
	else if (seconds <= 180) {
		return 30 / (seconds + loadtime)
	}
	else if (seconds <= 240) {
		return 45 / (seconds + loadtime)
	}
	else if (seconds <= 360) {
		return 60 / (seconds + loadtime)
	}
	else if (seconds <= 480) {
		return 72 / (seconds + loadtime)
	}
	else if (seconds <= 600) {
		return 84 / (seconds + loadtime)
	}
	else if (seconds <= 720) {
		return 96 / (seconds + loadtime)
	}
	else if (seconds <= 900) {
		return 108 / (seconds + loadtime)
	}
	else {
		return 120 / (seconds + loadtime)
	}

}

; Find our initial best turnin time
find_max() {
	i := 0
	max := 0
	c := 0
	
	while (c < 902) {
		val := cal_cash(c)
		if (val > max) {
			i := c
			max := val
		}
		c += 1
	}
	return i
}

find_edge(seconds, nexttime) {
	global loadtime
	i := 0
	max := 0
	c := seconds
	next_cash := cal_cash(nexttime)
	
	while (c < nexttime) {
		val := cal_cash(c)
		if (val > next_cash) {
			i := c
			max := val
		}
		else {
			return i
		}
		c += 1
	}
	return i
}

first_max := find_max()


;SetTimer, update_gta5_clock, 500
SetTimer, update_gta5_clock2, 500

; search for an image, if it exists reset timer
update_gta5_clock:
{
	CoordMode, Pixel, Screen
	ImageSearch, foundX, foundY, 0, 1100, 600, 1300, *Trans00FF00 *40 mcs.bmp
	if (ErrorLevel == 0) {
		last_reset := A_TickCount
	}
	return
}

; current mission time and
; how long to wait or how long you have
update_gta5_clock2:
{
	global first_max
	seconds := (A_TickCount - last_reset) / 1000, seconds
	fmttime := format_elapsed(seconds)
	GuiControl,, Clock, %fmttime%

	t := first_max

	if (seconds > first_max) {
		if (seconds <= 60) {
			t := 61
		}
		else if (seconds <= 120) {
			t := 121
		}
		else if (seconds <= 180) {
			t := 181
		}
		else if (seconds <= 240) {
			t := 241
		}
		else if (seconds <= 360) {
			t := 361
		}
		else if (seconds <= 480) {
			t := 481
		}
		else if (seconds <= 600) {
			t := 601
		}
		else if (seconds <= 720) {
			t := 721
		}
		else if (seconds <= 900) {
			t := 901
		}
		else {
			GuiControl, +cGreen, Clock2
			GuiControl,, Clock2, Turn in Now
			return
		}
		time := find_edge(seconds, t)
	}
	else {	
		time := 0
	}
	
	if ( seconds < time ) {
		fmttime := format_elapsed(time - seconds)
		GuiControl, +cGreen, Clock2
		GuiControl,, Clock2, Turn in %fmttime%
	}
	else {
		fmttime := format_elapsed(t - seconds)
		GuiControl, +cRed, Clock2
		GuiControl,, Clock2, Wait %fmttime%
	}
	return
}

 
NumpadDiv::
{
	last_reset := A_TickCount
	return
}
