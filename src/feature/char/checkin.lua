local M = {}

---! 获取签到天数
function M:get_days()
    return self:query("dailyCheckin", "days") or 0
end

---! 累加签到天数
function M:add_days()
    local days = self:get_days() + 1
    if days >= 14 then
        days = days - 7
    end
    self:set_days(days)
end

---! 设置签到天数
function M:set_days(days)
    self:set("dailyCheckin", "days", days)
end

---! 获取签到标记
function M:get_sign()
    local sign = self:query("dailyCheckin", "sign") or 0
    return sign ~= 0 and true or false
end

---! 设置签到标记
function M:set_sign()
    self:set("dailyCheckin", "sign", 1)
end

F_CHAR_CHECKIN = M
