local function main (userOb, msgData)
    return SHOP_D:exchange_prop(userOb, msgData.changeId, msgData.count)
end

COMMAND_D:register_command("MSGC2SChangeProp", GameCmdType.NONE, main)
