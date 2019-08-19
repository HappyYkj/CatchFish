local function main (userOb, msgData)
    return SHOP_D:buy_prop(player, msgData.propId, msgData.count)
end

COMMAND_D:register_command("MSGC2SBuy", GameCmdType.NONE, main)
