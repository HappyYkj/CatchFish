local function main (userOb, msgData)
    return LOGIN_D:logout(userOb)
end

COMMAND_D:register_command("MSG_DISCONNECT", GameCmdType.NONE, main)
