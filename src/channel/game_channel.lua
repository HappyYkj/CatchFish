local json = require "cjson"

SERVICE_D:register("game_channel_lua", function (linda, data)
    local recv = json.decode(data)
    if not recv then
        spdlog.warn("game_channel", string.format("parse error, data : %s", data));
        return
    end

    if not recv.SendTime then
        spdlog.warn("game_channel", string.format("member[SendTime] type error, data : %s", data));
        return
    end

    if recv.SendTime + 30 < os.time() then
        spdlog.warn("game_channel", string.format("member[SendTime] too long, data : %s", data));
        return
    end

    if not recv.Sender then
        spdlog.warn("game_channel", string.format("member[Sender] type error, data : %s", data));
        return
    end

    if not recv.userName then
        spdlog.warn("game_channel", string.format("member[userName] type error, data : %s", data));
        return
    end

    if not recv.MsgData then
        spdlog.warn("game_channel", string.format("member[MsgData] type error, data : %s", data));
        return
    end

    local MsgData = {}
    if recv.MsgData ~= "" then
        local ok
        ok, MsgData = pcall(json.decode, recv.MsgData)
        if not ok then
            spdlog.warn("game_channel", string.format("member[MsgData] parse error, data : %s", data));
            return
        end
    end

    COMMAND_D:process_command(recv.userName, recv.MsgType, MsgData)
end)
