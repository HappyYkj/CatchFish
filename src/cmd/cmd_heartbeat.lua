local function main (userOb, msgData)
    local result = {}
    result.frameCount = userOb:get_desk():get_frame_count()
    userOb:brocast_packet("MSGS2CHeartBeat", result)
end

COMMAND_D:register_command("MSGC2SHeartBeat", GameCmdType.DESK, main)
