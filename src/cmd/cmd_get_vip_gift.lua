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
    local props = {}
    local seniorProps = {}
    for propId, propCount in pairs(vip_config.vipGift) do repeat
        local item_config = ITEM_CONFIG:get_config_by_id(propId)
        if not item_config then
            break
        end
        
        if not item_config.if_senior then
            userOb:change_prop_count(propId, propCount, PropRecieveType.kPropChagneTypeGetVipGift)
            props[#props + 1] = { propId = propId, propCount = propCount, }
        else
            for idx = 1, propCount do 
                seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
            end
        end
    until true end

    ---! 通知给奖励信息
    local result = {}
    result.playerId = userOb:get_id()
    result.dropProps = props
    result.dropSeniorProps = seniorProps
    result.source = "MSGC2SRequestGetVipGift"
    userOb:brocast_packet("MSGS2CUpdatePlayerProp", result)
end

COMMAND_D:register_command("MSGC2SRequestGetVipGift", GameCmdType.NONE, main)
