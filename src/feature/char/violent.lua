local M = {}

---! 初始狂暴状态
function M:init_violent()
    return VIOLENT_D:init_violent(self)
end

---! 清除狂暴状态
function M:clear_violent()
    return VIOLENT_D:clear_violent(self)
end

---! 是否处于狂暴状态
function M:is_on_violent()
    return VIOLENT_D:is_on_violent(self)
end

---! 获取狂暴倍率
function M:get_violent_ratio()
    return VIOLENT_D:get_violent_ratio(self)
end

F_CHAR_VIOLENT = M
