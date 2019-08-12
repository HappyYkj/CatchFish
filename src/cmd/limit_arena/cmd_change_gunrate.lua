local function main (userOb, msgData)
    return LIMIT_ARENA_D:change_gunrate(userOb, msgData.newGunRate)
end

COMMAND_D:register_command("MSGC2SLimitArenaGunRateChange", GameCmdType.DESK, main)
