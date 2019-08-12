local tbl = CONFIG_D:get_table("config")
if not tbl then
    return
end

-- 初始鱼币数额
local initFishicon = 0
if tbl[990000005] then
    initFishicon = tonumber(tbl[990000005].data)
end

-- 初始水晶数额
local initCrystal = 0
if tbl[990000006] then
    initCrystal = tonumber(tbl[990000006].data)
end

-- 奖金鱼抽奖个数
local drawPriceFishCount = {}
if tbl[990000007] then
    for _, field in ipairs(split(tbl[990000007].data, ";")) do
        drawPriceFishCount[#drawPriceFishCount + 1] = tonumber(field)
    end
end

-- 冰冻掉落必需
local freezeDropRequire = 0
if tbl[990000010] then
    freezeDropRequire = tonumber(tbl[990000010].data)
end

-- 锁定掉落必需
local aimDropRequire = 0
if tbl[990000011] then
    aimDropRequire = tonumber(tbl[990000011].data)
end

-- 技能卡爆率
local skillPropPercent = 0
if tbl[990000012] then
    skillPropPercent = tonumber(tbl[990000012].data)
end

-- 房间不开炮踢人时间
local shootTimeout = 0
if tbl[990000013] then
    shootTimeout = tonumber(tbl[990000013].data)
end

-- 鱼潮来临前技能不能使用间隔
local fishGroupNotifySeconds = 0
if tbl[990000016] then
    fishGroupNotifySeconds = tonumber(tbl[990000016].data)
end

-- 技能卡数量限制
local maxSkillCardCount = 0
if tbl[990000019] then
    maxSkillCardCount = tonumber(tbl[990000019].data)
end

-- 炸弹库值投库比
local bombAccurateRate = 0
if tbl[990000020] then
    bombAccurateRate = tonumber(tbl[990000020].data)
end

-- 房间内公告金额条件
local minAnnounceFishCount = 0
if tbl[990000026] then
    minAnnounceFishCount = tonumber(tbl[990000026].data)
end

-- 月卡持续时间
local maxMonthCardDays = 0
if tbl[990000031] then
    maxMonthCardDays = tonumber(tbl[990000031].data)
end

-- 月卡奖励内容
local monthCardConfig = {}
if tbl[990000032] then
    local fields = split(tbl[990000032].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            monthCardConfig[tonumber(key)] = tonumber(val)
        end
    end
end

-- 普通转盘奖励
local loginDrawConfig = {}
if tbl[990000036] then
    local fields = split(tbl[990000036].data, ";")
    for i = 1, #fields, 3 do
        local propId, propCount, percent = fields[i], fields[i + 1], fields[i + 2]
        if propId and propCount and percent then
            loginDrawConfig[#loginDrawConfig + 1] = {
                propId = tonumber(propId),
                propCount = tonumber(propCount),
                percent = tonumber(percent),
            }
        end
    end
end

-- VIP转盘奖励
local vipDrawConfig = {}
if tbl[990000037] then
    local fields = split(tbl[990000037].data, ";")
    for i = 1, #fields, 3 do
        local propId, propCount, percent = fields[i], fields[i + 1], fields[i + 2]
        if propId and propCount and percent then
            vipDrawConfig[#vipDrawConfig + 1] = {
                propId = tonumber(propId),
                propCount = tonumber(propCount),
                percent = tonumber(percent),
            }
        end
    end
end

-- 累计签到奖励
local signInConfigs = {}
if tbl[990000040] then
    local fields = split(tbl[990000040].data, ";")
    for i = 1, #fields, 3 do
        local days, propId, propCount = fields[i], fields[i + 1], fields[i + 2]
        if propId and propCount and days then
            signInConfigs[#signInConfigs + 1] = {
                propId = tonumber(propId),
                propCount = tonumber(propCount),
                days = tonumber(days),
            }
        end
    end
end

-- VIP转盘每次消耗
local vipDrawFishIconCost = 0
if tbl[990000041] then
    vipDrawFishIconCost = tonumber(tbl[990000041].data)
end

-- 好友每日首次分享奖励
local shareLinkRewards = {}
if tbl[990000042] then
    local fields = split(tbl[990000042].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            shareLinkRewards[tonumber(key)] = tonumber(val)
        end
    end
end

-- 用户邀请码奖励
local inviteRewards = {}
if tbl[990000043] then
    local fields = split(tbl[990000043].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            inviteRewards[tonumber(key)] = tonumber(val)
        end
    end
end

-- 累计签到循环天数
local maxSignDay = 0
if tbl[990000045] then
    maxSignDay = tonumber(tbl[990000045].data)
end

-- 奖金鱼投入奖池比例
local rewardRewardFishDropRate = 0
if tbl[990000052] then
    rewardRewardFishDropRate = tonumber(tbl[990000052].data)
end

-- 补助库值参数扣除比例
local allowanceDropRate = 0
if tbl[990000053] then
    allowanceDropRate = tonumber(tbl[990000053].data)
end

-- 充值库值参数扣除比例
local chargeDropRate = 0
if tbl[990000054] then
    chargeDropRate = tonumber(tbl[990000054].data)
end

-- 历史输赢初始参数值
local initHistoryIconDropValue = 0
if tbl[990000055] then
    initHistoryIconDropValue = tonumber(tbl[990000055].data)
end

-- 高于X倍的鱼记录日志
local recordFishScore = 0
if tbl[990000056] then
    recordFishScore = tonumber(tbl[990000056].data)
end

-- 昵称修改次数
local maxNickNameChangeCount = 0
if tbl[990000059] then
    maxNickNameChangeCount = tonumber(tbl[990000059].data)
end

-- 结晶的掉落折算值
local forgeDropRequre = 0
if tbl[990000060] then
    forgeDropRequre = tonumber(tbl[990000060].data)
end

-- 锻造材料掉落最低炮倍
local minDropFrogeDropGunRate = 0
if tbl[990000061] then
    minDropFrogeDropGunRate = tonumber(tbl[990000061].data)
end

-- 锻造材料投库比
local mapForgeDropRate = {}
if tbl[990000062] then
    local fields = split(tbl[990000062].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            mapForgeDropRate[tonumber(key)] = tonumber(val)
        end
    end
end

-- 锻造材料爆率
local forgeDropPercent = 0
if tbl[990000063] then
    forgeDropPercent = tonumber(tbl[990000063].data)
end

-- 结晶掉落权重
local forgeMesteralDropWeights = {}
if tbl[990000064] then
    local fields = split(tbl[990000064].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            forgeMesteralDropWeights[tonumber(key)] = tonumber(val)
        end
    end
end

-- 单次分解结晶数量
local decomposeCrystalRequire = 0
if tbl[990000065] then
    decomposeCrystalRequire = tonumber(tbl[990000065].data)
end

-- 分解获得结晶能量的数量范围
local decomposeFailEnengyCrystalLowerLimit = 0
local decomposeFailEnengyCrystalLimit = 0
if tbl[990000066] then
    local fields = split(tbl[990000066].data, ";")
    decomposeFailEnengyCrystalLowerLimit = tonumber(fields[1])
    decomposeFailEnengyCrystalLimit = tonumber(fields[2])
end

-- 锻造失败时取整系数
local crystalEnergeDropRateWhenFail = 0
if tbl[990000067] then
    crystalEnergeDropRateWhenFail = tonumber(tbl[990000067].data)
end

-- 奖券兑换（奖券数量；话费元）
local lotteryCostPerRecieve = 0
local phoneFarePerRecieve = 0
if tbl[990000068] then
    local fields = split(tbl[990000068].data, ";")
    lotteryCostPerRecieve = tonumber(fields[1])
    phoneFarePerRecieve = tonumber(fields[2])
end

-- 任务宝箱
local m_mapDailyActiveReward = {}
if tbl[990000080] then
    local fields = split(tbl[990000080].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            m_mapDailyActiveReward[tonumber(key)] = val
        end
    end
end

-- 变倍率区间
local randomBossMinScore = 0
local randomBossMaxScore = 0
if tbl[990000089] then
    local fields = split(tbl[990000089].data, ";")
    randomBossMinScore = tonumber(fields[1])
    randomBossMaxScore = tonumber(fields[2])
end

-- 捕鱼配置版本
local configVersion = 0
if tbl[990000110] then
    configVersion = tonumber(tbl[990000110].data)
end

-- 免费场剩余子弹与炮倍相关
local arrFreeArenaGunRate = {}
if tbl[990000130] then
    local fields = split(tbl[990000130].data, ";")
    for i = 1, #fields, 2 do
        local num, gunrate = fields[i], fields[i + 1]
        if num and gunrate then
            arrFreeArenaGunRate[#arrFreeArenaGunRate + 1] = { num = tonumber(num), gunrate = tonumber(gunrate), }
        end
    end
    table.sort(arrFreeArenaGunRate, function (config1, config2)
        return config1.num < config2.num
    end)
end

---! 限时赛炮倍限制相关
local arrLimitArenaGunRate = {}
if tbl[990000134] then
    local fields = split(tbl[990000134].data, ";")
    for i = 1, #fields, 1 do
        local gunrate = fields[i]
        if gunrate then
            arrLimitArenaGunRate[tonumber(gunrate)] = true
        end
    end
end

-- 明日礼包奖励
local tomorrowGifts = {}
if tbl[990000138] then
    local fields = split(tbl[990000138].data, ";")
    for i = 1, #fields, 2 do
        local key, val = fields[i], fields[i + 1]
        if key and val then
            tomorrowGifts[tonumber(key)] = tonumber(val)
        end
    end
end

-- 锁定道具的消耗倍率
local nLockFishCostRate = 0
if tbl[990000147] then
    nLockFishCostRate = tonumber(tbl[990000147].data)
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

FISH_SERVER_CONFIG = {}

FISH_SERVER_CONFIG.tomorrowGifts = tomorrowGifts
FISH_SERVER_CONFIG.monthCardConfig = monthCardConfig
FISH_SERVER_CONFIG.initHistoryIconDropValue = initHistoryIconDropValue
FISH_SERVER_CONFIG.initFishicon = initFishicon
FISH_SERVER_CONFIG.initCrystal = initCrystal
FISH_SERVER_CONFIG.fishGroupNotifySeconds = fishGroupNotifySeconds
FISH_SERVER_CONFIG.nLockFishCostRate = nLockFishCostRate
FISH_SERVER_CONFIG.maxSkillCardCount = maxSkillCardCount
FISH_SERVER_CONFIG.bombAccurateRate = bombAccurateRate
FISH_SERVER_CONFIG.skillPropPercent = skillPropPercent
FISH_SERVER_CONFIG.freezeDropRequire = freezeDropRequire
FISH_SERVER_CONFIG.aimDropRequire = aimDropRequire
FISH_SERVER_CONFIG.forgeDropRequre = forgeDropRequre
FISH_SERVER_CONFIG.minDropFrogeDropGunRate = minDropFrogeDropGunRate
FISH_SERVER_CONFIG.forgeMesteralDropWeights = forgeMesteralDropWeights
FISH_SERVER_CONFIG.allowanceDropRate = allowanceDropRate
FISH_SERVER_CONFIG.decomposeCrystalRequire = decomposeCrystalRequire
FISH_SERVER_CONFIG.pointRate = 3
FISH_SERVER_CONFIG.multiRatio = 10000

function FISH_SERVER_CONFIG:get_fish_draw_require(draw_count)
    return drawPriceFishCount[math.min(#drawPriceFishCount, draw_count + 1)]
end

function FISH_SERVER_CONFIG:get_enengy_crystal_count(times)
    if decomposeFailEnengyCrystalLimit <= decomposeFailEnengyCrystalLowerLimit then
        return math.max(0, decomposeFailEnengyCrystalLowerLimit * times)
    end

    local count = math.random(decomposeFailEnengyCrystalLowerLimit, decomposeFailEnengyCrystalLimit)
    return math.max(0, count * times)
end

function FISH_SERVER_CONFIG:get_free_arena_gunrate(num)
    for _, config in ipairs(arrFreeArenaGunRate) do
        if num <= config.num then 
            return config.gunrate
        end
    end
    return 1
end

function FISH_SERVER_CONFIG:is_limit_arena_gunrate(gunrate)
    if arrLimitArenaGunRate[gunrate] then
        return true
    end
    return false
end
