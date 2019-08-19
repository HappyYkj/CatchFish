local function main (userOb, msgData)
    local vip_config = VIP_CONFIG:get_config_by_vip_level(msgData.vipLv)
    if not vip_config then
        -- 配置不存在
        return
    end

    if userOb:get_vip_grade() < msgData.vipLv then
        -- 玩家还未达到此vip等级
        return
    end

    local gift_sign = userOb:get_gift_sign()
    if gift_sign & (1 << msgData.vipLv) ~= 0 then
        -- 已领取奖励
        return
    end

    ---! 设置已领取
    userOb:set_gift_sign(gift_sign | (1 << msgData.vipLv))

    ---! 通知客户端属性变更
    local result = {}
    result.attrs = { { attrKey = 4, attrValue = userOb:get_gift_sign(), } }
    userOb:send_packet("MSGS2CNotifyPlayerAttrs", result)

    ---! 给与奖励
    local props, senior_props = ITEM_D:give_user_props(userOb, vip_config.vipGift, PropChangeType.kPropChagneTypeGetVipGift)

    ---! 通知给奖励信息
    local result = {}
    result.playerId = userOb:get_id()
    result.dropProps = props
    result.dropSeniorProps = senior_props
    result.source = "MSGC2SRequestGetVipGift"
    userOb:brocast_packet("MSGS2CUpdatePlayerProp", result)
end

COMMAND_D:register_command("MSGC2SRequestGetVipGift", GameCmdType.NONE, main)
