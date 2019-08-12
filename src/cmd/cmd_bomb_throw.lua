local function main (userOb, msgData)
    return BULLET_D:throw_bomb(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SNBomb", GameCmdType.DESK, main)
