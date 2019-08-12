local M = {}

local INVALID_TASKID = 65535

---! 初始新手任务
function M:init_newbie_task()
    if self:get_task_id() ~= 0 then
        return
    end    

    local config = NEW_TASK_CONFIG:get_first_config()
    if not config then
        ---! 配置不存在
        return
    end

    ---! 初始新手任务
    self:set("newTask", "taskId", config.id)
end

---! 获取任务Id
function M:get_task_id()
    return self:query("newTask", "taskId") or 0
end

---! 获取任务计数
function M:get_task_count()
    return self:query("newTask", "taskCount") or 0
end

---! 设置任务计数
function M:set_task_count(offset)
    self:set("newTask", "taskCount", offset)
end

---! 累加任务计数
function M:add_task_count(offset)
    self:set("newTask", "taskCount", self:get_task_count() + offset)
end

---! 获取前一个任务Id
function M:get_last_task_id()
    local config = NEW_TASK_CONFIG:get_last_config(self:get_task_id())
    if not config then
        ---! 配置不存在
        return
    end

    return config.id
end

---! 下一个任务
function M:next_task_data()
    local config = NEW_TASK_CONFIG:get_next_config(self:get_task_id())
    if not config then
        ---! 配置不存在
        self:set("newTask", "taskId", INVALID_TASKID)
        self:delete("newTask", "taskCount")
        return
    end

    self:set("newTask", "taskId", config.id)
    self:delete("newTask", "taskCount")
end

---! 是否能够新手任务分享
function M:can_new_task_share(taskId)
    return self:query("newTask", "taskShare", taskId) and false or true
end

---! 设置新手任务分享完成
function M:set_new_task_share(taskId)
    self:set("newTask", "taskShare", taskId, true)
end

F_CHAR_NEWBIE_TASK = M
