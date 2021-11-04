﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; Preliminaries;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
Global UserProfile ; Make userprofile a global variable
EnvGet, UserProfile, UserProfile ; Get userprofile from system variables

; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Windows workflow
;;;; Author: Miika Mäki

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 0. Quick Guide
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; # = Win-key
;;;; <#= Left win-key
;;;; + = Shift
;;;; ^ = Ctrl
;;;; ! = Alt
;;;; <!= Left Alt-key
;;;; $ = will not fire any key but will prevent the hotkey itself from firing
;;;;
;;;; Complete Guide for hotkeys:	https://autohotkey.com/docs/Hotkeys.htm
;;;;                    	 		https://autohotkey.com/docs/KeyList.htm
;;;;
;;;; Syntax Highlighting 
;;;; & Auto-Completion:				https://www.autohotkey.com/boards/viewtopic.php?f=7&t=50		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;1.1 Roar - or The "Run or Activate Robust" function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Many parts owe to Learning One(2009) and seperman(2017):

roar(ID_1,TARGET_1="",EX_TITLE:="",EX_AHK:="", TARGET_2:="",ID_2:="",Mode:=1,Parambox:=0)
;-------------------------------------------------------------------------------
;
; Toggles, Activates, Minimizes, Restores, or Runs program windows based on the whether the applications are running, how many windows there are and what state they are at
;
;ID_1		= 1st critria to identify an existing window
;TARGET_1	= executable program or a path to it
;EX_TITLE	= exclude windows with titles that start with a given string
;EX_AHK		= exclude processes (eg. ahk_exe firefox.ex) or strings in a window
;TARGET_2	= alternative path to an excecutable file (if for example the paths are different in different machines you use)
;ID_2 	 	= 2nd criteria to identify an existing window (adds windows to the group)
;Mode 		= Mode of SetTitleMatchMode
;ParamBox	= Show parameter values (1/0)
;-------------------------------------------------------------------------------
{
;Creating groups with a uniques names;
	SetTitleMatchMode, %Mode%
	unique_group=%A_DDD%%A_YDay%%A_Hour%%A_Min%%A_MSec%
	unique_group1=% unique_group "1"
	unique_group2=% unique_group "2"
	GroupAdd, %unique_group1%, %ID_1%											;first criterion to include
	if (ParamBox==1)
		msgbox, ------Parameters-------- `n ID_1 `t`t %ID_1% `n TARGET_1 `t %TARGET_1% `n EX_TITLE  `t %EX_TITLE% `n EX_AHK `t %EX_AHK% `n TARGET_2 `t %TARGET_2% `n ID_2 `t`t %ID_2% `n mode `t %mode%
	
	if (ID_2 !=""){
		GroupAdd, %unique_group1%, %ID_2%
		;MsgBox, ID_2 not empty
	} 
	extitle_str:= % EX_TITLE
	GroupAdd, %unique_group2%,ahk_group %unique_group1%, , ,%extitle_str%		;exclude based on title
	GroupAdd, %unique_group%,ahk_group %unique_group2%, , , , %EX_AHK%			;exclude based on content (ahk_process)
; checking if the windows is active
	if WinActive("ahk_group" . unique_group) {
		WinGet, num, count,ahk_group %unique_group%
		;MsgBox, %num% ;;;
		; if only one window minimize or maximize
		if (num==1) || (ID_1=="ahk_exe spotify.exe") || (ID_1=="ahk_exe MobaXterm.exe")		; for some reason > 1 windows identified for these apps, this is a workaround
			{
			WinGet,WinState,MinMax,ahk_group %unique_group%
			If WinState = -1
				{
				;msgbox, restoring ;;;
				WinRestore ;;; was WinMaximize	
				}
			 else 
				{
				;msgbox, minimize
				WinMinimize
				}
			} 
		; if multiple windows, toggle
		else 
		{
		WinGet, List, List, ahk_group %unique_group%
		Loop, % List
			{
				index := List - A_Index + 1
				WinGet, State, MinMax, % "ahk_id " List%index%
				if (State <> -1)
				{
					WinID := List%index%
					break
				}
			}
		WinActivate, % "ahk_id " WinID
		return
		}
	}
; activate window if exists but not active
	else if WinExist("ahk_group" . unique_group) {
		;msgbox, activating inactive ;;;
		WinActivate
	}
; if window does not exist, run the target
	else
	;msgbox, running target
	{	
		try {
			If InStr(TARGET_1, "\")==1 {  
				;MsgBox, % UserProfile . TARGET_2
				Run, % UserProfile . TARGET_1
			} Else {
				;msgbox, %TARGET_1%
				Run, %TARGET_1%
			}
		} catch e {
				;MsgBox, Trying to run target_2 ;;;
			If InStr(TARGET_2, "\")==1 {
				;MsgBox, % UserProfile . TARGET_2
				Run, % UserProfile . TARGET_2
				
			} Else 
				;msgbox, %TARGET_2%
				Run, %TARGET_2%
		}
	;MsgBox, waiting ;;;
	WinWait, ahk_group unique_group,,2
	WinActivate, ahk_group unique_group
	;WinMaximize, ahk_group unique_group
	}
	Return
}


