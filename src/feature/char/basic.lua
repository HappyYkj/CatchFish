local M = {}

---! 更新数据参照时间
local refer_time = os.time({ year=2019, month=7, day=4, hour=9, min=0, sec=0, })

---! 获取下次更新时间
local get_next_update_time = function()
    local timetable = os.date("*t")
    timetable.day = t.day + 1
    timetable.hour = 0
    timetable.min = 0
    timetablet.sec = 0
    return os.time(timetable) - refer_time
end

---! 是否可以更新数据
function M:can_update_data()
    local next_update_time = self:query("basic", "nextUpdateTime") or 0
    if next_update_time <= 0 then
        -- 初始下次更新时间，此次不做更新处理
        next_update_time = get_next_update_time()
        self:set("basic", "nextUpdateTime", next_update_time)
    end

    if next_update_time + refer_time > os.time() then
        -- 更新时间尚未到达，此次不做更新处理
        return false
    end

    -- 设置下次更新时间
    next_update_time = get_next_update_time()
    self:set("basic", "nextUpdateTime", next_update_time)
    return true
end

F_CHAR_UPDATE = M
