local function main (userOb, msgData)
    ---! 获取签到天数
    local days = userOb:get_days()

    ---! 获取签到标记
    local sign = userOb:get_sign()

    ---! 是否有明日礼包
    local senior_prop = userOb:get_senior_prop_by_id(GameSeniorPropIds.kGameSeniorPropIdsTomorrowGift)
    if senior_prop then
        local result = {}
        result.isSuccess = false
        result.newSignInDays = days
        result.sign = sign
        userOb:send_packet("MSGS2CSignIn", result)
        return
    end

    ---! 获取签到标记
    if sign then
        local result = {}
        result.isSuccess = false
        result.newSignInDays = days
        result.sign = sign
        userOb:send_packet("MSGS2CSignIn", result)
        return
    end

    local config = CHECKIN_CONFIG:get_config_by_day(days + 1)
    if not config then
        local result = {}
        result.isSuccess = false
        result.newSignInDays = days
        result.sign = sign
        userOb:send_packet("MSGS2CSignIn", result)
        return
    end

    ---! 累加签到天数
    userOb:add_days()

    ---! 设置签到标记
    userOb:set_sign()

    local props = {}
    local seniorProps = {}
    
    ---! 发放签到奖励
    for propId, propCount in pairs(config.reward_props) do repeat
        local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
        if not itemConfig then
            break
        end

        if not itemConfig.if_senior then
            userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTypeSignIn)
            props[#props + 1] = { propId = propId, propCount = propCount, }
            break
        end

        for idx = 1, propCount do 
            seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
        end
    until true end
    
    ---! vip额外奖励
    if userOb:get_vip_grade() >= config.vip then
        for propId, propCount in pairs(config.vip_props) do repeat
            local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
            if not itemConfig then
                break
            end

            if not itemConfig.if_senior then
                userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTypeSignIn)
                props[#props + 1] = { propId = propId, propCount = propCount, }
                break
            end

            for idx = 1, propCount do 
                seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
            end
        until true end
    end

    local result = {}
    result.isSuccess = true
    result.newSignInDays = userOb:get_days()
    result.sign = userOb:get_sign()
    result.props = props
    result.seniorProps = seniorProps
    userOb:brocast_packet("MSGS2CSignIn", result)
end

COMMAND_D:register_command("MSGC2SSignIn", GameCmdType.NONE, main)
