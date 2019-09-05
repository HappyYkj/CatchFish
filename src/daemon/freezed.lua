---! 结束冰冻
local function finish_freeze(desk)
    ---! 获取冰冻开始时间
    local freeze_start_time = desk:query_temp("freeze", "start_time")

    ---! 清理定时器标志位
    desk:delete_temp("freeze", "timer_id")

    ---! 重置冰冻开始时间
    desk:delete_temp("freeze", "start_time")

    ---! 重置冰冻发起人id
    desk:delete_temp("freeze", "player_id")

    ---! 刷新召唤鱼的信息
    desk:flush_visable_callfishes(freeze_start_time)

    ---! 获取冰冻历史时长
    local freeze_timespan = desk:query_temp("freeze", "timespan") or 0

    ---! 累加历史冰冻时长
    desk:set_temp("freeze", "timespan", freeze_timespan + os.clock() - freeze_start_time)

    ---! 广播冰冻结束消息
    local result = {}
    desk:brocast_packet("MSGS2CFreezeEnd", result)

    spdlog.debug("freeze", string.format("finish freeze, freeze_start_time = %s, freeze_timespan = %s", freeze_start_time, os.clock() - freeze_start_time))
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
FREEZE_D = {}

---! 开始执行冰冻
function FREEZE_D:begin_freeze(desk, player)
    ---! 设置发起冰冻的玩家id
    desk:set_temp("freeze", "player_id", player:get_id())

    if not desk:is_in_freeze() then
        ---! 设置冰冻开始时间
        desk:set_temp("freeze", "start_time", os.clock())
    end

    ---! 停止之前定时器
    local freeze_timer_id = desk:query_temp("freeze", "timer_id")
    if freeze_timer_id then
        TIMER_D:cancel_timer(freeze_timer_id)
    end

    ---! 根据vip配置获取冰冻时间
    local freeze_seconds = math.floor(1.0 * 10 * VIP_CONFIG:get_freeze_skill_plus(player:get_vip_exp()) / 100)

    ---! 启动冰冻定时器
    local freeze_timer_id = TIMER_D:start_timer(freeze_seconds, 1, function() finish_freeze(desk) end)
    desk:set_temp("freeze", "timer_id", freeze_timer_id)

    spdlog.debug("freeze", string.format("player [%s] begin freeze, freeze_seconds = %s, freeze_timer_id = %s", player:get_id(), freeze_seconds, freeze_timer_id))
end

---! 是否处于冰冻状态
function FREEZE_D:is_in_freeze(desk)
    return desk:query_temp("freeze", "start_time") and true or false
end

---! 获取冰冻开始时间
function FREEZE_D:get_freeze_start_time(desk)
    return desk:query_temp("freeze", "start_time") or 0
end

---! 获取冰冻历史时长
function FREEZE_D:get_freeze_timespan(desk)
    ---! 获取历史冰冻时长
    local freeze_timespan = desk:query_temp("freeze", "timespan") or 0

    ---! 当前已冰时长
    if desk:is_in_freeze() then
        ---! 获取冰冻开始时间
        local freeze_start_time = desk:query_temp("freeze", "start_time") or os.clock()

        ---! 累加历史冰冻时长
        freeze_timespan = freeze_timespan + os.clock() - freeze_start_time
    end

    ---! 返回当前冰冻时长
    return freeze_timespan
end

---! 冰冻发起人id
function FREEZE_D:get_freeze_player_id(desk)
    return desk:query_temp("freeze", "player_id") or 0
end

---! 重置冰冻状态
function FREEZE_D:reset_freeze(desk)
    local freeze_map = desk:query_temp("freeze")
    if not freeze_map then
        return
    end

    ---! 停止冰冻定时器
    local freeze_timer_id = freeze_map["timer_id"]
    if freeze_timer_id then
        TIMER_D:cancel_timer(freeze_timer_id)
    end

    ---! 清空冰冻信息
    desk:delete_temp("freeze")
end
