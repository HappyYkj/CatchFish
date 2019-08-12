local function main (userOb, msgData)
    if msgData.count <= 0 then
        return
    end

    local config = EXCHANGE_CONFIG:get_config_by_id(msgData.changeId)
    if not config then
        return
    end

    ---! 判断数量
    for propId, propCount in pairs(config.need_item) do
        if userOb:get_prop_count(propId) < propCount * msgData.count then
            local result = {}
            result.errorCode = 1
            result.playerId = userOb:get_id()
            userOb:send_packet("MSGS2CChangeProp", result)
            return
        end
    end

    ---! 扣除道具
    for propId, propCount in pairs(config.need_item) do
        userOb:change_prop_count(propId, -propCount * msgData.count, PropRecieveType.kPropChangeSupermaketFishTicket)
    end
    
    ---! 获得奖励
    local props = {}
    local seniorProps = {}
    for propId, propCount in pairs(config.reward) do repeat
        local itemConfig = ITEM_CONFIG:get_config_by_id(propId)
        if not itemConfig then
            break
        end

        if not itemConfig.if_senior then
            userOb:change_prop_count(propId, propCount * msgData.count, PropRecieveType.kPropChangeSupermaketFishTicket)
            props[#props + 1] = { propId = propId, propCount = propCount * msgData.count, }
            break
        end

        for idx = 1, propCount * msgData.count do 
            seniorProps[#seniorProps + 1] = userOb:add_senior_prop_quick(propId)
        end
    until true end

    ---! 兑换成功
    local result = {}
    result.errorCode = 0
    result.playerId = userOb:get_id()
    result.buyProps = props
    result.buySeniorProps = seniorProps
    userOb:brocast_packet("MSGS2CChangeProp", result)
end

COMMAND_D:register_command("MSGC2SChangeProp", GameCmdType.NONE, main)
