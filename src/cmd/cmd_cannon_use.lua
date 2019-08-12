local function main (userOb, msgData)
    return CANNON_D:use_cannon(userOb, msgData.propID, msgData.useType)
end

COMMAND_D:register_command("MSGC2SUsePropCannon", GameCmdType.NONE, main)
