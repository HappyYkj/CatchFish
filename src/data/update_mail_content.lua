local json = require "json"

local function main(conn, msg)
    local id, status = msg['id'], msg['status']

    local table = "mail_data"
    local cmd = string.format("UPDATE `%s` SET `status` = '%s' WHERE `id` = '%s'", table, status, id)
    print (cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

return main
