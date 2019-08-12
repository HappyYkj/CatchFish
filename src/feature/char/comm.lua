local json = require "json"

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

local M = {}

function M:send_packet(MsgType, MsgValue, exclude_player_ids)
    if type(exclude_player_ids) == "table" then
        for _, playerId in ipairs(exclude_player_ids) do
            if playerId ==self then
                return
            end
        end
    elseif type(exclude_player_ids) == "number" then
        local playerId = exclude_player_ids
        if playerId == self then
            return
        end
    end

    local clientId = self:query_temp("clientId")
    if not clientId then
        return
    end

    local clientAddr = self:query_temp("clientAddr")
    if not clientAddr then
        return
    end

    local root = {}
    root["UserName"] = clientId
    root["SendTime"] = os.time()
    root["Sender"] = "game_channel_lua"
    root["MsgData"] = { MsgType = MsgType, MsgValue = MsgValue, }
    THREAD_D:post("client_channel", clientAddr, json.encode(root))
end

function M:send_group_packet(MsgType, MsgValue)
    if self:get_desk() then
        return
    end

    self:send_packet(MsgType, MsgValue)
end

function M:send_desk_packet(MsgType, MsgValue)
    if not self:get_desk() then
        return
    end

    self:send_packet(MsgType, MsgValue)
end

function M:brocast_packet(MsgType, MsgValue, exclude_player_ids)
    local desk = self:get_desk()
    if desk then
        desk:brocast_packet(MsgType, MsgValue, exclude_player_ids)
        return
    end

    self:brocast_group_packet(MsgType, MsgValue, exclude_player_ids)
end

function M:brocast_group_packet(MsgType, MsgValue, exclude_player_ids)
    if self:get_desk() then
        return
    end

    self:send_packet(MsgType, MsgValue, exclude_player_ids)
end

function M:brocast_desk_packet(MsgType, MsgValue, exclude_player_ids)
    local desk = self:get_desk()
    if not desk then
        return
    end
    
    desk:brocast_packet(MsgType, MsgValue, exclude_player_ids)
end

F_CHAR_COMM = M
