sub init()
	m.playerEpoch = 0
	'm.viewpost.totalBandwidth = CreateObject("roFloat")
	m.debugKeyTimer = 0


	m.segmenttimer = createobject("roTimeSpan")
	m.showvideoinfotimer = createobject("roTimeSpan")
	m.viewtimer = createobject("roTimeSpan")

	m.showvideoinfotimer = createobject("roTimeSpan")
	m.showvideoinfo = 0


	m.viewpost = CreateObject("roSGNode", "ViewPost")
	m.viewpost.ObserveField("response", "posted")
	m.viewpost.ObserveField("playContentID", "updateoverlays")
	m.viewpost.ObserveField("nextPlayConentID", "updatenextoverlays")
	'm.viewpost.ObserveField("serverepoch", "posted")
	m.viewPostTick = m.top.findNode("viewPostTick")
	m.viewPostTick.ObserveField("fire","viewPostTick")


	m.videoinfo = CreateObject("roSGNode", "VideoInfo")
	m.videoinfo.ObserveField("display", "GotVideoInfo")
	m.videoinfoOverlayfadeout = m.top.FindNode("videoinfoOverlayfadeout")
	m.videoinfoOverlayfadein = m.top.FindNode("videoinfoOverlayfadein")



	m.status = CreateObject("roSGNode", "serverstatus")
	m.status.ObserveField("serverepoch", "Gotstatus")
	m.statustick = m.top.findNode("statustick")
	m.statustick.ObserveField("fire","getStatus")

	'm.status.ObserveField("regcode", "doregistration")
	m.loadingoverlay = m.top.findnode("loadingoverlay")
	m.loadinglabel = m.top.findnode("loadinglabel")
	m.loadingoverlayfadeout = m.top.FindNode("loadingoverlayfadeout")
	m.loadingoverlayfadein = m.top.FindNode("loadingoverlayfadein")

	m.registrationScreen = m.top.findnode("registrationScreen")
	m.regcode = m.top.findnode("regcode")
	m.registrationmessage = m.top.findnode("registrationmessage")
	m.registrationfadeout = m.top.FindNode("registrationscreenfadeout")

	m.vote = CreateObject("roSGNode", "Vote")
	m.voteoverlay = m.top.findnode("VoteOverlay")
	m.voteselection = -1
	m.votetick = m.top.findNode("votetick")
	m.votetick.ObserveField("fire", "RunVotePost")
	m.vote.ObserveField("voteOptions", "VotesChanged")

	m.highResTick = m.top.findNode("highResTick")
	m.highResTick.ObserveField("fire","highResTick")
	m.debugOverlay = m.top.findnode("debugOverlay")
	m.debugLabel = m.top.findnode("debugLabel")



	m.showOverlays = false
	m.mainOverlay = m.top.findnode("mainoverlay")
	m.overlays = []
	m.nextoverlays = []
	m.overlayfadeout = m.top.FindNode("overlayfadeout")
	m.overlayfadein = m.top.FindNode("overlayfadein")
	m.overlayfastfadeout = m.top.FindNode("overlayfastfadeout")
	m.overlayfastfadein = m.top.FindNode("overlayfastfadein")


	videocontent = createObject("RoSGNode", "ContentNode")
	videocontent.title = "360"
	videocontent.streamformat = "hls"
	videocontent.streams = [{
		url : "https://360tv.net/stream/east/index.m3u8",
		bitrate : 2300,
		quality : false,
		contentid : "1"
	}]


	m.video = m.top.findNode("VideoPlayer")
	m.video.ObserveField("streamingSegment", "videoevent")
	m.video.ObserveField("downloadedSegment", "videoevent")
	m.video.ObserveField("state", "videoevent")
	m.video.ObserveField("videoFormat", "videoevent")
	m.video.ObserveField("playStartInfo", "videoevent")

	m.video.content = videocontent
	m.video.control = "play"

	m.top.setFocus(true)

	m.loadinglabel.text = "getting server status"
	m.status.control = "RUN"

	m.statustick.control = "start"
	m.viewposttick.control = "start"
	'm.votetick.control = "start"
	m.debugOverlay.visible = true
end sub

sub viewPostTick()
	? "Running View Post"
	m.viewpost.control = "RUN"
end sub


sub RunVotePost()
    '? "Running Vote Post"
    m.vote.control = "RUN"