;-----------------------------------------------------------------------------------------------------------------------------------------

;Applying Roar to different apps

;1.1.It is recommened – but not a prerequisite – to to pin programs to the taskbar in the following order.
; (1 Stata) 
; (2 Outlook)
; ...The hotkeys will work anyway but the build-in function Win + (1 or 2) works quite nicely together with...
; ...the hotkeys I have assigned for Stata and Outlook.




;-----------------------------------------------------------------------------------------
; Chart of hotkeys starting with Left Alt - also those not yet assigned to a programme
;-----------------------------------------------------------------------------------------


;---------------------------------------F1F2...F12HomeEndDelete---------------------------
<!delete::roar("ahk_class TaskManagerWindow", "taskmgr.exe")

;---------------------------------------1234567890---------------------------------------

<!§::roar("ahk_class PPTFrameClass", "powerpnt.exe") ; see also <
<!1::roar("ahk_exe StataSE-64.exe", "C:\Program Files (x86)\Stata15\StataSE-64.exe")
<!2::roar("ahk_exe outlook.exe", "outlook.exe")
;<!3::roar("ahk_exe acrord32.exe","acrord32.exe") ;ADOBE READER
<!3::roar("ahk_exe acrobat.exe","acrobat.exe") ;ADOBE READER
;<!4 - see dep
;<!5
;<!6 - see toggle tooltip
;<!7
;<!8
;<!9 
;<!0 - 
;<!+:: 

;---------------------------------------qwertyuiopå---------------------------------------
<!q::roar("ahk_class XLMAIN", "excel.exe")
<!w::roar("ahk_class OpusApp", "winword.exe") ; WORD
; <!e:: ;- see section 2 for  zotero maneouvers
;<!r - (Quick format citation)
;<!t
<!y::roar("ahk_exe filezilla.exe", "filezilla.exe")
;<!u:: 
<!i::roar("Photos ahk_class ApplicationFrameWindow","ms-photos:",,,,,Mode:=2)
<!o::roar("ahk_exe opera.exe", "opera.exe")
<!p::roar("ahk_exe mspub.exe", "mspub.exe") ; PUBLISHER
<!å::roar("- Paint 3D","ms-paint:",,,,,mode:=2)

