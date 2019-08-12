local M = {}

---! 获取分享次数
function M:get_share_count(share_type)
    return self:query("share", "shareInfo", share_type) or 0
end

---! 累加分享次数
function M:add_share_count(share_type)
    self:set("share", "shareInfo", share_type, self:get_share_count(share_type) + 1)
end

---! 获取分享信息
function M:get_share_info()
    local share_items = {}
    local share_info = self:query("share", "shareInfo")
    if type(share_info) == "table" then
        for share_type, share_count in pairs(share_info) do
            share_items[#share_items + 1] = { shareType = share_type, shareCount = share_count, }
        end
    end
    return share_items
end

F_CHAR_SHARE = M
