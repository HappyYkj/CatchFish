local function main (userOb, msgData)
    return CALL_D:call_fish(userOb, msgData.useType)
end

COMMAND_D:register_command("MSGC2SCallFish", GameCmdType.DESK, main)
