local function main (userOb, msgData)
    local item_config = ITEM_CONFIG:get_config_by_id(msgData.propId)
    if not item_config then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CBuy", result)
        return
    end

    if item_config.can_buy ~= 1 then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CBuy", result)
        return
    end

    if userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal) < item_config.require_num then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CBuy", result)
        return
    end

    if userOb:get_max_gunrate() < item_config.need_cannon then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CBuy", result)
        return
    end

    local prop_id = msgData.propId
    local prop_count = item_config.num_perbuy * msgData.count
    local price_value = item_config.price_value * prop_count
    if userOb:get_prop_count(item_config.price_type) < price_value then
        local result = {}
        result.isSuccess = false
        userOb:send_packet("MSGS2CBuy", result)
        return
    end

    ---! 扣除商品费用
    userOb:change_prop_count(item_config.price_type, -price_value, PropRecieveType.kPropChangeTypeBuyCost)

    ---! 给与响应商品
    userOb:change_prop_count(prop_id, prop_count, PropRecieveType.kPropChangeTypeBuyWithCrystal)
    
    ---! 通知购买成功
    local result = {}
    result.isSuccess = true
    result.propId = prop_id
    result.propCount = userOb:get_prop_count(prop_id)
    result.newCrystal = userOb:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    userOb:brocast_packet("MSGS2CBuy", result)
end

COMMAND_D:register_command("MSGC2SBuy", GameCmdType.NONE, main)
