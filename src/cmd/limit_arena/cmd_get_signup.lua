local function main (userOb, msgData)
    return LIMIT_ARENA_D:send_signup_info(userOb, msgData.arenaType)
end

COMMAND_D:register_command("MSGC2SLimitArenaGetSignup", GameCmdType.HALL, main)
