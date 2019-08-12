local json = require "json"

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

        ---! 道具基本数据
        if item_dbase.props then
            self:set_temp("item", "props", item_dbase.props)
        end

        if item_dbase.seniorProps then
            local maxSeniorPropId = self:query_temp("maxSeniorPropId") or 0
            local seniorProps = self:query_temp("item", "seniorProps") or {}
            for _, seniorProp in ipairs(item_dbase.seniorProps) do
                seniorProps[seniorProp.propItemId] = seniorProp
                maxSeniorPropId = math.max(seniorProp.propItemId, maxSeniorPropId)
            end
            self:set_temp("maxSeniorPropId", maxSeniorPropId)
            self:set_temp("item", "seniorProps", seniorProps)
        end
    end

    ---! 加载成功
    return true
end

function M:save()
    local user_id = self:get_id()

    ---! 保存道具数据
    local item_dbase = self:query_temp("item")
    if item_dbase then
        local item_map = {
            props = table.values(item_dbase["props"]),
            seniorProps = table.values(item_dbase["seniorProps"]),
        }

        FILE_D:write_common_content("item", user_id, "", json.encode(item_map))
    end

    ---! 保存基本数据
    local user_dbase = self:query_entire_dbase()
    FILE_D:write_common_content("user", user_id, "", json.encode(user_dbase))
end

F_CHAR_SAVE = M
