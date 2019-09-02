local json = require "cjson"

local M = {}

function M:load()
    local user_id = self:get_id()

    local ok, user_map = FILE_D:read_common_content("user", user_id)
    if not ok then
        return false
    end

    local ok, item_map = FILE_D:read_common_content("item", user_id)
    if not ok then
        return false
    end

    if #user_map > 0 then
        local ok, user_dbase = pcall(json.decode, user_map)
        if not ok then
            return false
        end

        ---! 玩家基本数据
        self:set_entire_dbase(user_dbase)
    end

    if #item_map > 0 then
        local ok, item_dbase = pcall(json.decode, item_map)
        if not ok then
            return false
        end

        ITEM_D:load_user_props(self, item_dbase)
    end

    ---! 加载成功
    return true
end

function M:save()
    local user_id = self:get_id()

    ---! 保存道具数据
    local item_dbase = ITEM_D:save_user_props(self)
    FILE_D:write_common_content("item", user_id, "", json.encode(item_dbase))

    ---! 保存基本数据
    local user_dbase = self:query_entire_dbase()
    FILE_D:write_common_content("user", user_id, "", json.encode(user_dbase))
end

F_CHAR_SAVE = M
