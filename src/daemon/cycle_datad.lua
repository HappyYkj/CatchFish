---! 参考时间
local refer_time = os.time({ day=4, month=9, year=2019, hour=9, })

---! 获取明日凌晨时间
local get_tomorrow_time = function()
    local ti = os.date("*t")
    ti.hour = 0
    ti.min = 0
    ti.sec = 0
    return os.time(ti) + 86400
end

---! 判断是否更新每日周期数据
local function can_update_daily_cycle_data(player)
    local update_time = player:query("updateTime") or 0
    if update_time <= 0 then
        -- 初始下次更新时间，此次不做更新处理
        player:set("updateTime", get_tomorrow_time() - refer_time)
        return false
    end

    if update_time + refer_time > os.time() then
        -- 更新时间尚未到达，此次不做更新处理
        return false
    end

    -- 设置下次更新时间
    player:set("updateTime", get_tomorrow_time() - refer_time)
    return true
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CYCLE_DATA_D = {}

function CYCLE_DATA_D:update_daily_cycle_data(player)
    if not can_update_daily_cycle_data(player) then
        return
    end

    player:delete("vip", "vipCoinRecruitUsed")
    player:delete("level", "gradeShare")
    player:delete("alm", "todayCount")
    player:delete("dailyCheckin", "sign")
    player:delete("share", "share_info")
    player:delete("cannon", "gunRateShare")
    player:delete("fishDraw", "killRwardFishInDay")
    player:delete("fishDraw", "drawCountInDay")
    player:delete("match")
end
