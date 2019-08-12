local function main (userOb, msgData)
    CANNON_D:change_gunrate(userOb, msgData.newGunRate)
end

COMMAND_D:register_command("MSGC2SGunRateChange", GameCmdType.NONE, main)
