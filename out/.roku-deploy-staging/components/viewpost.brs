sub init()
	'm.top.segmentEpoch = 0
	m.viewtimer = createobject("roTimeSpan")
	m.segmentTimer = createobject("roTimeSpan")

	m.top.ObserveField("setStreamingSegment", "setStreamingSegment")
	m.top.ObserveField("setDownloadedSegment", "setDownloadedSegment")
	m.top.ObserveField("setPlayStartInfo", "setPlayStartInfo")
	m.top.ObserveField("setPositionInfo", "setPositionInfo")
	m.top.ObserveField("setStreamInfo", "setStreamInfo")
	m.top.ObserveField("setState", "setState")

	m.top.functionName = "executeTask"

end sub

function executeTask() as void

	overlays = []
	nextoverlays = []
	posttimer = createobject("rotimespan")
	posttimer.mark()
	postBody = FormatJson({
		"esn" : m.global.device.esn
		"user" : m.global.user,
		"playerEpoch" : playerEpoch() ,
		"screenMode" : m.top.screenMode,
		"streamName" : m.top.streamName,
		"channelNumber" : 1,
		"playID" : m.top.playID,
		"action" : "PLAY",
		"position" : m.top.nowpos,
		"bandwidth" : m.top.totalBandwidth,
		"segmentEpoch" : m.top.segmentEpoch,
		"segmentTimer" : m.segmentTimer.TotalMilliseconds(),
		"offset" : m.top.offset
	})
	'? postBody
	response = post(m.global.config.viewpost, postBody)
	m.top.posttime = posttimer.TotalMilliseconds()
	j = ParseJson(response)
	if j <> invalid and j.count() > 0 then 
		m.top.response = response
		' ? j["nowPlaying"]
		m.top.playOK = true
		content = []
		m.top.serverEpoch = ParseJson(j["serverEpoch"].tostr())
		m.top.offset = j["channel"]["offset"] * 1000
		
		for each item in j["nowPlaying"]
			' ? item
			content.push({
				artist : item["alphaArtist"],
				title : item["title"],
				contentEndEpoch : item["contentEndEpoch"],
				contentEpoch : item["contentEpoch"],
				TRT : item["trt"],
				titleIn : item["titlein"],
				titleOut : item["titleout"],
				overlay : item["overlay"],
				mode : item["mode"]
			})
		end for
		m.top.content = content
		if m.top.content.count() > 0
			m.top.mode = m.top.content[m.top.content.count() -1].mode 
			m.top.overlay = m.top.content[m.top.content.count() -1].overlay 
		end if

	else
		m.top.playOK = false
	end if

	m.top.control = "stop"

end function


function segmentTimer() as longinteger
	return m.segmentTimer.totalMilliseconds()
end function 

function viewTimer() as longinteger
	return m.viewtimer.TotalMilliseconds()
end function 

function playerEpoch() as longinteger
	if m.top.serverEpoch <> invalid then
		return m.top.serverEpoch + ( 5000)
	else 
		
STOP
		return 0
	end if


end function

function timeLeft() as float
	if m.top.content <> invalid and  m.top.content.count() > 0 then 
		return (m.top.content[0].contentEndEpoch - playerEpoch())
	else
		return 0
	end if
end function

function setStreamingSegment(data)
	m.top.playOK = true
	msg = data.getData()
	m.segmentTimer.mark()

	if msg <> invalid then 
		' ? "StremingSegment = >  " + ParseJson(mid(msg.segurl, Len("https://360tv.net/stream/east/")+1,13 )).tostr()
		' ? "	 StremingURL = > " + mid(msg.segurl, Len("https://360tv.net/stream/east/")+1,13 )
		' ? "   Segment start : " + m.top.segmentStartTime.toStr()
		' ? "	 StremingURL = > " + msg.segURL
		' ? "	 SegmentEpoch= > " + m.top.segmentEpoch.tostr()
		m.top.segmentStartTime = msg.segStartTime
		m.top.segmentURL = msg.segURL
		m.top.segmentSequence = msg.segSequence
		m.top.segmentEpoch = ParseJson(mid(msg.segurl, Len("https://360tv.net/stream/east/")+1,13 ))
		if m.top.segmentEpoch = invalid then stop

		m.top.segmentBitrateBPS = msg.segBitrateBPS
		'm.top.control = "RUN"
	end if
end function

function setDownloadedSegment(data)
	msg = data.getData()
	if msg <> invalid then 
		m.top.segmentDownloadDuration = msg.downloadDuration
		m.top.segmentDownloadedSize = msg.SegSize * 0.00000095367432
		'? msg.BitrateBPS      'integer Bitrate of the segment, in bits per second
		m.top.totalBandwidth = m.top.totalBandwidth + (m.top.segmentDownloadedSize * 0.00000095367432)
	end if 
end function

function setPlayStartInfo(data)
	msg = data.getData()
	if msg <> invalid then 
		? setPlayStartInfo
		? msg
	end if
end function

function setPositionInfo(data)
	msg = data.getData()
	if msg <> invalid then 
		? "setPositionInfo"
		? msg
	end if
end function

function setStreamInfo(data)
	msg = data.getData()
	if msg <> invalid then 
		? msg
	end if
end function

function setState(data)
	msg = data.getData()
	? "setstate " + msg
	if msg = "playing" then
		m.viewtimer.mark()
		m.top.playok = true
		'm.top.control = "RUN"
		m.segmentTimer.mark()

	else
		m.top.playok = false
	end if
end function

