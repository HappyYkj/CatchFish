local function main (userOb, msgData)
    return FREE_ARENA_D:hit_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SFreeArenaHit", GameCmdType.DESK, main)
