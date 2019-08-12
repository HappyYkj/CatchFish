local M = {}

---! 获取奖池（游戏内抽奖使用）
function M:get_draw_rate()
    return self:query("fishDraw", "rewardRate") or 0
end

---! 累加奖池
function M:add_draw_rate(offset)
    self:set("fishDraw", "rewardRate", self:get_draw_rate() + offset)
end

---! 清空奖励
function M:del_draw_rate()
    self:delete("fishDraw", "rewardRate") 
end

---! 获取当日击杀奖金鱼次数
function M:get_kill_reward_fish()
    return self:query("fishDraw", "killRwardFishInDay") or 0
end

---! 累加当日击杀奖金鱼次数
function M:add_kill_reward_fish(offset)
    self:set("fishDraw", "killRwardFishInDay", self:get_kill_reward_fish() + offset)
end

---! 清空当日击杀奖金鱼次数
function M:del_kill_reward_fish()
    self:delete("fishDraw", "killRwardFishInDay")
end

---! 获取当日抽奖次数
function M:get_draw_count()
    return self:query("fishDraw", "drawCountInDay") or 0
end

---! 累加当日抽奖次数
function M:add_draw_count(offset)
    self:set("fishDraw", "drawCountInDay", self:get_draw_count() + offset)
end

F_CHAR_FISHDRAW = M
