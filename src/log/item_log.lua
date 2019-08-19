local table = "item_log"

local function main(conn, data)
    local player_id, prop_id, prop_count = data['player_id'], data['prop_id'], data['prop_count']
    local offset, desk_grade = data['offset'], data['desk_grade']
    local reason, memo, update_time = data['reason'], data['memo'], data['update_time']

    player_id = player_id or 0
    prop_id = prop_id or 0
    prop_count = prop_count or 0
    offset = offset or 0
    reason = reason or 0
    memo = memo or ""
    update_time = update_time or os.date("%Y-%m-%d %H:%M:%S")

    local cmd = string.format("INSERT INTO `%s` (`update_time`, `player_id`, `prop_id`, `prop_count`, `offset`, `reason`, `desk_grade`, `memo`) " ..
                              "VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');",
                              table, update_time, player_id, prop_id, prop_count, offset, reason, desk_grade, memo);
    print(cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

LOG_D:register(table, main)
