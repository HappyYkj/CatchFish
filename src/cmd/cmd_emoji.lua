local function main (userOb, msgData)
    local config = EMOJI_CONFIG:get_config_by_id(msgData.emoticonId)
    if not config then
        -- 表情不存在
        local result = {}
        result.isSuccess = false
        result.emoticonId = msgData.emoticonId
        result.playerId = userOb:get_id()
        userOb:send_packet("MSGS2CEmoticon", result)
        return
    end

    if config.crystal_need > 0 and userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal) < config.crystal_need then
        -- 水晶不足
        local result = {}
        result.isSuccess = false
        result.emoticonId = msgData.emoticonId
        result.playerId = userOb:get_id()
        userOb:send_packet("MSGS2CEmoticon", result)
        return
    end

    if config.crystal_need > 0 then
        -- 扣除水晶
        userOb:change_prop_count(GamePropIds.kGamePropIdsCrystal, -config.crystal_need, PropRecieveType.kPropChangeTypeUseCrystal)
    
        -- 同步水晶
        ----todo：需要向客户端广播同步水晶数据

        -- 记录日志
    end

    ---! 使用成功
    local result = {}
    result.isSuccess = true
    result.emoticonId = msgData.emoticonId
    result.playerId = userOb:get_id()
    userOb:brocast_packet("MSGS2CEmoticon", result)
end

COMMAND_D:register_command("MSGC2SEmoticon", GameCmdType.DESK, main)
