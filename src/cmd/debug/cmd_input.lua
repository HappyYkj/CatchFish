local function main (userOb, msgData)
    return CLIENT_DEBUG_D:input_command(userOb, msgData.cmd)
end

COMMAND_D:register_command("MSGC2SConsoleCmd", GameCmdType.NONE, main)
