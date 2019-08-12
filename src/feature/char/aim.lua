local M = {}

---! 初始化锁定状态
function M:start_aim_fish(duration, skill_plus)
    return AIM_D:start_aim_fish(self, duration, skill_plus)
end

---! 设置锁定倍率
function M:set_lock_fish_hit_rate(gunRate)
    --undo: 当前锁定倍率不生效
    --[[ 
    local hitRate = 300
    if gunRate > 700 then
        hitRate = math.random(170, 200)
    elseif gunRate > 150 then
        hitRate = math.random(180, 200)
    elseif gunRate > 80 then
        hitRate = 200
    end
    self:set_temp("aim", "hitRate", hitRate)
    --]]
end

---! 当前是否锁定状态
function M:is_on_aim_fish()
    return AIM_D:is_on_aim_fish(self)
end

---! 获取锁定结束时间
function M:get_lock_fish_end_time()
    return self:query_temp("aim", "endTime") or 0
end

---! 获取锁定命中倍率
function M:get_lock_fish_hit_rate()
    return self:query_temp("aim", "hitRate") or 0
end

---! 清除锁定状态
function M:clear_lock_fish_state()
    self:delete_temp("aim")
end
 
F_CHAR_AIM = M