end sub


sub VotesChanged()
    if m.vote.voteOptions <> invalid then
        for i= 0 to 2
            if m.top.findnode("votetextA" + i.toStr()).text <> m.vote.voteOptions[i].artist + " - " + m.vote.voteOptions[i].title then 
                m.vote.voteIndex = -1
                m.vote.highlightIndex = 0
            end if

            m.top.findnode("votetextA" + i.toStr()).text = m.vote.voteOptions[i].artist + " - " + m.vote.voteOptions[i].title
            m.top.findnode("votetextB" + i.toStr()).text = m.vote.voteOptions[i].votes

            if m.vote.highlightIndex = i then 
                m.top.findnode("VoteIndicator" + i.toStr()).color = "0x00FF00A8"
            else
                m.top.findnode("VoteIndicator" + i.toStr()).color = "0x524b61FF"
            end if

            if m.vote.voteIndex = i then 
                m.top.findnode("votetextA" + i.toStr()).color = "0xff4d50FF"
            else
                m.top.findnode("votetextA" + i.toStr()).color = "0x867aa1FF"
            end if
        next
    end if
end sub 

sub posted(obj)

	'm.viewpost.callFunc("timeleft") = (m.viewpost.contentendepoch - m.playerEpoch) - (m.segmenttimer.totalmilliseconds() / 1000)
	'm.mainOverlay.removechildren(m.mainOverlay.getChildren(1e4,0))
	if m.showoverlays = 1 then 
		if m.overlays.count() > 0 then
			'm.overlays = []

			'? m.viewpost.overlays
			'? m.overlays
		end if
	else if m.showoverlays = 2 then
		if m.nextoverlays.count() > 0 then
			m.nextoverlays = []
			m.nextoverlays = m.viewpost.nextoverlays
			for each overlay in m.viewpost.nextoverlays
				? overlay.node 
				m.mainOverlay.appendChild(overlay.node)
			end for
		end if
	end if
	m.loadinglabel.text = "posted"
	
	
	if m.mainOverlay.getchildcount() > 0 then
		? "================================="
		? "Overlays"
		? m.mainOverlay.getChildren(1e4,0)
		? "================================="
	end if        
	if m.nextoverlays.count() > 0 then
		? "Next Overlays"
		? m.nextoverlays.count()
		? "================================="
	end if

end sub


sub getStatus()
    '? "Getting Server Status"
    m.loadinglabel.text = "getting server status"
    m.status.control = "RUN"
end sub


sub gotStatus(obj) 
    '? m.status
    m.loadinglabel.text = "got server status"
    if m.status.onair = true and  m.video.state <> "playing" then 
        m.loadinglabel.text = "Enjoy"
        m.video.control = "play"
    else if m.status.onair = false then
        m.loadinglabel.text = "off air"
        if m.viewpost.callFunc("timeleft") < 0 and m.viewpost.playok = true then 
            m.video.control = "stop"
            m.viewpost.playok = false
            if m.loadingoverlay.opacity = 0 then m.loadingoverlayfadein.control = "start"
        end if
    end if
    if m.status.regcode <> "" then
        'm.loadinglabel.text = "register"
        m.regcode.text = m.status.regcode
        m.registrationmessage.text = m.status.registrationmessage
        'if m.registrationscreen.visible = false then m.registrationscreen.visible = true
    else 
        'if m.registrationscreen.visible = true then m.registrationscreen.visible = false
    end if
end sub

sub doRegistration(obj)
    ? "Doing Registration------------------"
    ? obj
end sub

