local function main (userOb, msgData)
    return LIMIT_ARENA_D:go_ready(userOb, msgData.arenaType)
end

COMMAND_D:register_command("MSGC2SLimitArenaReady", GameCmdType.DESK, main)
