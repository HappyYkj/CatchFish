local function main (userOb, msgData)
    return BULLET_D:blast_bomb(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SNBombBlast", GameCmdType.DESK, main)
