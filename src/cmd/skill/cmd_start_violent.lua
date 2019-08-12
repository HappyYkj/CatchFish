local function main (userOb, msgData)
    return VIOLENT_D:start_violent(userOb, msgData.useType)
end

COMMAND_D:register_command("MSGC2SViolent", GameCmdType.DESK, main)
