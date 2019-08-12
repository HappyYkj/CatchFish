local function main (userOb, msgData)
    BULLET_D:batch_bullet(userOb, msgData)
end

COMMAND_D:register_command("MSGC2SBatchShoot", GameCmdType.DESK, main)
