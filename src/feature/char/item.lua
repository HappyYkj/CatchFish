M = {}

---! 设置初始道具
function M:init_item()
    ---! 初始鱼币
    self:change_prop_count(GamePropIds.kGamePropIdsFishIcon, FISH_SERVER_CONFIG.initFishicon)

    ---! 初始水晶
    self:change_prop_count(GamePropIds.kGamePropIdsCrystal, FISH_SERVER_CONFIG.initCrystal)

    ---! 初始启航礼包
    self:add_senior_prop_quick(GameSeniorPropIds.kGameSeniorPropIdsNewbieGift)
    
    ---! 初始明日礼包
    self:add_senior_prop_quick(GameSeniorPropIds.kGameSeniorPropIdsTomorrowGift)
end

---! 获取道具数量
function M:get_prop_count(propId)
    local props = self:query_temp("item", "props")
    if not props then
        return 0
    end

    for _, prop in pairs(props) do
        if prop.propId == propId then
            return prop.propCount
        end
    end
    return 0
end

---! 修改道具数量
function M:change_prop_count(propId, offset, changeType)
    local props = self:query_temp("item", "props")
    if not props then
        self:set_temp("item", "props", {})
    end

    local props = self:query_temp("item", "props")
    for _, prop in pairs(props) do
        if prop.propId == propId then
            prop.propCount = prop.propCount + offset
            return
        end
    end
    props[#props + 1] = { propId = propId, propCount = offset}
end

---! 增加高级道具
-- propId:道具类型id
-- stringProp:字符串属性
-- intProp1:数字属性1
-- intProp2:数字属性2
function M:add_senior_prop(propId, stringProp, intProp1, intProp2)
    local maxSeniorPropId = self:query_temp("maxSeniorPropId") or 0
    local seniorProps = self:query_temp("item", "seniorProps") or {}
    local propItemId = maxSeniorPropId + 1

    local prop = {}
    prop.propId = propId
    prop.stringProp = stringProp or ""
    prop.intProp1 = intProp1 or 0
    prop.intProp2 = intProp2 or 0
    prop.propItemId = propItemId
    seniorProps[propItemId] = prop

    self:set_temp("maxSeniorPropId", propItemId)
    self:set_temp("item", "seniorProps", seniorProps)
    return prop
end

---! 快速添加高级道具，在内部会对不同道具id做特定处理
function M:add_senior_prop_quick(propId)
    local config = assert(ITEM_CONFIG:get_config_by_id(propId))
    if propId == GameSeniorPropIds.kGameSeniorPropIdsTomorrowGift then
        -- 明日礼包
        return self:add_senior_prop(propId, "", os.time())
    elseif propId == GameSeniorPropIds.kGameSeniorPropIdsNewbieGift then
        -- 新手礼包
        return self:add_senior_prop(propId, "", os.time())
    elseif config.itemtype == 1 and config.taste_time > 0 then
        -- 限时炮台
        return self:add_senior_prop(propId, "", os.time() + config.taste_time)  
    elseif propId == GameSeniorPropIds.kGameSeniorPropIdsCatchFishRate or propId == GameSeniorPropIds.kGameSeniorPropIdsAutoShoot then
        -- 捕获道具
        local config = ITEM_CONFIG:get_config_by_id(propId)
        local itemProp = self:get_senior_prop_by_id(propId)
        if not itemProp then
            return self:add_senior_prop(propId, "", os.time() + config.taste_time)
        end
        itemProp.intProp1 = itemProp.intProp1 + config.taste_time
        return itemProp
    end
    return self:add_senior_prop(propId)
end

---! 删除高级道具
function M:erase_senior_prop(propItemId)
    local seniorProps = self:query_temp("item", "seniorProps") 
    if not seniorProps then
        return
    end
    
    seniorProps[propItemId] = nil
    self:set_temp("item", "seniorProps", seniorProps)
end

---! 是否有高级道具
function M:has_senior_prop(propId, propItemId)
    local seniorProps = self:query_temp("item", "seniorProps") 
    if not seniorProps then
        return false
    end

    local seniorProp = seniorProps[propItemId]
    if not seniorProp then
        return false
    end

    if seniorProp.propId ~= propId then
        return false
    end

    return true
end

---! 获取是否由某一类的高级道具
function M:get_senior_prop_by_id(propId)
    local seniorProps = self:query_temp("item", "seniorProps") 
    if not seniorProps then
        return
    end

    for _, seniorProp in pairs(seniorProps) do
        if seniorProp.propId == propId then
            return seniorProp
        end
    end
end

---! 生成用户相关信息
function M:generate_palyer_info()

end

function M:get_props()
    return self:query_temp("item", "props") or {}
end

function M:get_senior_props()
    return self:query_temp("item", "seniorProps") or {}
end

F_CHAR_ITEM = M
