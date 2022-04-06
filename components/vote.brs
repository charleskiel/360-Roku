
sub init()
	m.top.functionName = "executeTask"
end sub

function executeTask() as void
	url = "https://360tv.net:8001/status?" + "regtoken=" + m.global.regtoken + "&regcode=" + m.top.regcode + "&action=VOTE&castVote=" + m.top.castVote.toStr() + "&voteSelection=" + m.top.voteIndex.toStr()
	? url
	port = CreateObject("roMessagePort")
	request = CreateObject("roUrlTransfer")
	request.SetMessagePort(port)
	request.SetCertificatesFile("common:/certs/ca-bundle.crt")
	request.RetainBodyOnError(true)
	request.AddHeader("Content-Type", "application/json")
	request.SetRequest("POST")
	request.SetUrl(url)
	
	body = FormatJSON({"device" : m.global.device})
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
	
	if http.AsyncGetToString() then
		msg = wait(6000, port)
		if (type(msg) = "roUrlEvent")
			'HTTP response code can be <0 for Roku-defined errors
			if (msg.getresponsecode() > 0 and msg.getresponsecode() < 400)
				'm.top.posttime = posttimer.totalmilliseconds()

				json = ParseJSON(msg.getstring())
				'? json
				if json.modeSelections <> invalid then m.top.voteOptions = json.modeSelections.details
				m.top.castVote = false
			else
				? "feed load failed: "; msg.getfailurereason();" "; msg.getresponsecode();" "; m.top.url
				m.top.response = ""
			end if
			http.asynccancel()
		else if (msg = invalid)
			? "feed load failed."
			m.top.response = ""
			http.asynccancel()
		end if
	end if
	m.top.control = "stop"
end function

function randID() as string

	randkey = createobject("roArray", 5, true)
	for i = 0 to 5
		randkey[i] = (RND(0) * (65 - 90)) + 90
	next i
	return chr(randkey[0]) + chr(randkey[1]) + chr(randkey[2]) + chr(randkey[3]) + chr(randkey[4]) + chr(randkey[5])
end function


