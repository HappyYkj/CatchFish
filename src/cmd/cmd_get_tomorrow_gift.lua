local function main (userOb, msgData)
    ---! 是否有明日礼包
    local senior_prop = userOb:get_senior_prop_by_id(GameSeniorPropIds.kGameSeniorPropIdsTomorrowGift)
    if not senior_prop then
        local result = {}
        result.errorCode = -1
        result.playerId = userOb:get_id()
        userOb:send_packet("MSGS2CGetTomorrowGift", result)
        return
    end

    ---! 是否可以领取礼包
    local ti = os.date("*t")
    ti.hour, ti.min, ti.sec = 0, 0, 0
    if os.time(ti) < senior_prop.intProp1 then
        local result = {}
        result.errorCode = -1
        result.playerId = userOb:get_id()
        userOb:send_packet("MSGS2CGetTomorrowGift", result)
        return
    end

    ---! 删除明日礼包
    userOb:erase_senior_prop(senior_prop.propItemId)

    ---! 给予礼包奖励
    local props = {}
    local seniorProps = {}
    for propId, propCount in pairs(FISH_SERVER_CONFIG.tomorrowGifts) do repeat
        local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
        if not itemConfig then
            break
        end

        if not itemConfig.if_senior then
            userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTomorrowGift)
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
    result.playerId = userOb:get_id()
    result.props = props
    result.seniorProps = seniorProps
    userOb:brocast_packet("MSGS2CGetTomorrowGift", result)
end

COMMAND_D:register_command("MSGC2SGetTomorrowGift", GameCmdType.NONE, main)
