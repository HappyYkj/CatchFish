local process_cmd_map = {}

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
COMMAND_D = {}

function COMMAND_D:process_command(clientId, MsgType, MsgData)
    local user_ob = LOGIN_D:find_user(clientId)
    if not user_ob then
        return
    end

    local cmd = process_cmd_map[MsgType]
    if not cmd then
        spdlog.error("cmd", string.format("not found command [%s]", MsgType))
        return
    end

    if cmd.type ~= GameCmdType.NONE then
        if cmd.type == GameCmdType.HALL then
            -- hall
            if user_ob:get_desk() then
                spdlog.error("cmd", string.format("not hall command [%s]", MsgType))
                return
            end
        elseif cmd.type == GameCmdType.DESK then
            -- desk
            if not user_ob:get_desk() then
                spdlog.error("cmd", string.format("not desk command [%s]", MsgType))
                return
            end
        end
    end

    local func = cmd.func
    if not func then
        spdlog.error("cmd", string.format("command [%s] callback not exists", MsgType))
        return
    end

    ---! 记录当前指令处理时间
    user_ob:set_temp("command_time", os.time())

    ---! 优先尝试更新玩家数据
    user_ob:update_data()

    ---! 而后尝试调用指令回调
    xpcall(function() func(user_ob, MsgData) end, function(err)
        spdlog.error(err)
        spdlog.error(debug.traceback())
    end)
end

function COMMAND_D:register_command(cmd, type, func)
    process_cmd_map[cmd] = { type = type, func = func, }
end
