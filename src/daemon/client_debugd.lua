-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------
CLIENT_DEBUG_D = {}

function CLIENT_DEBUG_D:input_command(player, cmd)
    if cmd == "save_users" then
        local users = USER_D:get_all_users()
        for _, user in pairs(users) do
            user:save()
        end

        local result = {}
        result.output = "success"
        player:send_packet("MSGC2SConsoleCmd", result)
        return
    end


    if cmd == "limit_arena" then
        LIMIT_ARENA_D:test_limit_arena()

        local result = {}
        result.output = "success"
        player:send_packet("MSGC2SConsoleCmd", result)
        return
    end

    local result = {}
    result.output = cmd
    player:send_packet("MSGC2SConsoleCmd", result)
end