;--------------------------------------- asdfghjklöä-----------------------------------------
<!CAPSLOCK::roar("ahk_class MozillaWindowClass", "firefox.exe",EX_TITLE:="Quick Format Citation",EX_AHK:="ahk_exe zotero.exe")
<!a::roar("ahk_class CabinetWClass", "explorer.exe")
<!s::roar("ahk_exe code.exe", "\AppData\Local\Programs\Microsoft VS Code\Code.exe", "Google Keep")
<!d::roar("ahk_exe teams.exe", "\AppData\Local\Microsoft\Teams\Update.exe --processStart Teams.exe")
;<!f
<!g::roar("ahk_class gdkWindowToplevel", "C:\Program Files\GIMP 2\bin\gimp-2.10.exe") ;NB!
;<!ht
<!j::roar("ahk_exe MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
<!k::roar("Snip & Sketch ahk_class ApplicationFrameWindow", "ms-screenclip:?source=QuickActions") ; built in combo #+s:: is a bit faster
<!l::roar("ahk_exe texstudio.exe", "C:\Program Files\texstudio\texstudio.exe",,TARGET_2:="C:\Program Files (x86)\texstudio\texstudio.exe") ; NB!
;<!ö - save as
;<!ä

;---------------------------------------<zxcvbnm,.----------------------------------------
<!SHIFT::roar("ahk_exe chrome.exe", "chrome.exe", "Google Keep")
#IfWinNotExist, Stata
<!<::roar("ahk_class PPTFrameClass", "powerpnt.exe")
#IfWinNotExist
<!z::roar("Zoom ahk_exe Zoom.exe","\AppData\Roaming\Zoom\bin\Zoom.exe" , , , , ID_2:="Room ahk_exe zoom.exe")
<!x::roar("ahk_exe rstudio.exe","rstudio.exe")
;<!c::roar("ahk_exe powershell.exe", "powershell.exe") ; not sure how to execute anaconda powershell
<!c::roar("ahk_exe cmd.exe","cmd.exe",,,"C:\Windows\SysWOW64\cmd.exe") ; not sure how to execute anaconda powershell
<!v::roar("ahk_exe Skype.exe", "Skype.exe")
<!b::roar("Settings ahk_class ApplicationFrameWindow", "ms-settings:bluetooth") ; toggle (all) setting windows or launch bluetooth settings
<!n::roar("ahk_class Notepad", "notepad.exe")
<!m::roar("ahk_class Notepad++", "notepad++.exe")
;<!,
;<!.
;<!-



;---------------------------------------CtrlWinAltSPACE---------------------------------------
<!LCTRL::roar(ID_1:="ahk_exe spotify.exe",TARGET_1:="\AppData\Roaming\Spotify\Spotify.exe", , ,TARGET_2:="\AppData\Local\Microsoft\WindowsApps\Spotify.exe")
<!LWIN::roar("Google Keep", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe --app=https://keep.google.com", , ,TARGET_2:="C:\Program Files\Google\Chrome\Application\chrome.exe --app=https://keep.google.com",mode:=2,ParamBox:=1) ;NB!
;ahk_exe chrome.exe"
<!SPACE::roar("A") ; Active process
;<!-Ralt
;<!-RCtrl
;<!(Arrows)
;---------------------------------------------------------------------------------------------------------------------------------------------------





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 1.2 Working with windows, but not with the ROAR function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "ahk_class ZPContentWndClass"

;Close current window
#IfWinNotActive, Program Manager ;this, and following prevents windows from getting rid of desktop items
#IfWinNotActive, "" 
#IfWinNotActive, ahk_class WorkerW
<!ESC::
SetTitleMatchMode, 1
if Winactive("Zoom") && !Winexist("Zoom Meeting")
    run, taskkill /f /im zoom.exe
Else 
	WinClose A
Return
#IfWinNotActive
 


; Toggle tooltip (same hotkey exits in the tooltip.ahk file)

<!6::
;DetectHiddenWindows, On
SetTitleMatchMode, 3
IfWinNotExist,tooltip.ahk
	try {
		Run, "%UserProfile%\OneDrive\Autohotkey\Useful_material\tooltip.ahk" ;NB!
		Return
	} catch e{
		MsgBox, not implemented yet
		Return
	}
SetTitleMatchMode, 1
Return



;NB!  ; you may just want to delete this
;dep
<!4:: 
if (WinActive("ahk_exe Dep.exe"))
{
WinGet,WinState,MinMax,ahk_exe Dep.exe
If WinState = -1
   WinMaximize
else
   WinMinimize
Return
}
if (WinActive("ahk_exe BlaiseCaseControl.exe") && !WinExist("ahk_exe Dep.exe")) 
{
WinGet,WinState,MinMax, ahk_exe BlaiseCaseControl.exe
If WinState = -1
   WinMaximize
else
   WinMinimize
Return
}
if (WinActive("ahk_exe BlaiseCaseControl.exe") && WinExist("ahk_exe Dep.exe")) 
	{
	WinActivate, ahk_exe Dep.exe
	Return
	}
else if (WinExist("ahk_exe Dep.exe") && WinExist("ahk_exe BlaiseCaseControl.exe"))
	{
    	WinActivate, ahk_exe Dep.exe
	Return
	}
else if WinExist("ahk_exe BlaiseCaseControl.exe")
	Winactivate
else
{	
	Run, "C:\ProgramData\CentERdata\SHARE_CASE_CTRL_W9_2\casectrl\BlaiseCaseControl.exe",,,OutputVarPID ; OBS!
	WinWait, ahk_pid %OutputVarPID%
	WinActivate, ahk_pid %OutputVarPID%
	WinMaximize, ahk_pid %OutputVarPID%
}
Return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;2. General windows, Zotero, Word & other microsoft applications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; 2.0 Simple typing

;;;;;;;;;;;;
; email formalities

;formal tone
<^<!o::
Send,I hope this message finds you well{.}{Enter}{Enter}{Enter}{Enter}
Send,Wishing you a great day ahead.{Enter}{Enter}
Send,Kind regards{,}{Enter}{Up}{Up}{Up}{Up}{Up}
Return

;informal tone
<^<!i::
Send,I hope your day is off to a good start{.}{Enter}{Enter}{Enter}{Enter}
Send,Have a good one{!}{Enter}{Enter}
Send,Take care{,}{Enter}{Up}{Up}{Up}{Up}{Up}
Return

; Matrix multiplication in Rstudio - shorcut for %*%
#IfWinActive ahk_exe rstudio.exe
<^'::
Send,{SHIFT DOWN}5'5{SHIFT UP}
Return
#IfWinActive


;En dash
<#n::
Send,–
Return

;Em dash
<#m::
Send,—
Return

;Larger and smaller than with an american keyboard with Scandinavian settings..

/*
#,::
Send, <
Return


#.::
Send, >
Return
*/








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;2.1 plainpaste microsoft office
#If (WinActive("ahk_exe outlook.exe") or WinActive("ahk_exe winword.exe"))
$^$+$v::
Send, {Control down}{Alt down}v{Control up}{Alt up}{pause}{pause}{pause}{pause}{pause}{down}{pause}{down}{pause}{down}{pause}{down}{pause}{enter}
Return
#IfWinActive

#IfWinActive ahk_exe powerpnt.exe
$^$+$v::
Send, {Control down}{Alt down}v{Control up}{Alt up}{pause}{pause}{pause}{pause}{pause}{tab}{pause}{down}{down}{pause}{enter}
Return
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2.2 Saving references to Zotero in firefox and chrome and other zotero functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Run or Activate Zotero and quick format citation
<!e:: 
if (WinActive("Zotero") && WinExist("Quick Format Citation"))
	{
	WinActivate, Quick Format Citation
	Return
	}
else if (WinActive("Zotero") && !WinExist("Quick Format Citation"))
	{
	WinGet,WinState,MinMax,ahk_exe zotero.exe
	If WinState = -1
	   WinMaximize
	else
	   WinMinimize
	Return
	}
else if (WinExist("Zotero") && WinExist("Quick Format Citation"))
{
	WinGet, List, List, Zotero
	Loop, % List
	{
		index := List - A_Index + 1
		WinGet, State, MinMax, % "ahk_id " List%index%
		if (State <> -1)
		{
			WinID := List%index%
			break
		}
	}
	WinActivate, % "ahk_id " WinID
}
else if WinExist("Zotero")
	Winactivate
else
{	
	Run, zotero.exe,,,OutputVarPID
	WinWait, ahk_pid %OutputVarPID%
	WinActivate, ahk_pid %OutputVarPID%
}
Return



; Adding a zotero reference

#IfWinActive, ahk_exe firefox.exe
^+s::
If !Winexist("ahk_exe zotero.exe")
{
	Run, zotero.exe,,,OutputVarPID
	WinWait, ahk_pid %OutputVarPID%
	WinActivate, ahk_exe firefox.exe
}
	Send, {Ctrl down}{Shift down}s{pause}{Shift up}{Ctrl up}
	Return
	
#IfWinActive

#IfWinActive, ahk_exe chrome.exe
^+s::
If Winexist("ahk_exe zotero.exe")
{
Send, {Ctrl down}{Shift down}s{pause}{Shift up}{Ctrl up}
}
else
{	
	Run, zotero.exe,,,OutputVarPID
	WinWait, ahk_pid %OutputVarPID%
	WinActivate, ahk_exe chrome.exe
	Send, {Ctrl down}{Shift down}s{pause}{Shift up}{Ctrl up}
}
Return
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;



;; -  Making word do Zotero related stuff with Ctrl & å - NB! change this to your key of liking

$^å::
If !WinActive("Quick Format Citation") && WinActive("ahk_class OpusApp") && Winexist("Zotero")
{
Send, ^+!j ; ZoteroAddEditCitation. this only works with the word macro (see the VBA script file)
;Send, {Ctrl down}å{Ctrl up} ; ZoteroAddEditCitation. this only works with the word macro (see the VBA script file)
Return
}
If !WinExist("Quick Format Citation") && WinActive("ahk_class OpusApp") && !Winexist("Zotero")
{	
	Run, zotero.exe,,,OutputVarPID
	WinWait, ahk_pid %OutputVarPID%
	WinActivate, ahk_class OpusApp
	Send, ^+!j ; ZoteroAddEditCitation. this only works with the word macro (see the VBA script file)
	;Send, {Ctrl down}å{Ctrl up} ; ZoteroAddEditCitation. this only works with the word macro (see the VBA script file)
	WinWait, Quick Format Citation
    WinActivate, Quick Format Citation
	Return
}
; Activate Quick format citation under certain conditions with Alt & r or suppress the author
If !WinActive("Quick Format Citation") && WinExist("Quick Format Citation") && !WinActive("ahk_class OpusApp")
{
WinActivate, Quick Format Citation
Return
}
;Suppress Author
If WinActive("Quick Format Citation")
{
;old ahk
;send,  {Control down}{down}{Control up}{pause}{pause}{pause}{pause}{pause}{tab}{tab}{tab}{tab}{tab}{space}{pause}{pause}{pause}{enter}{pause}{pause}{enter}

; new, quicker ahk
Send,{Control down}{down}{Control up}
Sleep, 80
Send,{tab}{tab}{tab}{tab}{tab}{space}
Sleep, 80
Send,{enter}
Sleep, 80
Send,{enter}
Return
}
Return


;SetTitleMatchMode, 1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2.3
;WORKAROUNDS FOR WORD THAT DOES NOT HAVE SPECIAL CHARACTERS OR SCANDINAVIAN LETTERS AS wdKeys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NB! You need the VBA code for these to work

;ZoteroAddEditBibliography_SC
; press ctrl + Shift + B (built in in word, no ahk needed)


;Refresh bibliography
;note that word's own ctrl/alt/r works
#IfWinActive, ahk_exe winword.exe
$^+å::
Send, ^+!r
Return
#IfWinActive


;Make paragraph green
; selecthighlight
#IfWinActive, ahk_exe winword.exe
$^ö::
Send, ^+!l
Return
#IfWinActive


;Remove color from paragraph
;selecthighlightR
#IfWinActive, ahk_exe winword.exe
$^ä::
Send, ^+!k
Return
#IfWinActive

;Select paragraph
;Select para
#IfWinActive, ahk_exe winword.exe
$^'::
Send, ^+!p
Return
#IfWinActive

;Select paragraph, make norma
;Normal_selectSC
#IfWinActive, ahk_exe winword.exe
$^¨::
Send, ^+!n
Return

#IfWinActive




SetTitleMatchMode, 1





;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;2.4. VScode, citing and zotero

;Note that you can also assign shortcuts in VS Studio (file->preferences->keyboard shortcuts)

If Winactive("ahk_exe code.exe")
{
	$^$ä::
	If !Winexist("ahk_exe zotero.exe")
	{
		Run, zotero.exe,,,OutputVarPID
		WinWait, ahk_pid %OutputVarPID%
		WinActivate, ahk_exe code.exe
	}
	else if WinExist("Quick Format Citation")
	{
		if Winactive("Quick Format Citation")
		{
			WinGet,WinState,MinMax,Quick Format Citation
			If WinState = -1 ; minimized
			   WinRestore, Quick Format Citation
			else
			   WinMinimize, Quick Format Citation
			Return
		}
		else
		{
			WinActivate, Quick Format Citation
			Return
		}
	}
	Send, {Ctrl down}ä{pause}{Ctrl up} ; Ctrl+ö needs to be activated in vscode shortcuts for "Cite from Zotero"
	Winwait, Quick Format Citation
	WinActivate, Quick Format Citation
	Return
}



#IfWinActive, ahk_exe code.exe
	;adding a citation -Citation picker zotero
	;typing citep and opening quic format citation
	<$^+$ä::
	;Send, \citep{{}{ctrl down}{shift down}{p}{ctrl up}{shift up}{pause}{pause}cite from{pause}{pause}{Enter} ; if ctrl+ä not activated
	Send, \citep{{}{pause}{ctrl down}{ä}{pause}{ctrl up} ; if ctrl+ä activated
	WinWait, Quick Format Citation
	WinActivate, Quick Format Citation
	Return 



	<^!m::
	Send,if __name__ == "__main__":
	Return

#IfWinActive


#IfWinNotActive, ahk_class opusapp

	; typing citep{}
	<^ö::
	Send, \citep{{}
	Return
	
	; typing citet{}
	<$^$+$ö::
	Send, \citet{{}
	Return


#IfWinNotActive



;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;;; 3. OTHER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; X Links
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Learning One(2009) Run application if not active - activate window if active [Accessed Oct 15, 2019] https://autohotkey.com/board/topic/79159-run-application-if-not-active-activate-window-if-active/
;seperman (2017) AutoHotkey_ErgoKeyboard [Accessed Oct 15, 2019] https://gist.github.com/seperman/8064659


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Y. BACKUP CODE;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


<^!q::
MsgBox, This is a test, and it works nicely
Return


/*
#IfWinActive, ahk_exe notepad.exe
$^!ö::
Send, Toimii
Return
#IfWinActive
*/



/*
;Activate or minimize save as
<!ö::

	if WinExist("Save As")
		if WinActive()
			WinMinimize
		else
			WinActivate
	Else
		WinActivate
	return
}
*/
