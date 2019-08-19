local function main (userOb, msgData)
    return SHOP_D:send_exchange_info(userOb)
end

COMMAND_D:register_command("MSGC2SGetChangePropInfo", GameCmdType.NONE, main)
