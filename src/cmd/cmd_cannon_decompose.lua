local function main (userOb, msgData)
    return CANNON_D:decompose_cannon(userOb, msgData.propId)
end

COMMAND_D:register_command("MSGC2SDecompose", GameCmdType.NONE, main)
