local function main(conn, msg)
    local user_id, order_id = msg['user_id'], msg['order_id']

    local table = "charge_data"
    local cmd = string.format("UPDATE `%s` SET `status` = 1, `finish_time` = '%s' WHERE `user_id` = '%s' AND `order_id` = '%s';",
                table, os.date("%Y-%m-%d %H:%M:%S"), user_id, order_id);
    print(cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

return main