sub GotVideoInfo(obj)
	m.loadinglabel.text = "got video info"
	m.showvideoinfotimer.mark()
	videoinfolabel = m.top.findNode("VideoInfoLabel") 
	videoinfostarimage = m.top.findNode("starimage")
	averageratingline = m.top.findNode("AverageRatingline")

	videoinfolabel.text = m.videoinfo.display
	
	loggedInLabel1= m.top.findnode("loggedInLabel1")
	loggedInLabel2= m.top.findnode("loggedInLabel2")
	loggedInLabel3= m.top.findnode("loggedInLabel3")
	avatar = m.top.findnode("avatar")

	if m.global.user.regtoken = "" then
		loggedInLabel1.text = "Register this device at www.360tv.net"
		loggedInLabel2.text = "with code:"
		loggedInLabel3.text = m.global.user.regcode
		avatar.visible = false
	else
		loggedInLabel1.text = "Logged in as:"
		loggedInLabel2.text = m.global.user.firstname + " " + m.global.user.lastname
		loggedInLabel3.text = m.global.user.zipcode
		avatar.visible = true 
		avatar.uri = m.global.user.avatar
	end if

	
	if m.videoinfo.userrating = 0 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/0star.png"
	else if m.videoinfo.userrating = 20 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/1star.png"
	else if m.videoinfo.userrating = 40 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/2star.png"
	else if m.videoinfo.userrating = 60 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/3star.png" 
	else if m.videoinfo.userrating = 80 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/4star.png"
	else if m.videoinfo.userrating = 100 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/5star.png"
		
		
	else if m.videoinfo.averagerating < 7 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/0star-a.png"
	else if m.videoinfo.averagerating <= 10 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/10star-a.png"
	else if m.videoinfo.averagerating <= 20 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/20star-a.png"
	else if m.videoinfo.averagerating <= 30 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/30star-a.png"
	else if m.videoinfo.averagerating <= 40 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/40star-a.png"
	else if m.videoinfo.averagerating <= 50 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/50star-a.png"
	else if m.videoinfo.averagerating <= 60 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/60star-a.png"
	else if m.videoinfo.averagerating <= 70 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/70star-a.png"
	else if m.videoinfo.averagerating <= 80 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/80star-a.png"
	else if m.videoinfo.averagerating <= 90 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/90star-a.png"
	else if m.videoinfo.averagerating <= 100 then
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/100star-a.png"
	else
		videoinfostarimage.uri= "https://www.360tv.net/roku/theme/0star.png"
	end if

	if m.videoinfo.enabled = false then  videoinfostarimage.uri= "https://www.360tv.net/roku/theme/0star.png"
	if m.videoinfo.averagerating > 0 then 
		averageratingline.width = videoinfostarimage.width * (m.videoinfo.averagerating / 100) 
	else
		averageratingline.width = videoinfostarimage.width
	end if 
	
	if m.showvideoinfo = 0 then
		m.showvideoinfo = 1
		m.videoinfoOverlayfadein.control = "start"
	end if
end sub

sub hideVoting()
	m.vote.enabled = false
	? m.vote.enabled
	? "Hiding"
	'm.VoteOverlay.visible = "false"

	'?  m.top.FindNode("VoteOverlay")
	t = m.top.FindNode("VoteOverlaySlideOut")
	t.fieldToInterp = "VoteOverlay.translation"
	t.keyValue = "[[0,0],[500,0]"
	t.control = "stop"
	t.control = "start"
	? t.keyValue
end sub

sub showVoting()
	m.vote.enabled = true
	m.VoteOverlay.visible = "true"
	? m.vote.enabled
	? "Showing"
	t = m.top.FindNode("VoteOverlaySlideIn")
	t.fieldToInterp = "VoteOverlay.translation"
	t.keyValue = "[[500,0],[0,0]"
	t.control = "stop"
	t.control = "start"
	? t.keyValue
end sub


sub getdeviceinfo()
    m.device.deviceinfo()
end sub

sub onIndexChanged()
    ? "Index Changed"
end sub

