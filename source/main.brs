'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub Main()

	screen = CreateObject("roSGScreen")
	
	m.port = CreateObject("roMessagePort")
	screen.setMessagePort(m.port)
	scene = screen.CreateScene("Videoscene")
	deleteRegistrationToken()

	m.global = screen.getGlobalNode()
	m.global.id = "GlobalNode"
	
	m.global.addFields( {
		regtoken: loadRegistrationToken()
	} )
		
	m.global.addFields({"get" : get})
	m.global.addFields({"post" : post})
      
	m.global.addFields( {device: deviceinfo()} )
	m.global.addFields( {config: post("https://www.360tv.net/api/v1/roku/config", FormatJSON({"device" : m.global.device}))} )
	m.global.addFields( {user: post("https://www.360tv.net/api/v1/roku/userInfo", FormatJson({"device" : m.global.device, "regtoken" : m.global.regtoken} ))})
	m.global.addFields( {userparams: ""} )
	' m.global.addFields( {urlparams: urlparams(0)} )
	m.global.addFields( {fonts: getfonts()} )
	
	screen.show()  
	while(true)
		msg = wait(0, m.port)
		msgType = type(msg)
		? msg
		if msgType = "roSGScreenEvent"
			if msg.isScreenClosed() then return
		end if
	end while

end sub

Function DeviceInfo() as object
	device = createobject("roAssociativeArray")
	device.appVersion = "1.00"
	device.status = "OK"
	device.message1 = ""
	device.message2 = ""
	device.messageColor = ""
	device.ESN = CreateObject("roDeviceInfo").GetChannelClientId()
	device.model = ""
	device.modelDisplayName = ""
	device.deviceUniqueId = CreateObject("roDeviceInfo").GetChannelClientId()
	device.displayType = CreateObject("roDeviceInfo").GetDisplayType()
	device.displayMode = CreateObject("roDeviceInfo").GetDisplayMode()
	device.countryCode = ""
	device.timeZone = ""
	device.audioOutputChannel = ""
	
	device.displayMode = CreateObject("roDeviceInfo").GetVideoMode()
	device.model = CreateObject("roDeviceInfo").GetModel()
	device.modelDisplayName = CreateObject("roDeviceInfo").GetModelDisplayName()
	device.linkStatus = CreateObject("roDeviceInfo").GetLinkStatus()
	device.countryCode = CreateObject("roDeviceInfo").GetCountryCode()
	device.audioOutputChannel = CreateObject("roDeviceInfo").GetAudioOutputChannel()
	
	getIp  = CreateObject("roDeviceInfo").GetIPAddrs()
	
	if getIp.eth0 <> invalid then
		device.ipAddress = getIp.eth0
	else if getIp.eth1 <> invalid then
		device.ipAddress = getIp.eth1
	end if
	
	return device
End Function

function getfonts()' as object
	CreateDirectory("tmp:/fonts")

	https = CreateObject("roUrlTransfer")
	https.SetCertificatesFile("common:/certs/ca-bundle.crt")
	https.InitClientCertificates()
	https.setport(m.port)

	fonts = CreateObject("roArray", 5, true) 
	font = createobject("roAssociativeArray")
	reg = CreateObject("roFontRegistry")
	app = CreateObject("roAppManager")
	theme = CreateObject("roAssociativeArray")

	font = CreateObject("roArray", 5, true) 
	for idx = 0 to (m.global.config.fonts.count() -1)
		font = CreateObject("roArray", 5, true)
		
		https.SetUrl(m.global.config.fonts[idx].url)
		https.GetToFile(m.global.config.fonts[idx].path)
		reg.Register(m.global.config.fonts[idx].path)
		
		for idx1 = 0 to (m.global.config.fonts[idx].sizes.count() - 1)
			fontset = reg.GetFont(m.global.config.fonts[idx].name, m.global.config.fonts[idx].sizes[idx1], false, false)
			font.push(fontset)
		next

		fonts.push(font)
	next

    return fonts
end function

function get(url as string)
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
			json = ParseJSON(msg.GetString())
			json["responseCode"] = msg.GetResponseCode()
			json["statusCode"] = msg.GetResponseCode()
			json["headers"] = msg.GetResponseHeaders()
			' json["headers"] = msg.GetResponseHeaders()["Etag"]
		end if
	end if
	print json
	return json
end function


function post(url as string, body as object)
	? url
	'body = FormatJSON({"device" : m.global.device})
	port = CreateObject("roMessagePort")
	request = CreateObject("roUrlTransfer")
	request.SetMessagePort(port)
	request.SetCertificatesFile("common:/certs/ca-bundle.crt")
	request.RetainBodyOnError(true)
	request.AddHeader("Content-Type", "application/json")
	request.SetRequest("POST")
	request.SetUrl(url)
	requestSent = request.AsyncPostFromString(body)
	if (requestSent)
		msg = wait(0, port)
		if (type(msg) = "roUrlEvent")
			json = ParseJSON(msg.GetString())
			json["responseCode"] = msg.GetResponseCode()
			json["statusCode"] = msg.GetResponseCode()
			json["headers"] = msg.GetResponseHeaders()
		end if
	end if
	print json
	return json
end function

