local function main (userOb, msgData)
    USER_D:send_hall_info(userOb)
end

COMMAND_D:register_command("MSGC2SGetHallInfo", GameCmdType.NONE, main)
