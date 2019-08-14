local lanes = require "lanes"

-------------------------------------------------------------------------------
---! GENERATE ID TO HOLD TIMERS
-------------------------------------------------------------------------------
local timer_id = 0

-------------------------------------------------------------------------------
---! CREATE TABLE TO HOLD TIMERS
-------------------------------------------------------------------------------
local timer_map = {}

-------------------------------------------------------------------------------
---! 内部接口
-------------------------------------------------------------------------------
local function now_secs()
    return lanes.now_secs()
end

local function sort_rule(timer1, timer2)
    return timer1.tigger < timer2.tigger
end

local function trace_func(err)
    spdlog.error(err)
    spdlog.error(debug.traceback())
end

local function loop()
    while true do
        local timers = table.values(timer_map)
        if #timers > 0 then
            ---! 获取当前时间
            local now = now_secs()

            ---! 根据触发时间进行排序
            table.sort(timers, sort_rule)

            ---! 获取第一个定时器
            for _, timer in ipairs(timers) do
                if timer.tigger > now then
                    break
                end

                -- 扣除执行次数
                if timer.times > 0 then
                    timer.times = timer.times - 1
                end

                -- 尝试执行回调
                xpcall(timer.func, trace_func)

                -- 获取定时器Id
                local timer_id = timer.id

                -- 更新定时器
                if timer.times == 0 then
                    -- 剩余次数为0时，需要移除当前定时器
                    timer = nil
                else
                    -- 否则需要更新下一次执行时间
                    timer.tigger = now + timer.interval
                end

                -- 保存定时器
                timer_map[timer_id] = timer
            end
        end

        -- 休眠一秒
        THREAD_D:sleep(1)
    end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
TIMER_D = {}

function TIMER_D:start_timer(...)
    local count = select("#", ...)
    if count < 2 then
        return
    end

    local sec, func, times
    if count < 3 then
        sec = select(1, ...)
        func = select(2, ...)
        times = -1
    else
        sec = select(1, ...)
        func = select(3, ...)
        times = select(2, ...)
    end

    ---! 分配唯一id
    timer_id = timer_id + 1

    ---! 设置相关信息
    local timer = {}
    timer.id = timer_id
    timer.interval = sec
    timer.tigger = now_secs() + sec
    timer.func = func
    timer.times = times

    ---! 记录定时器
    timer_map[timer_id] = timer

    ---! 返回定时器Id
    return timer_id
end

function TIMER_D:cancel_timer(_timer_id)
    timer_map[_timer_id] = nil
end

function TIMER_D:get_timer(_timer_id)
    return timer_map[_timer_id]
end

-------------------------------------------------------------------------------
---! 启动接口
-------------------------------------------------------------------------------
register_post_init(function()
    THREAD_D:create(loop)
end)
