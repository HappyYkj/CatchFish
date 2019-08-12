local function main (userOb, msgData)
    return VIOLENT_D:set_violent(userOb, msgData.nRatio)
end

COMMAND_D:register_command("MSGC2SSetViolentRatio", GameCmdType.DESK, main)
