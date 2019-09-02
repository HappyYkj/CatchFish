local json = require "cjson"

local function main(conn, msg)
    local playerId, mail = msg['playerId'], msg['mail']
    local id, types, title, content, attach, status, sendTime = mail['id'], mail['type'], mail['title'], mail['content'], mail['attach'], mail['status'], mail['sendTime']

    local table = "mail_data"
    local cmd = string.format("INSERT INTO `%s` (`id`, `type`, `title`, `content`, `attach`, `status`, `sendTime`, `playerId`) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');",
                table, id, types, title, content, attach, status, os.date("%Y-%m-%d %H:%M:%S", sendTime), playerId)
    print(cmd)

    local affected_rows = conn:execute(cmd)
    return affected_rows > 0
end

return main
