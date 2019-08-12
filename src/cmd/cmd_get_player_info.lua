local function main (userOb, msgData)
    if msgData.playerId <= 0 then
        local result = {}
        result.isSuccess = true
        result.playerInfo = userOb:generate_player_info()
        userOb:send_packet("MSGS2CGetPlayerInfo", result)
        return
    end

    local player = USER_D:find_user(msgData.playerId)
    if not player then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CGetPlayerInfo", result)
    end

    local result = {}
    result.isSuccess = true
    result.playerInfo = player:generate_player_info()
    userOb:send_packet("MSGS2CGetPlayerInfo", result)
end

COMMAND_D:register_command("MSGC2SGetPlayerInfo", GameCmdType.NONE, main)
