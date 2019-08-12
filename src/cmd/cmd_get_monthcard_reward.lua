local function main (userOb, msgData)
    ---! 获取剩余月卡天数
    if userOb:get_monthcard_left_days() <= 0 then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CGetMonthCardReward", result)
        return
    end

    ---! 获取是否已经领取月卡奖励
    if userOb:get_monthcard_reward_token() then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CGetMonthCardReward", result)
        return
    end

    ---! 标记奖励已领取
    userOb:set_monthcard_reward_token()

    ---! 给予月卡奖励
    local props = {}
    local seniorProps = {}
    print(serialize(FISH_SERVER_CONFIG.monthCardConfig))
    for propId, propCount in pairs(FISH_SERVER_CONFIG.monthCardConfig) do repeat
        local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
        if not itemConfig then
            break
        end

        if not itemConfig.if_senior then
            userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChangeTypeMonthCard)
            props[#props + 1] = { propId = propId, propCount = propCount, }
            break
        end

        for idx = 1, propCount do 
            seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
        end
    until true end

    ---! 领取成功
    local result = {}
    result.isSuccess = true
    result.rewardItems = props
    result.seniorProps = seniorProps
    userOb:send_packet("MSGS2CGetMonthCardReward", result)

    ---! 广播消息
    local result = {}
    result.playerId = userOb:get_id()
    result.source = "MSGS2CGetMonthCardReward"
    result.dropProps = props
    result.dropSeniorProps = seniorProps
    userOb:brocast_packet("MSGS2CUpdatePlayerProp", result, userOb)
end

COMMAND_D:register_command("MSGC2SGetMonthCardReward", GameCmdType.NONE, main)
