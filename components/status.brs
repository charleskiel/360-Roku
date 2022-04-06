
sub init()
    m.top.functionName = "executeTask"
end sub

function executeTask() as void
	m.top.regtoken = RegRead("RegToken", "Authentication")
	? m.top.regtoken
	posttimer = createobject("rotimespan")
	
	user = createobject("roAssociativeArray")
	
	url = m.global.config.userInfo + "&regtoken=" + m.global.regtoken + "&regcode=" + m.top.regcode
	? url
	port = CreateObject("roMessagePort")
	request = CreateObject("roUrlTransfer")
	request.SetMessagePort(port)
	request.SetCertificatesFile("common:/certs/ca-bundle.crt")
	request.RetainBodyOnError(true)
	request.AddHeader("Content-Type", "application/json")
	request.SetRequest("GET")
	request.SetUrl(url)
	requestSent = request.AsyncGetToString()
	if (requestSent)
		msg = wait(0, port)
		if (type(msg) = "roUrlEvent")
			json = msg.GetString()
			' json["responseCode"] = msg.GetResponseCode()
			' json["statusCode"] = msg.GetStatusCode()
			' json["headers"] = msg.GetResponseHeaders()
			? json
			' stop
			
			' json["headers"] = msg.GetResponseHeaders()["Etag"]
		end if
	end if
	print json
	
	m.top.control = "stop"
end function


Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function
Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
End Function