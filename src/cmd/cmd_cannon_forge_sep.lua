local function main (userOb, msgData)
    return CANNON_D:forge_seperate_cannon(userOb)
end

COMMAND_D:register_command("MSGC2SSeperateGunForge", GameCmdType.NONE, main)
