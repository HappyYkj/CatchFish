local function main (userOb, msgData)
    return CANNON_D:forge_cannon(userOb, msgData.useCrystalPower)
end

COMMAND_D:register_command("MSGC2SForge", GameCmdType.NONE, main)
