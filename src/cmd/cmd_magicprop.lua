local function main (userOb, msgData)
    local config = MAGICPROP_CONFIG:get_config_by_id(msgData.magicpropId)
    if not config then
        -- 配置不存在
        local result = {}
        result.isSuccess = false
        result.playerId = userOb:get_id()
        result.toPlayerID = msgData.toPlayerID
        result.magicpropId = msgData.magicpropId
        userOb:send_packet("MSGS2CMagicprop", result)
        return
    end

    if config.crystal_need > 0 and userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal) < config.crystal_need then
        -- 水晶不足
        local result = {}
        result.isSuccess = false
        result.playerId = userOb:get_id()
        result.toPlayerID = msgData.toPlayerID
        result.magicpropId = msgData.magicpropId
        userOb:send_packet("MSGS2CMagicprop", result)
        return
    end

    if config.crystal_need > 0 then
        -- 扣除水晶
        userOb:change_prop_count(GamePropIds.kGamePropIdsCrystal, -config.crystal_need, PropRecieveType.kPropChangeTypeUseCrystal)
    
        -- 同步水晶
        ----todo：

        -- 记录日志
        ----todo：
    end

    ---! 使用成功
    local result = {}
    result.isSuccess = true
    result.playerId = userOb:get_id()
    result.toPlayerID = msgData.toPlayerID
    result.magicpropId = msgData.magicpropId
    userOb:brocast_packet("MSGS2CMagicprop", result)
end

COMMAND_D:register_command("MSGC2SMagicprop", GameCmdType.DESK, main)
