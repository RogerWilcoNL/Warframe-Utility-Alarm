WU_GetEidolonTime() {
    local data := WU_GetEidolonData()
    return data.expiry
}    

WU_GetEidolonData() {
    local
    json := DownloadToString("https://api.warframestat.us/pc/cetusCycle")
    lg(A_ThisFunc . ": ldt(" . A_Now . ") UTC(" . a_NowUTC . ") " . json)
    data := jxon_load(json)
    FrmDtm := GetDtm(data.expiry)
    if data.IsDay
        FrmDtm := DateAdd(FrmDtm, 50, "minutes")
    data.expiry := FrmDtm
    return data
}

DownloadToString(url, encoding := "utf-8")    ; by Bentschi
{
    local b, c, f, h, o, r:=0, s
    static a := "AutoHotkey/" A_AhkVersion
    if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
        return 0
    c := s := 0, o := ""
    if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
    {
        while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
        {
            VarSetCapacity(b, s, 0)
            DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
            o .= StrGet(&b, r >> (encoding = "utf-16" || encoding = "cp1200"), encoding)
        }
        DllCall("wininet\InternetCloseHandle", "ptr", f)
    }
    DllCall("wininet\InternetCloseHandle", "ptr", h)
    return o
}

GetDtm(str) {
  local Res := ""
  Loop Parse, str , "-T:.Z", A_Space
    if A_LoopField is "digit"
      Res .= A_LoopField
  return SubStr(Res, 1, 14)
}

#include jxon.ahk