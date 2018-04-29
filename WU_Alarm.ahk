; WU_Alarm (C) Peter Korver 2018
#Persistent
#SingleInstance force
LogFile:= "WU_Alarm.log"
FileDelete LogFile
Second := 1000
Minute := 60*Second

OnMessage(0x404,"AHK_NotifyTrayIcon")

Title := "Warframe Utility Alarm"
Menu "Tray", "Tip", Title . "`nday/night`n0h 0m 0s to Dawn"
Menu "Tray", "NoStandard"                  ; remove standard Menu items
Menu "Tray", "Add", "Show &Log", "Log"
Menu "SoundTests", "Add", "Dawn", "Dawn"
Menu "SoundTests", "Add", "Dusk", "Dusk"
Menu "SoundTests", "Add", "Two min. to Night", "AlmostNight"
Menu "SoundTests", "Add", "NightFall", "NightFall"
Menu "SoundTests", "Add", "Two min. to Dawn", "AlmostDawn"
Menu "Tray", "Add" , "&Test", ":SoundTests"       ; add a item named Change that goes to the Change label
Menu "Tray", "Add" , "E&xit", "ButtonExit" ; add a item named Exit that goes to the ButtonExit label

#Include WU_GetEidolonTime.ahk
Timer := {"SunRise": "", "SunDown": "", "FirstWarning": "", "LastWarning": "", "Finish": ""}
SecLeft := 0
StartDayCycle := WU_GetEidolonTime()
SecLeft := DateDiff(StartDayCycle, A_NowUTC, "seconds")
lg(A_ThisLabel . ": StartDayCycle(" . StartDayCycle . ") A_NowUTC(" . A_NowUTC . ") SecLeft(" . SecLeft . ") ")
Schedule_Alarm("SunRise", 0)
Schedule_Alarm("Finish", -2)
Schedule_Alarm("LastWarning", -50)
Schedule_Alarm("FirstWarning", -52)
Schedule_Alarm("SunDown", -62)
return

Schedule_Alarm(Label, Min) {
  Global
  lg(A_ThisFunc . ": Label(" . Label . ") Min(" . Min . ")")
  SetFor  := DateAdd(StartDayCycle, Min, "minutes")
  SecLeft := DateDiff(SetFor, A_NowUTC, "seconds")
  if SecLeft < 0
    SecLeft += 150*60
  Timer.Label := "scheduled"
  SetTimer Label, -SecLeft*second
  lg(A_ThisFunc . ": SetTimer '" . Label . "', " . -SecLeft)
  return
}

Check_Alarm(Label) {
  global
  if Timer.Label = "scheduled" {
    SetTimer Label, "Delete"
    SetTimer Label, 150*Minute
    Timer.Label := "set"
  }
  return
}

Lg(text) {
  global
  FileAppend A_TickCount . ": " . text . "`r`n", LogFile
  return
}

AHK_NotifyTrayIcon(wParam, lParam)
{
  global Title, Processed
  If lparam <> 0x200
    return ""
  if Processed
    return true
  data := WU_GetEidolonData()
  Menu "Tray", "Tip", Title . "`n" . (data.IsDay?"Day":"Night") . "`n" . data.shortString
  Processed := true
  SetTimer "Reset", -5000
  return true
}

Reset:
Processed := False
return

SunRise:
Check_Alarm(A_ThisLabel)
Dawn:
lg(A_ThisLabel . ": let the mockingbird sing once now")
SoundPlay "MockingBird-sounds.wav", "wait"
return

SunDown:
Check_Alarm(A_ThisLabel)
Dusk:
lg(A_ThisLabel . ": let the Nightingale sing once now")
SoundPlay "Nightingale-sound.mp3", "wait"
return

FirstWarning:
Check_Alarm(A_ThisLabel)
AlmostNight:
lg(A_ThisLabel . ": let the teralyst roar once now")
SoundPlay "eidolon roar.mp3", "wait"
return

LastWarning:
Check_Alarm(A_ThisLabel)
NightFall:
lg(A_ThisLabel . ": let the teralyst roar twice now")
SoundPlay "eidolon roar.mp3", "wait"
Sleep 500
SoundPlay "eidolon roar.mp3", "wait"
return

Finish:
Check_Alarm(A_ThisLabel)
AlmostDawn:
lg(A_ThisLabel . ": let the machine beep thrice now")
Loop 2 {
  SoundBeep 500,500
  Sleep 500
}
SoundBeep 1000,1000
return

Log:
Run LogFile
return

ButtonExit:
ExitApp