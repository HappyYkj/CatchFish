M = {}

---! 设置初始道具
function M:init_user_props()
    return ITEM_D:init_user_props(self)
end

---! 获取道具数量
function M:get_prop_count(prop_id)
    return ITEM_D:get_prop_count(self, prop_id)
end

---! 修改道具数量
function M:change_prop_count(prop_id, offset, reason)
    return ITEM_D:change_prop_count(self, prop_id, offset, reason)
end

---! 获取高级道具数量
function M:get_senior_prop_count(prop_id)
    return ITEM_D:get_senior_prop_count(self, prop_id)
end

---! 增加高级道具
-- prop_id:道具类型id
-- str_prop:字符串属性
-- int_prop1:数字属性1
-- int_prop2:数字属性2
function M:add_senior_prop(prop_id, str_prop, int_prop1, int_prop2)
    return ITEM_D:add_senior_prop(self, prop_id, str_prop, int_prop1, int_prop2)
end

---! 快速添加高级道具，在内部会对不同道具id做特定处理
function M:add_senior_prop_quick(prop_id)
    return ITEM_D:add_senior_prop_quick(self, prop_id)
end

---! 删除高级道具
function M:erase_senior_prop(prop_item_id)
    return ITEM_D:erase_senior_prop(self, prop_item_id)
end

---! 获取是否由某一类的高级道具
function M:get_senior_prop_by_id(prop_id)
    return ITEM_D:get_senior_prop_by_id(self, prop_id)
end

function M:get_props()
    return ITEM_D:get_props(self)
end

function M:get_senior_props()
    return ITEM_D:get_senior_props(self)
end

F_CHAR_ITEM = M
