local M = {}

---! 获取水晶掉落历史
function M:get_crystal_drop_history()
    return self:query("library", "crystalDropHistory") or 0
end

---! 累加水晶掉落历史
function M:add_crystal_drop_history(offset)
    self:set("library", "crystalDropHistory", self:get_crystal_drop_history() + offset)
end

---! 获取历史输赢库值
function M:get_history_icon_drop_rate()
    return self:query("library", "historyIconDropRate") or 0
end

---! 累加历史输赢库值
function M:add_history_icon_drop_rate(offset)
    self:set("library", "historyIconDropRate", self:get_history_icon_drop_rate() + offset)
end

---! 设置历史输赢库值
function M:set_history_icon_drop_rate(offset)
    self:set("library", "historyIconDropRate", offset)
end


---! 通过获得鱼币，更新历史输赢库值
function M:update_history_drop_by_fishicon(offset)
    if offset == 0 then
        return
    end

    if offset > 0 then
        self:add_history_icon_drop_rate(-offset)
        return
    end

    self:add_history_icon_drop_rate(-offset * 0.97)
end

---! 获取锻造材料库值
function M:get_material_rate()
    return self:query("library", "materialRate") or 0
end

---! 累加锻造材料库值
function M:add_material_rate(offset)
    self:set("library", "materialRate", self:add_material_rate() + offset)
end

---! 清空锻造材料库值
function M:del_material_rate()
    self:delete("library", "materialRate")
end

---! 获取核弹库值
function M:get_nbomb_rate()
    return self:query("library", "nbombRate") or 0
end

---! 累加核弹库值
function M:add_nbomb_rate(offset)
    self:set("library", "nbombRate", self:get_nbomb_rate() + offset)
end

---! 设置核弹库值
function M:set_nbomb_rate(offset)
    self:set("library", "nbombRate", offset)
end

---! 获取炸弹库值
function M:get_bomb_rate()
    return self:query("library", "bombRate") or 0
end

---! 累加炸弹库值
function M:add_bomb_rate(offset)
    self:set("library", "bombRate", self:get_bomb_rate() + offset)
end

---! 设置炸弹库值
function M:set_bomb_rate(offset)
    self:set("library", "bombRate", offset)
end

---! 获取补贴库值
function M:get_allowance_rate()
    return self:query("library", "allowanceRate") or 0
end

---! 累加补贴库值
function M:add_allowance_rate(offset)
    self:set("library", "allowanceRate", self:get_allowance_rate() + offset)
end

---! 设置补贴库值
function M:set_allowance_rate(offset)
    self:set("library", "allowanceRate", offset)
end

---! 获取新手库值
function M:get_allowance_newbie_rate()
    return self:query("library", "allowanceNewbieRate") or 0
end

---! 累加新手库值
function M:add_allowance_newbie_rate(offset)
    self:set("library", "allowanceNewbieRate", self:get_allowance_newbie_rate() + offset)
end

---! 获取充值库值
function M:get_charge_rate()
    return self:query("library", "chargeRate") or 0
end

---! 累加新手库值
function M:add_charge_rate(offset)
    self:set("library", "chargeRate", self:get_charge_rate() + offset)
end

---! 获取闪电库值
function M:get_thunder_rate()
    return self:query("library", "thunderRate") or 0
end

---! 累加闪电库值
function M:add_thunder_rate(offset)
    self:set("library", "thunderRate", self:get_thunder_rate() + offset)
end

---! 设置闪电库值
function M:set_thunder_rate(offset)
    self:set("library", "thunderRate", offset)
end

---! 获取水晶库值
function M:get_crystal_drop_rate()
    return self:query("library", "crystalDropRate") or 0
end

---! 累加水晶库值
function M:add_crystal_drop_rate(offset)
    self:set("library", "crystalDropRate", self:get_crystal_drop_rate() + offset)
end

---! 清空水晶库值
function M:del_crystal_drop_rate()
    self:delete("library", "crystalDropRate")
end

---! 获取技能库值
function M:get_skill_drop_rate()
    return self:query("library", "skillDropRate") or 0
end

---! 累加技能库值
function M:add_skill_drop_rate(offset)
    self:set("library", "skillDropRate", self:get_skill_drop_rate() + offset)
end

---! 清空技能库值
function M:del_skill_drop_rate()
    self:delete("library", "skillDropRate")
end

---! 获取召唤鱼库值
function M:get_callfish_drop_rate()
    return self:query("library", "callFishDropRate") or 0
end

---! 累加召唤鱼库值
function M:add_callfish_drop_rate(offset)
    self:set("library", "callFishDropRate", self:get_callfish_drop_rate() + offset)
end

F_CHAR_LIBRARY = M
