local json = require "json"

LISTEN_D:register_listen_channel("charge_channel", function (data)
    local recv = json.decode(data)
    local user_id = recv["userid"]
    local order_id = recv["order_id"]
    local goods_tag = recv["goodstag"]

    local ok, result = FILE_D:write_charge_content(user_id, order_id, goods_tag)
    if not ok or not result then
        return
    end

    local order = {}
    order.userid = user_id
    order.order_id = order_id
    order.goodstag = goods_tag
    CHARGE_D:process_incomplete_order(order)
end)
