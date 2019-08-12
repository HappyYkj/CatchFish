local json = require "json"

LISTEN_D:register_listen_channel("login_channel", function (data)
    local recv = json.decode(data)
    if not recv then
        spdlog.warn("login_channel", string.format("parse error, data : %s", data));
        return
    end

    if not recv.SendTime then
        spdlog.warn("login_channel", string.format("member[SendTime] type error, data : %s", data));
        return
    end
    
    if recv.SendTime + 30 < os.time() then
        spdlog.warn("login_channel", string.format("member[SendTime] too long, data : %s", data));
        return
    end
    
    if not recv.Sender then
        spdlog.warn("login_channel", string.format("member[Sender] type error, data : %s", data));
        return
    end
    
    if not recv.userName then
        spdlog.warn("login_channel", string.format("member[userName] type error, data : %s", data));
        return
    end
    
    if not recv.MsgData then
        spdlog.warn("login_channel", string.format("member[MsgData] type error, data : %s", data));
        return
    end

    LOGIN_D:login(recv.SendTime, recv.Sender, recv.userName, recv.MsgData)
end)
