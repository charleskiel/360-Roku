
sub init()
    m.top.functionName = "executeTask"
    
    'm.top.ObserveField("nowpos", "executeTask")
end sub

function executeTask() as void
	posttimer = createobject("rotimespan")
	postBody = FormatJson({
		"device" : m.global.device,
		"user" : m.global.userinfo
		"epoch" : m.top.playerepoch,
		"playID" : m.top.PlayID,
		"action" : "PLAY",
		"position" : m.top.nowpos,
		"screenmode" : m.top.screenmode,
		"epoch" : m.top.playerepoch,
		"streamname" : m.top.streamname,
		"bandwidth" : m.top.totalbandwidth
	})
	data = post(m.global.config.userinfo) 
	
	m.top.regcode = data.regcode
	m.top.regtoken = data.regtoken
	m.top.firstname = data.firstname
	m.top.lastname = data.lastname
	m.top.city = data.city
	m.top.state = data.state
	m.top.country = data.country
	m.top.zip = data.zip
	m.top.lat = data.lat
	m.top.lng = data.lng
	m.top.timezone = strtoi(data.timezone)
	m.top.poweruser = strtoi(data.poweruser)
	m.top.admin = strtoi(data.admin)
	m.top.verified = strtoi(data.verified)
	m.top.active = strtoi(data.active)
	m.top.suspended = strtoi(data.suspended)
	m.top.regdays = strtoi(data.regdays)
	m.top.UTC = data.UTC
	m.top.DST = data.DST
	m.top.preroll = 0
				
	'm.top.response = msg.getstring()
	'? "Got User Info"
	'? m.top
	'? "feed load failed: "; msg.getfailurereason();" "; msg.getresponsecode();" "; m.top.url

	m.top.control = "stop"
end function