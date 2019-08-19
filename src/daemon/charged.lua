-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CHARGE_D = {}

function CHARGE_D:request_incomplete_order(player_id)
    local ok, orders = FILE_D:read_charge_content(player_id, 5)
    if not ok then
        return
    end

    local order_size = #orders
    if order_size <= 0 then
        return
    end

    for _, order in ipairs(orders) do
        local player = USER_D:find_user(player_id)
        if not player then
            return
        end

        if not CHARGE_D:process_incomplete_order(order) then
            return
        end
    end

    if order_size < 5 then
        return
    end

    CHARGE_D:request_incomplete_order(player_id)
end

function CHARGE_D:process_incomplete_order(order)
    local user_id = order["userid"]
    local order_id = order["order_id"]
    local goods_tag = order["goodstag"]
    spdlog.info("charge", string.format("process order user_id = %s, order_id = %s, goods_tag = %s", user_id, order_id, goods_tag))

    local user = USER_D:find_user(tonumber(user_id))
    if not user then
        return false
    end

    ---! 处理订单
    FILE_D:update_charge_content(user_id, order_id)

    ----! 订单处理完成后，才能安排玩家下线
    ----todo:

    ---! 完成订单
    repeat
        local goods_tag = tonumber(goods_tag)
        local charge_config = CHARGE_CONFIG:get_config_by_id(goods_tag)
        if not charge_config then
            break
        end

        --- 累加充值记录
        user:add_buy_history(goods_tag)

        --- 累加VIP经验
        user:add_vip_exp(charge_config.recharge)

        if goods_tag == 830001040 then
            --- 新手任务一键完成
            TASK_D:finish_task_by_rechage(user)
        end

        local rewards = {}
        for prop_id, prop_count in pairs(charge_config.reward) do repeat
            if not rewards[prop_id] then
                rewards[prop_id] = prop_count
                break
            end
            rewards[prop_id] = rewards[prop_id] + prop_count
        until true end

        for prop_id, prop_count in pairs(charge_config.reward_gift) do repeat
            if not rewards[prop_id] then
                rewards[prop_id] = prop_count
                break
            end
            rewards[prop_id] = rewards[prop_id] + prop_count
        until true end

        ---! 获得奖励
        local props, senior_props = ITEM_D:give_user_props(user, rewards, PropChangeType.kPropChangeTypeCharge)

        -- 通知给奖励信息
        local result = {}
        result.playerId = user:get_id()
        result.source = "MSGS2CChargeGoodes"
        result.dropProps = props
        result.dropSeniorProps = senior_props
        user:brocast_packet("MSGS2CChargeGoodes", result)
    until true

    ---! 通知订单已完成
    local result = {}
    result.goodsTag = goods_tag
    result.orderId = order_id
    user:send_packet("MSGS2CChargeGoodes", result)

    ---! 充值后刷新玩家数据
    local result = {}
    result.playerInfo = user:generate_player_info()
    result.buyHistory = user:get_buy_history(1)
    result.todayBuy = user:get_buy_history(2)
    user:brocast_packet("MSGS2CUpdateRecharge", result)
    return true
end
