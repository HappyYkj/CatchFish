local function main (userOb, msgData)
    return FREE_ARENA_D:cancel_signup(userOb, msgData.arenaType)
end

COMMAND_D:register_command("MSGC2SFreeArenaCancelSignup", GameCmdType.HALL, main)
