local coroutine_pool = {}
local coroutine_wait = {}

local coroutine_uuid = 0
local gen_uuid = function()
    coroutine_uuid = coroutine_uuid + 1
    return coroutine_uuid
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
THREAD_D = {}

function THREAD_D:create(func)
    --获取协程id
    local co = table.remove(coroutine_pool)
    if co then
        -- 如果有此协程，那么直接唤醒并进行使用
        -- 协程内部已经将执行函数设置为新的 func
        coroutine.resume(co, func)
    else
        -- 如果没有此协程，那么需要新建一个辅助协程
        co = coroutine.create(function()
            -- 执行入口函数
            xpcall(func, error_traceback)

            -- 类似于一个主循环，永远不退出本协程
            while true do
                -- 执行完后，重新放入到池，等待下一次唤醒
                table.insert(coroutine_pool, co)

                -- 执行完毕挂起来等待，下次唤醒之后，就是新的入口函数了
                func = coroutine.yield(0)

                -- 先不执行，等待下一个唤醒，主动进行
                coroutine.yield()

                -- 执行，外部调用了 resume
                xpcall(func, error_traceback)
            end
        end)
    end

    -- 移除之前关联关系
    local old_id = coroutine_wait[co]
    if old_id then
        coroutine_wait[old_id] = nil
    end

    -- 重新分配唯一标识
    local new_id = gen_uuid()

    -- 关联当前协程对象
    coroutine_wait[new_id] = co
    coroutine_wait[co] = new_id

    -- 投递linda队列，由lanes线程主动唤醒
    SERVICE_D:post("coroutine_resume", new_id)
end

function THREAD_D:sleep(sec)
    local co = coroutine.running()
    local id = coroutine_wait[co]
    if not id then
        error("sleep failed, [id] not exists")
    end

    TIMER_D:start_timer(sec, 1, function()
        return THREAD_D:wakeup(id)
    end)
    coroutine.yield()
end

function THREAD_D:post(channel, ...)
    return SERVICE_D:post(channel, ...)
end

function THREAD_D:send(channel, ...)
    local co = coroutine.running()
    local id = coroutine_wait[co]
    if not id then
        error("send failed, [id] not exists")
    end

    SERVICE_D:post(channel, id, ...)
    return table.unpack(coroutine.yield())
end

function THREAD_D:wakeup(id, ...)
    local co = coroutine_wait[id]
    if not co then
        return
    end

    local status = coroutine.status(co)
    if status == "suspended" then
        coroutine.resume(co, table.pack(...))
    end
end

function THREAD_D:suspend(co)
    local co = co or coroutine.running()
    coroutine.yield(co)
end

-------------------------------------------------------------------------------
---! 启动模块
-------------------------------------------------------------------------------
register_post_init(function()
    SERVICE_D:register("coroutine_resume", function(linda, id, ...)
        return THREAD_D:wakeup(id, ...)
    end)
end)
