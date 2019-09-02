local json = require "cjson"

---! 解析配置
local config = {}
for name, dict in pairs(json.decode(load_file("databin.json"))) do repeat
    if type(dict["keys"]) ~= "table" then
        printf("error : table[%s], [keys] not exists!", name)
        break
    end

    if type(dict["list"]) ~= "table" then
        printf("error : table[%s], [list] not exists!", name)
        break
    end

    local tbl = {}
    for id, lst in pairs(dict["list"]) do repeat
        id = tonumber(id)
        if tbl[id] then
            printf("error : table[%s], id [%s] is duplicate!", name, id)
            break
        end

        tbl[id] = { id = id, }
        for idx, key in ipairs(dict["keys"]) do
            if name ~= "fishpathEx" then
                local val = lst[idx]
                if type(val) == "string" then
                    val = trim(val)
                end
                tbl[id][key] = val
            else
                tbl[id][key] = lst
            end
        end
    until true end

    if tbl then
        config[name] = tbl
    end
until true end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
CONFIG_D = {}

function CONFIG_D:get_table(tbl_name)
    return config[tbl_name] or nil
end
