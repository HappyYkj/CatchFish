local function main (userOb, msgData)
    ---! 获取签到天数
    local days = userOb:get_days()

    ---! 获取签到标记
    local sign = userOb:get_sign()

    ---! 是否有明日礼包
    local senior_prop = userOb:get_senior_prop_by_id(GamePropIds.kGamePropIdsTomorrowGift)
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

    ---! 普通签到奖励
    local rewards = {}
    for prop_id, prop_count in pairs(config.reward_props) do
        rewards[prop_id] = prop_count
    end

    ---! vip额外奖励
    if userOb:get_vip_grade() >= config.vip then
        for prop_id, prop_count in pairs(config.vip_props) do
            if rewards[prop_id] then
                rewards[prop_id] = rewards[prop_id] + prop_count
            else
                rewards[prop_id] = prop_count
            end
        end
    end

    ---! 发放签到奖励
    local props, senior_props = ITEM_D:give_user_props(userOb, rewards, PropChangeType.kPropChangeTypeSignIn)

    local result = {}
    result.isSuccess = true
    result.newSignInDays = userOb:get_days()
    result.sign = userOb:get_sign()
    result.props = props
    result.seniorProps = senior_props
    userOb:brocast_packet("MSGS2CSignIn", result)
end

COMMAND_D:register_command("MSGC2SSignIn", GameCmdType.NONE, main)
