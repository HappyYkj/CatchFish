local function main (userOb, msgData)
    local config = LEVEL_CONFIG:get_config_by_level(1)
    if not config then
        -- 奖励配置已丢失
        local result = {}
        result.errorCode = -1
        userOb:send_packet("MSGS2CGetNewerReward", result)
        return
    end

    ---! 是否有启航礼包
    local senior_prop = userOb:get_senior_prop_by_id(GameSeniorPropIds.kGameSeniorPropIdsNewbieGift)
    if not senior_prop then
        local result = {}
        result.errorCode = -1
        result.playerId = userOb:get_id()
        userOb:send_packet("MSGS2CGetTomorrowGift", result)
        return
    end

    ---! 删除启航礼包
    userOb:erase_senior_prop(senior_prop.propItemId)

    ---! 给予礼包奖励
    local props = {}
    local seniorProps = {}
    for propId, propCount in pairs(config.level_reward) do repeat
        local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
        if not itemConfig then
            break
        end

        if not itemConfig.if_senior then
            userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTypeNewerReward)
            props[#props + 1] = { propId = propId, propCount = propCount, }
            break
        end

        for idx = 1, propCount do 
            seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
        end
    until true end

    ---! 广播消息
    local result = {}
    result.errorCode = 0
    result.props = props
    userOb:brocast_packet("MSGS2CGetNewerReward", result)
end

COMMAND_D:register_command("MSGC2SGetNewerReward", GameCmdType.NONE, main)
