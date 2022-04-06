Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
End Function

Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function

Function RegDelete(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
End Function

Function loadRegistrationToken() As dynamic
    RegToken =  RegRead("RegToken", "Authentication")
    if RegToken = invalid then RegToken = ""
    if RegToken <> "" then return RegToken else return "" 
End Function

Sub saveRegistrationToken(token As String)
    RegWrite("RegToken", token, "Authentication")
End Sub

Sub deleteRegistrationToken()
    RegDelete("RegToken", "Authentication")
    'm.RegToken = ""
End Sub

Function isLinked() As boolean
    if Len(m.global.user.RegToken) > 0  then return true
    return false
End Function
