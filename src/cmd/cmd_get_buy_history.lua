local function main (userOb, msgData)
    local result = {}
    result.playerId = userOb:get_id()
    result.getType = msgData.getType
    result.buyHistory = userOb:get_buy_history(msgData.getType)
    userOb:send_packet("MSGS2CGetBuyHistory", result)
end

COMMAND_D:register_command("MSGC2SGetBuyHistory", GameCmdType.NONE, main)
