local M = {}

---! 鱼在当下时间是否还是可见
function M:is_fish_exist_and_alived(frame, timelineId, fisharrayId)
    return FISH_D:is_fish_exist_and_alived(self, frame, timelineId, fisharrayId)
end

---! 获取当前帧可见的鱼
function M:get_killed_fishes_on_frame(frame)
    return FISH_D:get_killed_fishes_on_frame(self, frame)
end

---! 增加被杀死的鱼
function M:add_killed_fish(timelineId, fisharrayId)
   return FISH_D:add_killed_fish(self, timelineId, fisharrayId)
end

---! 获取当前鱼使用的Id
function M:get_fishid_by_fisharray(timelineId, fisharrayId)
    return FISH_D:get_fishid_by_fisharray(self, timelineId, fisharrayId)
end

---! 移除所有被杀死的鱼
function M:remove_all_killed_fishes()
    return FISH_D:remove_all_killed_fishes(self)
end

F_COMBAT_FISH = M
