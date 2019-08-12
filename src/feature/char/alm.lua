local M = {}

---! 获取当日领取救济金次数
function M:get_today_count()
    return self:query("alm", "todayCount") or 0
end

---! 累加当日领取救济金次数
function M:add_today_count(offset)
    self:set("alm", "todayCount", self:get_today_count() + offset)
end

---! 记录玩家破产
function M:record_backup_time()
    self:set("alm", "lastBackup", os.time())
end

---! 获取上次破产时间
function M:get_last_backup_time()
    return self:query("alm", "lastBackup") or 0
end

F_CHAR_ALM = M
