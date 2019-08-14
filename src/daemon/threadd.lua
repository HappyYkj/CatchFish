local table_insert = assert(table.insert)
local table_remove = assert(table.remove)
local coroutine_yield = assert(coroutine.yield)
local coroutine_resume = assert(coroutine.resume)
local coroutine_create = assert(coroutine.create)
local coroutine_status = assert(coroutine.status)
local coroutine_running = assert(coroutine.running)

-------------------------------------------------------------------------------
---! CREATE TABLE TO HOLD COROUTINES
-------------------------------------------------------------------------------
local coroutine_pool = {}
local coroutine_wait = {}

-------------------------------------------------------------------------------
---! 内部接口
-------------------------------------------------------------------------------
local coroutine_uuid = 0
local gen_uuid = function()
    coroutine_uuid = coroutine_uuid + 1
    return coroutine_uuid
end

local error_func = function(err)
    spdlog.error("thread", err)
    spdlog.error("thread", debug.traceback())
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
THREAD_D = {}

function THREAD_D:create(func, ...)
    local co = table_remove(coroutine_pool)
    if co then
        -- 如果有此协程，那么直接唤醒并进行使用
        -- 协程内部已经将执行函数设置为新的 func
        coroutine_resume(co, func)
    else
        -- 如果没有此协程，那么需要新建一个辅助协程
        co = coroutine_create(function()
            -- 执行入口函数
            xpcall(func, error_func)

            -- 类似于一个主循环，永远不退出本协程
            while true do
                -- 执行完后，重新放入到池，等待下一次唤醒
                table_insert(coroutine_pool, co)

                -- 执行完毕挂起来等待，下次唤醒之后，就是新的入口函数了
                func = coroutine_yield(0)

                -- 先不执行，等待下一个唤醒，主动进行
                coroutine_yield()

                -- 执行，外部调用了 resume
                xpcall(func, error_func)
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

    -- 投递指定服务线程
    SERVICE_D:post("coroutine_resume", new_id)
end

function THREAD_D:sleep(secs)
    local co = coroutine_running()
    local id = coroutine_wait[co]
    if not id then
        error("sleep failed, [id] not exists")
        return
    end

    SERVICE_D:sleep(id, secs)
    coroutine_yield()
end

function THREAD_D:post(channel, ...)
    return SERVICE_D:post(channel, ...)
end

function THREAD_D:send(channel, ...)
    local co = coroutine_running()
    local id = coroutine_wait[co]
    if not id then
        error("send failed, [id] not exists")
        return
    end
    SERVICE_D:post(channel, id, ...)
    return table.unpack(coroutine.yield())
end

-------------------------------------------------------------------------------
---! 启动接口
-------------------------------------------------------------------------------
SERVICE_D:register("coroutine_resume", function(data)
    if type(data) ~= "table" then
        return
    end

    local id = table_remove(data, 1)
    local co = coroutine_wait[id]
    if not co then
        return
    end

    local status = coroutine_status(co)
    if status ~= "suspended" then
        return
    end

    coroutine_resume(co, data)
end)