sub highResTick()
	'? m.voteoverlay.visible
	if m.showvideoinfotimer.totalseconds() >= 7 and m.showvideoinfo = 1 then 
		m.videoinfooverlayfadeout.control = "start"
		m.showvideoinfo = 0
	end if

	if m.viewpost.playok = true and m.viewpost.content <> invalid and m.viewpost.content.count() > 0 then
	

		if m.viewpost.content[m.viewpost.content.count() -1].mode = "VOTE" then
			

			if (m.viewpost.callFunc("playerEpoch") - m.viewpost.content[m.viewpost.content.count() -1].contentEpoch > m.viewpost.content[m.viewpost.content.count() -1].titlein + 17) and (((m.viewpost.content[m.viewpost.content.count() -1].titleout = 0 and m.viewpost.callFunc("playerEpoch") - m.viewpost.content[m.viewpost.content.count() -1].contentEpoch <= m.viewpost.content[m.viewpost.content.count() -1].trt - 30) or (m.viewpost.content[m.viewpost.content.count() -1].titleout <> 0 and m.viewpost.callFunc("playerEpoch") - m.viewpost.content[m.viewpost.content.count() -1].contentEpoch <= m.viewpost.content[m.viewpost.content.count() -1].titleout - 14))) 
				showVoting()
			end if

			if ((m.viewpost.content[m.viewpost.content.count() -1].titleout = 0 and m.viewpost.callFunc("playerEpoch") - m.viewpost.content[m.viewpost.content.count() -1].contentEpoch > m.viewpost.content[m.viewpost.content.count() -1].trt - 35) or (m.viewpost.content[m.viewpost.content.count() -1].titleout <> 0 and m.viewpost.callFunc("playerEpoch") - m.viewpost.content[m.viewpost.content.count() -1].contentEpoch > m.viewpost.content[m.viewpost.content.count() -1].titleout - 15)) and m.viewpost.mode = "VOTE" and m.vote.enabled = true
				hideVoting()

			end if
		end if
		'm.playerEpoch = m.playerEpoch + m.segmenttimer.totalseconds()
		
		if (true) then 
			
			if (m.viewpost.content <> invalid and m.viewpost.content.count() = 1) then
				if m.mainOverlay.getchildcount() = 0
					for each overlay in m.overlays
						'? overlay.node
						m.mainOverlay.appendChild(overlay.node)
					end for
				end if
				if m.viewpost.content[0].trt <> invalid

					if (m.viewpost.content[0].trt - m.viewpost.callFunc("timeleft")) > 4 and m.viewpost.callFunc("timeleft") >= 9 then
						m.mainOverlay.removechildren(m.mainOverlay.getChildren(1e4,0))
						for each overlay in m.overlays
							'? overlay.node
							m.mainOverlay.appendChild(overlay.node)
						end for
						'm.mainOverlay.appendChildren(m.nextoverlays)
						m.showOverlays = 1
						m.overlayfadein.control = "start"
					else if (m.viewpost.callFunc("timeleft") < -4 ) and m.nextoverlay <> invalid then 'and m.viewpost.nextoverlays <> invalid then
					m.mainOverlay.removechildren(m.mainOverlay.getChildren(1e4,0))
					m.viewpost.contentid = m.viewpost.nextcontentid
					'm.mainOverlay.appendChildren(m.nextoverlays)
					
					for each overlay in m.nextoverlays
						'? overlay.node
						m.mainOverlay.appendChild(overlay.node)
					end for
					m.showOverlays = 2
					m.overlayfadein.control = "start"
					'stop
				end if
			end if
			else if m.showoverlays = 1

				if m.overlays <> invalid and m.overlays.count() > 0 and m.overlays.count() = m.mainOverlay.getChildCount() then
					for idx = 0 to ( m.mainOverlay.getChildCount() - 1)
						if m.overlays[idx].time <> invalid then
							if m.mainOverlay.getchild(idx).opacity = 0 and (m.viewpost.trt - m.viewpost.callFunc("timeleft")) >= m.overlays[idx].time and m.overlays[idx].triggered = 0 then
								? "Triggering IN " + idx.tostr() + " @ " m.overlays[idx].time.tostr() + "[" + (m.viewpost.trt - m.viewpost.callFunc("timeleft")).tostr() + "]" + "[" + (m.overlays[idx].triggered).tostr() + "]" + "[" + m.overlays[idx].node.id + "]"
								slidefadein = m.top.findnode("slidefadein")
								fastfade = m.top.FindNode("fastfadein")
								fastfade.fieldToInterp =  m.mainOverlay.getchild(idx).id + ".opacity"
								fastslidein = m.top.findnode("testvectorin")
								fastslidein.fieldToInterp = m.mainOverlay.getchild(idx).id + ".translation"
								fastslidein.keyValue=[ [m.mainOverlay.getchild(idx).translation[0] - 20 ,m.mainOverlay.getchild(idx).translation[1]], [m.mainOverlay.getchild(idx).translation[0],m.mainOverlay.getchild(idx).translation[1]]]
								slidefadein.control = "start"
								m.overlays[idx].triggered = 1
							else if m.mainOverlay.getchild(idx).opacity > 0 and (m.viewpost.trt - m.viewpost.callFunc("timeleft")) >= (m.overlays[idx].duration + m.overlays[idx].time) and m.overlays[idx].triggered = 1 then
								? "Triggering Out" + idx.tostr() + " @ " m.overlays[idx].time.tostr() + "[" + (m.viewpost.trt - m.viewpost.callFunc("timeleft")).tostr() + "]" + "[" + (m.overlays[idx].triggered).tostr() + "]" + "[" + m.overlays[idx].node.id + "]"
								slidefadeout = m.top.findnode("slidefadeout")
								fastfade = m.top.FindNode("fastfadeout")
								fastfade.fieldToInterp = m.overlays[idx].node.id + ".opacity"
								fastslideout = m.top.findnode("testVectorout")
								fastslideout.fieldToInterp = m.overlays[idx].node.id + ".translation"
								fastslideout.keyValue=[ [m.overlays[idx].node.translation[0] + 20 , m.overlays[idx].node.translation[1]], [m.overlays[idx].node.translation[0],m.overlays[idx].node.translation[1]]]
								slidefadeout.control = "start"
								m.overlays[idx].triggered = 2
							end if
						end if
					next
				end if
			end if
		end if
		
		m.DebugLabel.text = debugLabel()
	end if
