local function main (userOb, msgData)
    return ALM_D:send_alm_info(userOb)
end

COMMAND_D:register_command("MSGC2SAlmInfo", GameCmdType.NONE, main)
