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
    local props, senior_props = ITEM_D:give_user_props(userOb, FISH_SERVER_CONFIG.monthCardConfig, PropChangeType.kPropChangeTypeMonthCard)

    ---! 领取成功
    local result = {}
    result.isSuccess = true
    result.rewardItems = props
    result.seniorProps = senior_props
    userOb:send_packet("MSGS2CGetMonthCardReward", result)

    ---! 广播消息
    local result = {}
    result.playerId = userOb:get_id()
    result.source = "MSGS2CGetMonthCardReward"
    result.dropProps = props
    result.dropSeniorProps = senior_props
    userOb:brocast_packet("MSGS2CUpdatePlayerProp", result, userOb)
end

COMMAND_D:register_command("MSGC2SGetMonthCardReward", GameCmdType.NONE, main)
