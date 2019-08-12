local function main (userOb, msgData)
    return LIMIT_ARENA_D:signup(userOb, msgData.arenaType, msgData.signupType)
end

COMMAND_D:register_command("MSGC2SLimitArenaSignUp", GameCmdType.HALL, main)
