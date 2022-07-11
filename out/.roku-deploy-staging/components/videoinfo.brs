
sub init()
    m.top.functionName = "executeTask"
end sub

function executeTask() as void
	postBody = FormatJson({
		"esn" : m.global.device.esn
		"user" : m.global.user,
		"playerEpoch" : m.top.epoch,
		"channelNumber" : 0,
		"playID" : m.top.playID,
		"action" : "INFO"
	})
	'? postBody
	response = get("https://360tv.net/api/v1/channelStatus?channel=0")
	? response
	j = ParseJson(response)
	? j
	if j <> invalid and j.count() > 0 then 
		content = []
		for each channel in j
		
			for each item in channel["runlog"]
				' ? item
				content.push({
					artist : item["content"]["artist"],
					title : item["content"]["title"],
					contentEndEpoch : item["contentEndEpoch"],
					contentEpoch : item["contentEpoch"],
					TRT : item["content"]["trt"],
					titleIn : item["content"]["titlein"],
					titleOut : item["content"]["titleout"],
					timestamp : item["timestamp"],
					overlay : item["overlay"],
					mode : item["mode"]
				})
			end for
		end for

		m.top.content = content
	else
		' m.top.playOK = false
	end if


	m.top.control = "stop"
end function

