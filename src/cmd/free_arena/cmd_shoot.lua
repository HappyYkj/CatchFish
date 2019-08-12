local function main (userOb, msgData)
    return FREE_ARENA_D:shoot_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SFreeArenaShoot", GameCmdType.DESK, main)
