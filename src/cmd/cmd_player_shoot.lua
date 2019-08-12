local function main (userOb, msgData)
    BULLET_D:send_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SPlayerShoot", GameCmdType.DESK, main)
