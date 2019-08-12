local function main (userOb, msgData)
    return LIMIT_ARENA_D:hit_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SLimitArenaHit", GameCmdType.DESK, main)
