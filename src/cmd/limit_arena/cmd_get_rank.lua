local function main (userOb, msgData)
    return LIMIT_ARENA_D:send_rank_info(userOb, msgData.arenaType)
end

COMMAND_D:register_command("MSGC2SLimitArenaRank", GameCmdType.NONE, main)
