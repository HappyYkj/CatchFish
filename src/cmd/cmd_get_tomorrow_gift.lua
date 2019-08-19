local function main (userOb, msgData)
    ---! 是否有明日礼包
    local senior_prop = userOb:get_senior_prop_by_id(GamePropIds.kGamePropIdsTomorrowGift)
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
    local props, senior_props = ITEM_D:give_user_props(userOb, FISH_SERVER_CONFIG.tomorrowGifts, PropChangeType.kPropChangeTomorrowGift)

    ---! 广播消息
    local result = {}
    result.errorCode = 0
    result.playerId = userOb:get_id()
    result.props = props
    result.seniorProps = senior_props
    userOb:brocast_packet("MSGS2CGetTomorrowGift", result)
end

COMMAND_D:register_command("MSGC2SGetTomorrowGift", GameCmdType.NONE, main)
