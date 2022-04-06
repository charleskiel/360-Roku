
sub init()
    m.top.functionName = "executeTask"
    'm.top.ObserveField("nowpos", "executeTask")
end sub

function executeTask() as void
    posttimer = createobject("rotimespan")

    
    
    
    
    user = createobject("roAssociativeArray")
    xml=createobject("roXMLElement")
    url = m.global.config.userinfo + m.global.urlparams + m.global.userparams
    ? url
    http = createObject("roUrlTransfer")
    http.RetainBodyOnError(true)
    port = createObject("roMessagePort")
    http.setPort(port)
    http.setCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    http.enablehostverification(false)
    http.enablepeerverification(false)
    http.setUrl(url)
    posttimer.mark()
    if http.AsyncGetToString() Then
        msg = wait(6000, port)
        if (type(msg) = "roUrlEvent")
            'HTTP response code can be <0 for Roku-defined errors
            if (msg.getresponsecode() > 0 and  msg.getresponsecode() < 400)
                ? "Got User Info in " + posttimer.totalmilliseconds().tostr()
                'stop
                if xml.parse(msg.getstring())
                    user.clear()
                    user.regtoken = xml.regtoken.gettext()
                    user.firstname = xml.firstname.gettext()
                    user.lastname = xml.lastname.gettext()
                    user.city = xml.city.gettext()
                    user.state = xml.state.gettext()
                    user.country = xml.country.gettext()
                    user.zip = xml.zip.gettext()
                    user.lat = xml.lat.gettext()
                    user.lng = xml.lng.gettext()
                    user.timezone = strtoi(xml.timezone.gettext())
                    user.poweruser = strtoi(xml.poweruser.gettext())
                    user.admin = strtoi(xml.admin.gettext())
                    user.verified = strtoi(xml.verified.gettext())
                    user.active = strtoi(xml.active.gettext())
                    user.suspended = strtoi(xml.suspended.gettext())
                    user.regdays = strtoi(xml.regdays.gettext())
                    user.UTC = xml.UTC.gettext()
                    user.DST = xml.DST.gettext()
                    user.preroll = 0
                    m.global.user = user
                    '? m.global.user
                    'stop
                else
                ? "feed load failed: "; msg.getfailurereason();" "; msg.getresponsecode();" "; m.top.url
                    m.top.response = "ERROR"
                    ? "*****************************************************************************************************************"
                    ? msg.getString()
                    ? "*****************************************************************************************************************"
                end if
                http.asynccancel()
            else
                ? msg.getresponsecode().tostr() + " " + msg.getfailurereason() + ": Bad Response"
            end if
        else if (msg = invalid)
                ? "feed load failed."
            m.top.response =""
            http.asynccancel()
        end if
    end if
    
    m.top.control = "stop"
end function