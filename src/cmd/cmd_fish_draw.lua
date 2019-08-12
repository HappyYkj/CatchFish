local function main (userOb, msgData)
    return FISH_DRAW_D:draw(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SDraw", GameCmdType.DESK, main)
