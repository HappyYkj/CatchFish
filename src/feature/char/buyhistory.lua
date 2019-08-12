local M = {}

---! 增加购买记录
function M:add_buy_history(tag)
    local todayCount = self:query("buyHistory", "todayBuyHistory", tag) or 0
    self:set("buyHistory", "todayBuyHistory", tag, todayCount + 1)

    local totalCount = self:query("buyHistory", "totalBuyHistory", tag) or 0
    self:set("buyHistory", "totalBuyHistory", tag, totalCount + 1)
end

---! 获取购买记录
function M:get_buy_history(type)
    local history
    if type == 1 then
        history = self:query("buyHistory", "totalBuyHistory")
    else
        history = self:query("buyHistory", "todayBuyHistory")
    end

    local items = {}
    if history then
        for tag, count in pairs(history) do
            items[#items + 1] = { id = tonumber(tag), count = count, }
        end
    end
    return items
end

---! 更新数据
function M:update()
    self:delete("buyHistory", "todayBuyHistory")
end

F_CHAR_BUY_HISTORY = M
