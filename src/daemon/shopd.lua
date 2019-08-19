local table_insert = assert(table.insert)

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
SHOP_D = {}

function SHOP_D:send_exchange_info(player)
    local change_prop_info = {}
    for _, config in pairs(EXCHANGE_CONFIG:get_configs()) do
        local props = {}
        if config.reward then
            local prop_id = next(config.reward)
            local prop_count = config.reward[prop_id]
            if prop_id and prop_count then
                table_insert(props, { propId = prop_id, propCount = prop_count, })
            end
        end

        local buy_props = {}
        if config.reward then
            local prop_id = next(config.need_item)
            local prop_count = config.need_item[prop_id]
            if prop_id and prop_count then
                table_insert(buy_props, { propId = prop_id, propCount = prop_count, })
            end
        end

        table_insert(change_prop_info, {
            changeId = config.id,
            changeName = config.name,
            props = props,
            buyProps = buy_props,
            type = 2,
            leftCount = -1,
        })
    end

    local result = {}
    result.changePropInfo = change_prop_info
    player:send_packet("MSGS2CGetChangePropInfo", result)
end

function SHOP_D:exchange_prop(player, exchange_id, exchange_count)
    if exchange_count <= 0 then
        return
    end

    local exchange_config = EXCHANGE_CONFIG:get_config_by_id(exchange_id)
    if not exchange_config then
        return
    end

    ---! 判断数量
    for prop_id, prop_count in pairs(exchange_config.need_item) do
        if player:get_prop_count(prop_id) < prop_count * exchange_count then
            local result = {}
            result.errorCode = 1
            result.playerId = player:get_id()
            player:send_packet("MSGS2CChangeProp", result)
            return
        end
    end

    ---! 扣除道具
    for prop_id, prop_count in pairs(exchange_config.need_item) do
        player:change_prop_count(prop_id, -prop_count * exchange_count, PropChangeType.kPropChangeSupermaketFishTicket)
    end

    ---! 获得奖励
    local rewards = {}
    for prop_id, prop_count in pairs(exchange_config.reward) do
        rewards[prop_id] = prop_count * exchange_count
    end
    local props, senior_props = ITEM_D:give_user_props(player, rewards, PropChangeType.kPropChangeSupermaketFishTicket)

    ---! 兑换成功
    local result = {}
    result.errorCode = 0
    result.playerId = player:get_id()
    result.buyProps = props
    result.buySeniorProps = senior_props
    player:brocast_packet("MSGS2CChangeProp", result)
end

function SHOP_D:buy_prop(player, prop_id, prop_count)
    local item_config = ITEM_CONFIG:get_config_by_id(prop_id)
    if not item_config then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CBuy", result)
        return
    end

    if item_config.can_buy == 0 then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CBuy", result)
        return
    end

    if player:get_prop_count(GamePropIds.kGamePropIdsCrystal) < item_config.require_num then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CBuy", result)
        return
    end

    if player:get_max_gunrate() < item_config.need_cannon then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CBuy", result)
        return
    end

    local prop_id = prop_id
    local prop_count = item_config.num_perbuy * prop_count
    local price_value = item_config.price_value * prop_count
    if player:get_prop_count(item_config.price_type) < price_value then
        local result = {}
        result.isSuccess = false
        player:send_packet("MSGS2CBuy", result)
        return
    end

    ---! 扣除商品费用
    player:change_prop_count(item_config.price_type, -price_value, PropChangeType.kPropChangeTypeBuyCost)

    ---! 给与响应商品
    player:change_prop_count(prop_id, prop_count, PropChangeType.kPropChangeTypeBuyWithCrystal)

    ---! 通知购买成功
    local result = {}
    result.isSuccess = true
    result.propId = prop_id
    result.propCount = player:get_prop_count(prop_id)
    result.newCrystal = player:get_prop_count(GamePropIds.kGamePropIdsCrystal)
    player:brocast_packet("MSGS2CBuy", result)
end