end sub

function debugLabel() as string
	t = ""
	' if m.global.user.admin = 1 then 
	if m.viewpost.playOK = true then 
		if m.viewpost.content.count() = 1 then 
			t = t + "Now         : " + m.viewpost.content[0].overlay + " | " + m.viewpost.content[0].mode + " ["+ m.showoverlays.tostr() + "] "
			if m.viewpost.content[0].artist <> invalid then t = t + m.viewpost.content[0].artist + " - " + m.viewpost.content[0].title
			t = t + chr(10) + chr(10)
		else if m.viewpost.content.count() > 1 then 
			t = t + "Now         : " + m.viewpost.content[1].overlay + " | "  + " ["+ m.showoverlays.tostr() + "] "
			if m.viewpost.content[1].artist <> invalid then t = t + m.viewpost.content[1].artist + " - " + m.viewpost.content[1].title
			t = t + chr(10)

			t = t + "Next        : " + m.viewpost.content[0].overlay + " | " + m.viewpost.content[0].mode + " ["+ m.showoverlays.tostr() + "] "
			if m.viewpost.content[0].artist <> invalid then t = t + m.viewpost.content[0].artist + " - " + m.viewpost.content[0].title
			t = t + chr(10)

		else
			t = t + chr(10) + chr(10)
		end if
		
		t = t + chr(10)
		t = t + chr(10)
		t = t + chr(10)
		t = t + chr(10) +  "Player      : " + (m.viewpost.callFunc("playerEpoch")).tostr()
		t = t + chr(10) +  "Playing seg # " + m.viewpost.segmentEpoch.tostr()
		if m.viewpost.content.count() > 0 then 
			t = t + chr(10) +  "Content     : " + (m.viewpost.content[m.viewpost.content.count() -1].contentEpoch).tostr()
			t = t + chr(10) +  "Content End : " + (m.viewpost.content[m.viewpost.content.count() -1].contentEndEpoch).tostr()
			if m.viewpost.content[m.viewpost.content.count() -1].trt <> invalid then t = t + chr(10) +  "Run time    : " + (m.viewpost.content[m.viewpost.content.count() -1].trt).tostr() + " | " + ( m.viewpost.callFunc("playerEpoch") - m.viewpost.content[0].contentEpoch).tostr() + " | " + m.viewpost.callFunc("timeleft").toStr()
		else
			t = t + chr(10) + chr(10) + chr(10)
		end if
		t = t + chr(10)
		t = t + chr(10)
		
		t = t + chr(10) +  "View Time   : " + m.viewpost.callFunc("viewTimer").tostr()
		t = t + chr(10) +  "SegStart    : " + m.viewpost.segmentStartTime.tostr()
		t = t + chr(10) +  "SegURL      : " + m.viewpost.segmentURL.tostr()
		t = t + chr(10) +  "SegPath     : " + m.viewpost.segmentPath.tostr()
		t = t + chr(10) +  "SegBitrate  : " + m.viewpost.segmentBitrateBPS.tostr()
		t = t + chr(10) +  "SegSequence : " + m.viewpost.segmentSequence.tostr()
		t = t + chr(10) +  "Post time   : " + m.viewpost.posttime.tostr() + ":" + m.viewpost.callFunc("segmentTimer").tostr()
		t = t + chr(10) +  "Offset      : " + m.viewpost.offset.toStr()
		t = t + chr(10) +  "Delay       : " + (m.viewpost.serverEpoch - m.viewpost.segmentStartTime).toStr()
		t = t + chr(10)
		t = t + chr(10) +  "seg Size    : " +  m.viewpost.segmentdownloadedsize.toStr()
		t = t + chr(10) +  "DL time     : " +  m.viewpost.segmentdownloadduration.toStr() 
		t = t + chr(10) +  "Total BW    : " +  m.viewpost.totalbandwidth.toStr() 
		t = t + chr(10)
		t = t + chr(10) + chr(10) +  m.loadinglabel.text
		
		t = t + chr(10) + "Main Overlay Visible " + m.showOverlays.tostr()
		t = t + chr(10) + "Main Overlay Opacity " + m.mainOverlay.opacity.tostr()
		t = t + chr(10) + "Main Overlay Children " + m.mainOverlay.getchildcount().tostr()

		t = t + chr(10) + "Vote Enabled " + m.vote.enabled.tostr()
		t = t + chr(10) + "Vote Overlay Visible " + m.vote.enabled.tostr()
		t = t + chr(10)
		't = t + chr(10) + "Field Inter" + m.top.FindNode("VoteOverlaySlideIn").tostr()

		tt= ""
		if  m.viewpost.content <> invalid and m.viewpost.content.count() > 0 then
			for i = 0 to m.mainOverlay.getchildcount() -1
				if m.viewpost.content[i].overlays.count() > 0 and m.viewpost.content[i].overlays.type = "label" and m.viewpost.content[i].overlays.time <> invalid and m.viewpost.content[i].overlays.time >= m.viewpost.trt - m.viewpost.callFunc("timeleft")() then
					tt = tt + chr(10) + m.viewpost.content[i].overlays.type + " : " + m.viewpost.content[i].overlays.triggered.tostr() + ": [" + m.mainOverlay.getchild(i).translation[0].tostr() + "," + m.mainOverlay.getchild(i).translation[1].tostr() + "] " + m.mainOverlay.getchild(i).text
				else if m.overlays.count() > 0 and m.mainOverlay.getchild(i).subtype() = "Poster" then
					tt = tt + chr(10) + m.viewpost.content[i].overlays.type + " : " + m.viewpost.content[i].overlays.triggered.tostr() + ": [" + m.mainOverlay.getchild(i).translation[0].tostr() + "," + m.mainOverlay.getchild(i).translation[1].tostr() + "] " + m.mainOverlay.getchild(i).uri
				end if
			next
			t = t + tt
		end if

	else if m.viewpost.response <> invalid
		t = m.viewpost.response
	else
		'm.playerEpoch = m.playerEpoch +   m.segmenttimer.TotalSeconds() + m.viewpost.delay
		t = timestring(m.viewtimer.totalmilliseconds())
		't = t + chr(10) +  "Broadcast Delay : " +  (m.viewpost.serverepoch - m.playerEpoch).toStr()
		t = t + chr(10) +  "Bandwidth Used  : " +  m.viewpost.totalbandwidth.toStr() + " MB" 

	end if
	return t
