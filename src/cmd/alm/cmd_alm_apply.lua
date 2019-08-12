local function main (userOb, msgData)
    return ALM_D:apply_alm(userOb)
end

COMMAND_D:register_command("MSGC2SApplyAlm", GameCmdType.DESK, main)
