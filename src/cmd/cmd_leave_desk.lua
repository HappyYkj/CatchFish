local function main (userOb, msgData)
    ROOM_D:leave_desk(userOb, true)
end

COMMAND_D:register_command("MSGC2SLeaveDesk", GameCmdType.DESK, main)
