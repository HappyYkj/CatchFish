local json = require "cjson"

local function rows(conn, cmd)
    local cur = conn:execute(cmd)
    return function() return cur:fetch() end
end

local function main(conn, msg)
    local playerId, id, count = msg['playerId'], msg['id'], msg['count']

    id = id or ""
    if type(count) ~= "number" then
        count = 1
    else
        count = count > 0 and count or 1
    end

    local deadline = os.time() - 15 * 86400

    local table = "mail_data"
    local cmd
    if #id <= 0 then
        cmd = string.format("SELECT `id`, `type`, `title`, `content`, `attach`, `status`, UNIX_TIMESTAMP(`sendTime`) AS `sendTime` FROM `%s` WHERE playerId = '%s' AND status <> 3 AND sendTime > %s ORDER BY id DESC LIMIT %d",
                            table, playerId, deadline, count)
    else
        cmd = string.format("SELECT `id`, `type`, `title`, `content`, `attach`, `status`, UNIX_TIMESTAMP(`sendTime`) AS `sendTime` FROM `%s` WHERE playerId = '%s' AND id < '%s' AND status <> 3 AND sendTime > %s ORDER BY id DESC LIMIT %d",
                            table, playerId, id, deadline, count)
    end
    print(cmd)

    local mails = {}
    for id, types, title, content, attach, status, sendTime in rows(conn, cmd) do
        local mail = {}
        mail.id = id
        mail.type = tonumber(types)
        mail.title = title
        mail.content = content
        mail.attach = attach
        mail.status = tonumber(status)
        mail.sendTime = tonumber(sendTime)
        mails[#mails + 1] = mail
    end
    return mails
end

return main
