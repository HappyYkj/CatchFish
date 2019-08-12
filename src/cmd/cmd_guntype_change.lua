local function main (userOb, msgData)
    CANNON_D:change_guntype(userOb, msgData.newGunType)
end

COMMAND_D:register_command("MSGC2SGunTpyeChange", GameCmdType.NONE, main)
