local M = {}

---! 设置当前炮倍
function M:set_cur_gunrate(gunRate)
    self:set("cannon", "currentGunRate", gunRate)
end

---! 获取当前炮倍
function M:get_cur_gunrate()
    return self:query("cannon", "currentGunRate") or 0
end

---! 获取最高炮倍
function M:get_max_gunrate()
    return self:query("cannon", "maxGunRate") or 0
end

---! 修改最高炮倍
function M:set_max_gunrate(offset)
    self:set("cannon", "maxGunRate", offset)
end

---! 是否能够炮倍升级分享
function M:can_gunrate_share(grade)
    return self:query("cannon", "gunRateShare", grade) and false or true
end

---! 设置炮倍升级分享完成
function M:set_gunrate_share(grade)
    self:set("cannon", "gunRateShare", grade, true)
end

---! 获取炮台类型
function M:get_guntype()
    return self:query("cannon", "gunType") or 0
end

---! 设置炮台类型
function M:set_guntype(gunType)
    self:set("cannon", "gunType", gunType)
end

---! 获取分身炮台类型
function M:get_sep_guntype()
    return self:query("cannon", "seperateGunType") or 0
end

---! 设置分身炮台类型
function M:set_sep_guntype(gunType)
    self:set("cannon", "seperateGunType", gunType)
end

---! 获取分身锻造次数
function M:get_sep_guntype_forge_count()
    return self:query("cannon", "seperateGunForgeCount") or 0
end

---! 累加分身锻造次数
function M:add_sep_guntype_forge_count(offset)
    self:set("cannon", "seperateGunForgeCount", self:get_sep_guntype_forge_count() + offset)
end

---! 清空分身锻造次数
function M:del_sep_guntype_forge_count()
    self:delete("cannon", "seperateGunForgeCount")
end

F_CHAR_CANNON = M
