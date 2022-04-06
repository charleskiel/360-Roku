
function get(url as string)
	'? "[GET ] ==> " + url
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
			res = msg.GetString()
			'json = ParseJSON(msg.GetString())
			'json["responseCode"] = msg.GetResponseCode()
			'json["statusCode"] = msg.GetResponseCode()
			'json["headers"] = msg.GetResponseHeaders()
			'json["headers"] = msg.GetResponseHeaders()["Etag"]
		end if
	end if
	'print json
	return res
end function


function post(url as string, body as object)
	'? "[POST] ==> " + url + chr(10) + " body ==> " body.toStr()
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
		if (type(msg) = "roUrlEvent") then res = msg.GetString()
	end if
	'print json
	return res
end function

