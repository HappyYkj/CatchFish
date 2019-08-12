local function main(conn, msg)
    local user_id, order_id, goods_tag = msg['user_id'], msg['order_id'], msg['goods_tag']

    local table = "charge_data"
    local cmd = string.format("INSERT INTO `%s` (`charge_time`, `user_id`, `order_id`, `goods_tag`) VALUES ('%s', '%s', '%s', '%s');",
                table, os.date("%Y-%m-%d %H:%M:%S"), user_id, order_id, goods_tag);
    print(cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

return main
