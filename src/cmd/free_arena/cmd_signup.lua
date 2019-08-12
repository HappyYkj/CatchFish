local function main (userOb, msgData)
    return FREE_ARENA_D:signup(userOb, msgData.arenaType, msgData.signupType)
end

COMMAND_D:register_command("MSGC2SFreeArenaSignUp", GameCmdType.HALL, main)