function randID() as string
	randkey = createobject("roArray", 5, true)
	result = ""
	for i = 0 to 5
		result = result + (RND(0) * (65 - 90)) + 90
	next
	return result
end function


function updateoverlays() as void
	? "Updating Overlays"
	xml = createobject("roXMLElement")
	xml.parse(m.xop.xml.overlaysxml)
	overlays = []
	if xml.overlays.count() > 0 then
		for each obj in xml.overlays[0].overlay
			newitem = {}

			if (obj@url <> invalid) then
				'? obj.url.gettext()
				'm.top.overlay = obj.url.gettext()
				newitem.type = "poster"
				newitem.node = createObject("RoSGnode", "poster")
				newitem.node.id = "overlay-" + randID()
				newitem.node.uri = obj@url
				newitem.node.translation = [strtoi(obj@x), strtoi(obj@y)]
				'newitem.node.triggered = false
				'overlays.push(newitem.node)
			else
				newitem.type = "label"
				'? obj.url.gettext()
				'm.top.overlay = obj.text.gettext()
				newitem.node = createObject("RoSGnode", "label")
				newitem.node.id = "overlay-" + randID()
				'newitem.node.width = 800
				'newitem.node.height = 800
				newitem.node.text = obj.gettext().Replace("%bw", m.top.totalbandwidth.tostr())
				'newitem.node.font.role = "font"
				if obj@fonturi <> invalid then
					newitem.node.font.uri = obj@fonturi
				else if obj@font <> invalid then
					newitem.node.font = obj@font
				end if
				newitem.node.font.size = strtoi(obj@size)
				if obj@horizAlign <> invalid then newitem.node.horizAlign = obj@horizAlign
				newitem.node.translation = [strtoi(obj@x), strtoi(obj@y)]
				'newitem.node.triggered = false
				'stop
				'? "----"  + newitem.node.id
				'? "----"  + newitem.node.font.uri + " " + newitem.node.font.size.tostr() + " - " + obj.gettext() + " " + newitem.node.horizAlign
			end if
			
			if obj@time <> invalid then
				newitem.time = strtoi(obj@time)
				if m.top.TRT - m.top.timeleft >= newitem.time and (m.top.trt - m.top.timeleft) < (strtoi(obj@time) + strtoi(obj@duration)) then
					newitem.triggered = 1
					newitem.node.opacity = 1
				else if (m.top.trt - m.top.timeleft) >= (strtoi(obj@time) + strtoi(obj@duration)) and (m.top.trt - m.top.timeleft) > (strtoi(obj@time) + strtoi(obj@duration)) then
					newitem.triggered = 1
					newitem.node.opacity = 0
					'newitem.node.visible
				else' if m.top.TRT - m.top.timeleft < newitem.time
					newitem.triggered = 0
					newitem.node.opacity = 0
				end if
				newitem.duration = strtoi(obj@duration)
			else
				newitem.triggered = 1
				newitem.node.opacity = 1
			end if
			'? newitem
			overlays.push(newitem)
			'stop
			'if newitem.time <> invalid stop
		end for
		m.overlays = []
		m.overlays = overlays
	end if
end function

function updatenextoverlays() as void
	? "Updating Next Overlays"
	xml = createobject("roXMLElement")
	xml.parse(m.nextoverlaysxml)
	nextoverlays = []
	if xml.nextoverlays.count() > 0 then
		for each obj in xml.nextoverlays[0].overlay
			newitem = {}
			if (obj@url <> invalid) then
				'? obj.url.gettext()
				'm.top.overlay = obj.url.gettext()
				newitem.type = "poster"
				newitem.node = createObject("RoSGnode", "poster")
				newitem.node.id = "overlay-" + randID()
				newitem.node.uri = obj@url
				newitem.node.translation = [strtoi(obj@x), strtoi(obj@y)]
				'newitem.node.triggered = false
				'nextoverlays.push(newitem.node)
			else
				newitem.type = "label"
				'? obj.url.gettext()
				'm.top.overlay = obj.text.gettext()
				newitem.node = createObject("RoSGnode", "label")
				newitem.node.id = "overlay-" + randID()
				'newitem.node.width = 800
				'newitem.node.height = 800
				newitem.node.text = obj.gettext().Replace("%bw", m.top.totalbandwidth.tostr())
				'newitem.node.font.role = "font"
				if obj@fonturi <> invalid then
					newitem.node.font.uri = obj@fonturi
				else if obj@font <> invalid then
					newitem.node.font = obj@font
				end if
				newitem.node.font.size = strtoi(obj@size)
				if obj@horizAlign <> invalid then newitem.node.horizAlign = obj@horizAlign
				newitem.node.translation = [strtoi(obj@x), strtoi(obj@y)]
				'newitem.node.triggered = false
				'stop
				'? ----"  + newitem.node.font.uri + " " + newitem.node.font.size.tostr() + " - " + obj.gettext() + " " + newitem.node.horizAlign
			end if
			if obj@time <> invalid then
				newitem.time = strtoi(obj@time)
				if m.top.TRT - m.top.timeleft >= newitem.time then
					newitem.triggered = 1
					newitem.node.opacity = 1
				else
					newitem.triggered = 0
					newitem.node.opacity = 0
				end if
				newitem.duration = strtoi(obj@duration)
			else
				newitem.triggered = 0
				newitem.node.opacity = 1
			end if
			'? newitem
			nextoverlays.push(newitem)
			'stop
			'if newitem.time <> invalid stop
		end for
		m.nextoverlays = []
		m.nextoverlays = nextoverlays
	end if
end function