end function


function onKeyEvent(key as String, press as Boolean) as Boolean
	? key
	? press
	? m.debugOverlay.visible
	if m.vote.enabled and press = true
		if  key = "up" then
			if m.vote.highlightIndex = -1 or m.vote.highlightIndex= 0 then
			else if m.vote.highlightIndex = 1 or m.vote.highlightIndex = 2 then
				m.vote.highlightIndex -= 1
			end if

		else if key = "down" then
			if m.vote.highlightIndex = -1 or m.vote.highlightIndex = 0 or m.vote.highlightIndex = 1 then
				m.vote.highlightIndex += 1
			end if

		else if key = "right" then
			hideVoting()
		end if

		if  key = "OK" and m.vote.highlightIndex > -1 then
			m.vote.voteIndex = m.vote.highlightIndex
			m.vote.castVote = true
			m.vote.control = "RUN"

		end if
		
		VotesChanged()
	else
		if press = true and m.vote.enabled = false and key = "left" then
			showVoting()
		end if
		if press = true and key = "play" then
			? m.viewpost.callFunc("playerEpoch")
			m.debugkeytimer = m.viewpost.callFunc("playerEpoch")
		end if

		if press = false and key = "play" and m.viewpost.callFunc("playerEpoch") >= m.debugkeytimer + 2000 then
			if m.debugOverlay.visible then 
				m.debugOverlay.visible = false 
				? "Hiding Debug"
				'stop
			else
				 m.debugOverlay.visible = true
				? "Showing Debug"
			end if
		end if
			
		if m.showvideoinfo = 0 and press = true then
		
			if key = "OK" then
				m.loadinglabel.text = "getting video info"
				? "Getting Video Info "
				m.videoinfo.userrating = -1
				m.videoinfo.epoch = m.viewpost.callFunc("playerEpoch")
				m.videoinfo.streamname = m.status.streamname
				m.videoinfo.control = "RUN"
			else 
			end if
			
		else if m.showvideoinfo = 1 and press = true and m.videoinfo.enable then
		
		m.showvideoinfotimer.mark()
		videoinfostarimage = m.top.findNode("starimage")
			if key = "left" then
				if m.videoinfo.userrating <= 20  then
					m.videoinfo.userrating = 0
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/0star.png"
				else if m.videoinfo.userrating = 40 then
					m.videoinfo.userrating = 20
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/1star.png"
				else if m.videoinfo.userrating = 60 or m.videoinfo.userrating = -1 then
					m.videoinfo.userrating = 40
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/2star.png"
				else if m.videoinfo.userrating = 80 then
					m.videoinfo.userrating = 60
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/3star.png"
				else if m.videoinfo.userrating = 100 then
					m.videoinfo.userrating = 80
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/4star.png"
				end if
			else if key = "right" then
				if m.videoinfo.userrating = 0 then
					m.videoinfo.userrating = 20
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/1star.png"
				else if m.videoinfo.userrating = 20 then
					m.videoinfo.userrating = 40
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/2star.png"
				else if m.videoinfo.userrating = 40 or m.videoinfo.userrating = -1 then
					m.videoinfo.userrating = 60
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/3star.png"
				else if m.videoinfo.userrating = 60 then
					m.videoinfo.userrating = 80
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/4star.png"
				else if m.videoinfo.userrating = 80 then
					m.videoinfo.userrating = 100
					videoinfostarimage.uri= "https://www.360tv.net/roku/theme/5star.png"
				end if
			else if key = "OK" then
				m.videoinfo.control = "RUN"
			end if
			
		end if
	end if
	if m.showvideoinfo = 1 and press = true then
		'if key = "right" then 
	end if
