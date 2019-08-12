local function main (userOb, msgData)
    BULLET_D:hit_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SPlayerHit", GameCmdType.DESK, main)
