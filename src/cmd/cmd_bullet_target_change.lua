local function main (userOb, msgData)
    for _, bulletId in ipairs(msgData.bullets) do
        userOb:get_desk():change_bullet_target(userOb:get_id(), bulletId, msgData.timelineId, msgData.fishArrayId)
    end
    
    ---! 广播消息
    local result = {}
    result.playerId = userOb:get_id()
    result.bullets = msgData.bullets
    result.timelineId = msgData.timelineId
    result.fishArrayId = msgData.fishArrayId
    userOb:brocast_packet("MSGS2CBulletTargetChange", result)
end

COMMAND_D:register_command("MSGC2SBulletTargetChange", GameCmdType.DESK, main)