end function


    
function timestring(time as integer) as string
	if time >= 3600000 then hours = fix(time / 3600000) else hours = 0
	if time >= 60000 then minutes = fix((time - (hours * 3600000) )/ (60000)) else minutes = 0
	if time >= 1000 then seconds =  fix((time - (minutes * 60000) - (hours * 3600000) ) / 1000) else seconds = 0
	return hours.tostr() + "hrs " + minutes.tostr() + "min " + seconds.tostr() + "sec "  
end function

	
	
	
	

sub updateoverlays() as void
	? "Updating Overlays"
	xml=createobject("roXMLElement")
	xml.parse(m.viewpost.xml)
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
				newitem.node.translation = [strtoi(obj@x),strtoi(obj@y)]
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
				newitem.node.text = obj.gettext().Replace("%bw", m.viewpost.totalbandwidth.tostr()) 
				'newitem.node.font.role = "font"
				if obj@fonturi <> invalid then
					newitem.node.font.uri = obj@fonturi
				else if obj@font <> invalid then
					newitem.node.font = obj@font
				end if
				newitem.node.font.size = strtoi(obj@size)
				if obj@horizAlign <> invalid then newitem.node.horizAlign = obj@horizAlign
				newitem.node.translation = [strtoi(obj@x),strtoi(obj@y)]
				'newitem.node.triggered = false
				'stop
				'? "----"  + newitem.node.id 
				'? "----"  + newitem.node.font.uri + " " + newitem.node.font.size.tostr() + " - " + obj.gettext() + " " + newitem.node.horizAlign 
			end if
			if obj@time <> invalid then
				newitem.time = strtoi(obj@time)
				if m.top.TRT - m.top.timeleft >= newitem.time  and (m.top.trt - m.top.timeleft) < (strtoi(obj@time) + strtoi(obj@duration)) then 
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
end sub 

