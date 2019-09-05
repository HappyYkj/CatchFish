
local uuid = require "global.common.uuid"

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
MAIL_D = {}

---! 发送邮件
function MAIL_D:send_mail(playerId, mail)
    local mail = mail or {}
    mail.id = uuid.hex()
    mail.type = 1
    mail.title = mail.title or ""
    mail.content = mail.content or ""
    mail.attach = mail.attach or ""
    mail.status = 0
    mail.sendTime = os.time()

    ---! 写入数据库
    local ok, result = FILE_D:write_mail_content(playerId, mail)
    if not ok or not result then
        return
    end

    local player = USER_D:find_user(playerId)
    if player then
        player:set_temp("mail", mail.id, mail)

        local result = {}
        result.mail = mail
        player:send_packet("MSGS2CMailNew", result)
    end
end

---! 获取邮件列表
function MAIL_D:get_mail_list(player, id, count)
    local ok, mails = FILE_D:read_mail_content(player:get_id(), id, count)
    if not ok then
        local result = {}
        result.errorCode = 1
        player:send_packet("MSGS2CMailList", result)
        return
    end

    ---! 缓存拉去的邮件信息
    for _, mail in ipairs(mails) do
        player:set_temp("mail", mail.id, mail)
    end

    local result = {}
    result.mails = mails
    result.errorCode = 0
    player:send_packet("MSGS2CMailList", result)
end

---! 更新指定邮件
function MAIL_D:update_mail(player, id, op)
    local mail = player:query_temp("mail", id)
    if not mail then
        -- 邮件未拉取
        local result = {}
        result.id = id
        result.errorCode = 1
        player:send_packet("MSGS2CMailUpdate", result)
        return
    end

    if op == 1 then
        -- 读取
        if mail.status ~= 0 then
            -- 该邮件已读取
            local result = {}
            result.id = id
            result.status = mail.status
            result.errorCode = 0
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 更新数据库
        local ok, result = FILE_D:update_mail_content(player:get_id(), id, 1)
        if not ok or not result then
            -- 数据库更新失败
            local result = {}
            result.id = id
            result.errorCode = 2
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 修改邮件状态
        mail.status = 1

        -- 通知客户端
        local result = {}
        result.id = id
        result.status = mail.status
        result.errorCode = 0
        player:send_packet("MSGS2CMailUpdate", result)
        return
    end

    if op == 2 then
        -- 领取
        if mail.status ~= 0 and mail.status ~= 1 then
            -- 该邮件已读取
            local result = {}
            result.id = id
            result.status = mail.status
            result.errorCode = 0
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 更新数据库
        local ok, result = FILE_D:update_mail_content(player:get_id(), id, 2)
        if not ok or not result then
            -- 数据库更新失败
            local result = {}
            result.id = id
            result.errorCode = 2
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 修改邮件状态
        mail.status = 2

        -- 发放邮件奖励
        if mail.attach and #mail.attach > 0 then
            local prop_map = {}
            for _, prop_desc in ipairs(split(mail.attach, ";")) do repeat
                local fields = string.split(prop_desc, ",")
                if #fields < 2 then
                    break
                end

                local prop_id, prop_count = fields[1], fields[2]
                if not prop_id or not prop_count then
                    break
                end

                prop_map[tonumber(prop_id)] = tonumber(prop_count)
            until tru end
            local props, senior_props = ITEM_D:give_user_props(player, prop_map, PropChangeType.kPropChangeTypeMail)

            ---! 通知给奖励信息
            local result = {}
            result.playerId = player:get_id()
            result.dropProps = props
            result.dropSeniorProps = senior_props
            result.source = "MSGS2CMailUpdate"
            player:brocast_packet("MSGS2CUpdatePlayerProp", result)
        end

        -- 通知客户端
        local result = {}
        result.id = id
        result.status = mail.status
        result.errorCode = 0
        player:send_packet("MSGS2CMailUpdate", result)
        return
    end

    if op == 3 then
        -- 删除
        if mail.status == 3 then
            -- 该邮件已删除
            local result = {}
            result.id = id
            result.status = mail.status
            result.errorCode = 0
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 更新数据库
        local ok, result = FILE_D:update_mail_content(player:get_id(), id, 3)
        if not ok or not result then
            -- 数据库更新失败
            local result = {}
            result.id = id
            result.errorCode = 2
            player:send_packet("MSGS2CMailUpdate", result)
            return
        end

        -- 移除缓存邮件
        player:delete_temp("mail", id)

        -- 通知客户端
        local result = {}
        result.id = id
        result.status = status
        result.errorCode = 0
        player:send_packet("MSGS2CMailUpdate", result)
        return
    end
end
