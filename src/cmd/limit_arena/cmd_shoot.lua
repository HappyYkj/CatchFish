local function main (userOb, msgData)
    return LIMIT_ARENA_D:shoot_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SLimitArenaShoot", GameCmdType.DESK, main)
