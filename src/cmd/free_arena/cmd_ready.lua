local function main (userOb, msgData)
    return FREE_ARENA_D:go_ready(userOb)
end

COMMAND_D:register_command("MSGC2SFreeArenaReady", GameCmdType.DESK, main)
