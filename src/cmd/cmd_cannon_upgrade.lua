local function main (userOb, msgData)
    return CANNON_D:upgrade_gunrate(userOb, msgData.gunRate)
end

COMMAND_D:register_command("MSGC2SUpgradeCannon", GameCmdType.NONE, main)
