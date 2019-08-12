local tbl = CONFIG_D:get_table("config")
if not tbl then
    return
end

local configs = {}
if tbl[990000135] then
    local fields = split(tbl[990000135].data, ";")
    for i = 1, #fields, 4 do
        if fields[i] and fields[i + 1] and fields[i + 2] and fields[i + 3] then
            configs[#configs + 1] = {
                seperateGunType = tonumber(fields[i]),          -- 分身炮台类型
                gunRateLimit = tonumber(fields[i + 1]),         -- 炮倍限制
                initSuccessRate = tonumber(fields[i + 2]),      -- 初始成功率
                definiteSuccessCount = tonumber(fields[i + 3]), -- 必成次数
                props = {}                                      -- 消耗道具
            }
        end
    end

    if tbl[990000136] then
        local fields = split(tbl[990000136].data, ";")
        for i = 1, #fields do
            if configs[i] then
                local item = split(fields[i], "_")
                if #item == 2 then
                    configs[i].props = { [tonumber(item[1])] = tonumber(item[2]), }
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FORGE_CONFIG = {}

function FORGE_CONFIG:get_config(seperateGunType, maxGunRate)
    for _, config in ipairs(configs) do repeat
        if not config then
            break
        end

        if config.seperateGunType ~= seperateGunType then
            break
        end

        if config.gunRateLimit > maxGunRate then
            break
        end

        return config
    until true end
end

function FORGE_CONFIG:get_forge_result(config, historyForgeCount)
    if historyForgeCount >= config.definiteSuccessCount then
        return true
    end

    if math.random(10000) < config.initSuccessRate then
        return true
    end

    return false
end