sub updatenextoverlays() as void
	? "Updating Next Overlays"
	xml=createobject("roXMLElement")
	xml.parse(m.viewpost.xml)
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
				newitem.node.translation = [strtoi(obj@x),strtoi(obj@y)]
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
				newitem.node.text = obj.gettext().Replace("%bw", m.viewpost.totalbandwidth.tostr()) 
				'newitem.node.font.role = "font"
				if obj@fonturi <> invalid then
					newitem.node.font.uri = obj@fonturi
				else if obj@font <> invalid then
					newitem.node.font = obj@font
				end if
				newitem.node.font.size = strtoi(obj@size)
				if obj@horizAlign <> invalid then newitem.node.horizAlign = obj@horizAlign
				newitem.node.translation = [strtoi(obj@x),strtoi(obj@y)]
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
		stop
	end if
end sub 

function randID() as string

	randkey = createobject("roArray", 5, true)
	for i = 0 to 5
		randkey[i] = (RND(0) * (65 - 90)) + 90
	next
	return chr(randkey[0]) + chr(randkey[1]) + chr(randkey[2]) + chr(randkey[3]) + chr(randkey[4]) + chr(randkey[5])
End Function

function on_open(event as object) as void
	'm.ws.send = ["Hello World"]
	? "Connected"
	date = createObject("roDateTime")
	date.mark()
	m.ws.send = ["{[""messageType"": ""login"", ""data"": { ""role"": ""ROKU"", ""datetime"": " +  date.AsSeconds().toStr() + ", ""regtoken"": """ + m.global.user.regtoken + """, ""sessionId"": "" " + m.viewpost.playid + " "" } }"]
	'm.ws.send = ["{[""messageType"": ""login"", ""data"": { ""role"": ""ROKU"", ""datetime"": " +  date.AsSeconds().toStr() + ", ""regtoken"": """ + m.global.user.regtoken + """, ""sessionId"": "" " + m.viewpost.playid + " """ } }]
end function



' Socket message event
function on_message(event as object) as void
	message = event.getData().message
	if type(message) = "roString"
		print "WebSocket text message: " + message
	else
		ba = createObject("roByteArray")
		for each byte in message
			ba.push(byte)
		end for
		print "WebSocket binary message: " + ba.toHexString()
	end if
end function
' Socket Error event
function on_error(event as object) as void
	print "WebSocket error"
	print event.getData()
end function

function post()

end function



    
'Fired on Each Segment Play
sub videoEvent(obj)
		field = obj.getfield()
		? "VideoEvent " + field
		if  field = "streamingSegment" then
			m.viewpost.setStreamingSegment = obj.getData()
		else if field = "downloadedSegment"
			m.viewpost.setDownloadedSegment = obj.getData()
		else if field = "positionInfo"
			m.viewpost.setPositionInfo = obj.getData()
		else if field = "streamInfo"
			m.viewpost.setStreamInfo = obj.getData()
		else if field = "playStartInfo"
			m.viewpost.setPlayStartInfo = obj.getData()
		else if field = "state"
			msg = obj.getData()
			m.viewpost.setState = msg

			if msg = "none" then
			else if msg = "paused" then
			else if msg = "stopped" then
			else if msg = "finished" then
			else if msg = "playing" then
				m.segmentTimer.mark()
				m.highResTick.control = "start"
				m.loadinglabel.text = "playing"
				m.loadingoverlayfadeout.control = "start"
			else if msg = "buffering" then 
				m.loadinglabel.text = "buffering"
				if m.loadingoverlay.opacity = 1 then m.loadingoverlayfadein.control = "start"
			else if msg = "error" then 
				index = obj
				? index
				m.loadinglabel.text = "error"
				if m.loadingoverlay.opacity = 1 then m.loadingoverlayfadein.control = "start"
			end if
		else if field = "errorCode"
			? obj.getdata()
		else if field = "errorMsg"
			? obj.getdata()
		else if field = "errorStr"
			? obj.getdata()
		else if field = "errorInfo"
			? obj.getdata()
		else if field = "errorCode"
			? obj.getdata()
		else
			? obj
		end if
end sub
