local M = {}

---! 获取等级经验
function M:get_grade_experience()
    return self:query("level", "gradeExp") or 0
end

---! 累加等级经验
function M:add_grade_experience(offset)
    self:set("level", "gradeExp", self:get_grade_experience() + offset)
end

---! 获取当前等级
function M:get_grade()
    return LEVEL_CONFIG:get_grade_by_exp(self:get_grade_experience())
end

---! 获取最大等级
function M:get_max_grade()
    return LEVEL_CONFIG:get_max_grade()
end

---! 是否能够升级分享
function M:can_grade_share(grade)
    return self:query("level", "gradeShare", grade) and false or true
end

---! 设置升级分享完成
function M:set_grade_share(grade)
    self:set("level", "gradeShare", grade, true)
end

F_CHAR_LEVEL = M
