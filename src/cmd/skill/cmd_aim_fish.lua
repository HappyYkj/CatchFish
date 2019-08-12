local function main (userOb, msgData)
    return AIM_D:start_aim(userOb, msgData.useType, msgData.fishArrayId, msgData.timelineId)
end

COMMAND_D:register_command("MSGC2SAim", GameCmdType.DESK, main)
