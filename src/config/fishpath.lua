local tbl = CONFIG_D:get_table("fishpathEx")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id  -- 鱼种id
    
    -- 鱼线
    config.pointdata = {}
    if row.pointdata ~= "" then
        local tbl = {}
        local fields = row.pointdata
        for i = 1, #fields, 3 do
            if fields[i] and fields[i + 1] and fields[i + 2] then
                tbl[#tbl + 1] = { x = tonumber(fields[i]), y = tonumber(fields[i + 1]), z = tonumber(fields[i + 2]), } 
            end
        end

        if table.len(tbl) > 0 then
            config.pointdata = tbl
        end
    end

    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FISH_PATH_CONFIG = {}

function FISH_PATH_CONFIG:get_config_by_id(id)
    local config = configs[id]
    if not config then
        return
    end
    return config
end
