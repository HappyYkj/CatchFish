local function rows(conn, cmd)
    local cur = conn:execute(cmd)
    return function() return cur:fetch() end
end

local function main(conn, msg)
    local user_id, count = msg['user_id'], msg['count']

    local table = "charge_data"
    local cmd = string.format("SELECT `order_id`, `goods_tag` FROM `%s` WHERE `user_id` = '%s' AND `status` = 0 ORDER BY `charge_time` LIMIT %s",
                table, user_id, count)
    print(cmd)

    local orders = {}
    for order_id, goods_tag in rows(conn, cmd) do
        local order = {}
        order.userid = user_id
        order.order_id = order_id
        order.goodstag = goods_tag
        orders[#orders + 1] = order
    end
    return orders
end

return main
