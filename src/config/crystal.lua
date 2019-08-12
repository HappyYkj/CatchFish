
local tbl = CONFIG_D:get_table("crystal")
if not tbl then
    return
end

local configs = {}
for key, row in pairs(tbl) do
    local config = {}
    config.id = row.id                          -- 索引
    config.num1 = row.crystal_num1              -- 水晶掉落间隔1（历史掉落数量）
    config.num2 = row.crystal_num2              -- 水晶掉落间隔2（历史掉落数量）
    config.crystal_cost = row.crystal_cost      -- 奖励乘数（服务器计算乘数*最大炮倍）
    configs[config.id] = config
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------

CRYSTAL_CONFIG = {}

function CRYSTAL_CONFIG:get_crystal_rate_cost(history_drop)
    for _, config in pairs(configs) do repeat
        if history_drop < config.num1 then
            break
        end

        if config.num2 and history_drop > config.num2 then
            break
        end

        return config.crystal_cost
    until true end

    return 10000000
end

-- 掉落水晶/鱼券配置
local dropCrystalConfig = {
	-- 第一类鱼(普通鱼)(炮倍按当前炮倍计算）
	[1] = {
		[30] = "2,80;18,0;0,0", --1-30
		[50] = "2,50;18,0;0,50",  -- 31-50
		[100] = "2,30;18,0;0,70",
		[200] = "2,10;18,0;0,90",
		[500] = "2,0;18,0;0,100",
		[1000] = "2,0;18,0;0,100",
		[7000] = "2,0;18,0;0,100",
		[10000] = "2,0;18,0;0,100",
	},

	--第二类鱼(奖金鱼)
	[2] = {
	    [30] = "2,100;18,0;0,0",
		[50] = "2,100;18,0;0,0",
		[100] = "2,100;18,0;0,0",
		[200] = "2,85;18,0;0,15",
		[500] = "2,75;18,0;0,25",
		[1000] = "2,70;18,0;0,30",
		[3000] = "2,60;18,0;0,40",
		[5000] = "2,50;18,0;0,50",
		[7000] = "2,40;18,0;0,60",
		[9500] = "2,30;18,0;0,70",
		[10000] = "2,25;18,0;0,75",
	},

	-- 第三类鱼
	--[3] = {
		--[100] = "2,30;16,40;0,50",  -- 1-100倍
		--[200] = "2,30;16,40;0,50",  -- 101-无穷大
	--}
}

-- 最大鱼券/水晶掉落个数
-- propId:道具id
-- roomType:房间类型
-- gunRate:炮倍
function getMaxCrystalPropDrop(propId, roomType, gunRate)
end

-- 获得击杀鱼掉落
-- fish_type:鱼类型，1为普通鱼，2为奖金鱼，3为boss
-- gunrate:最大炮倍
-- 返回值格式为道具id1,权重1;道具id2,权重2...
-- 如2,100;18,0;0,0
function CRYSTAL_CONFIG:get_crystal_rate_drop(fish_type, gunrate)
	local tab = dropCrystalConfig[fish_type]
	if tab == nil then
		return 0
	end

	local lastId = 0
	local keys = {}
	for index, id in pairs(tab) do
		table.insert(keys, index)
	end
	if #keys <= 0 then 
		return 0
	end
	
	table.sort(keys)
	local rewards = tab[#keys]
	for _, id in ipairs(keys) do
		if id >= gunrate then
			rewards = tab[id]
		end
	end
	
	local weight = 0
	local splitlist = {}
	string.gsub(rewards, '[^%s;]+', function(reward)
		local splititem = {}
		string.gsub(reward, '[^%s,]+', function(item)
			table.insert(splititem, item)
		end)
		
		if #splititem == 2 and tonumber(splititem[2]) > 0 then
			weight = weight + tonumber(splititem[2])
			table.insert(splitlist, splititem)
		end  
	end)
	
	if weight > 0 then 
		local index = math.random(weight)
		for _, splititem in ipairs(splitlist) do 
			if index < tonumber(splititem[2]) then
				return tonumber(splititem[1])
			end
			index = index - tonumber(splititem[2])
		end 
	end
	return 0
end

function CRYSTAL_CONFIG:get_crystal_max_drop_prop_count(gunrate)
	if gunrate <= 50 then
		return 1
	elseif gunrate <= 80 then
		return 2
	elseif gunrate <= 200 then
		return 3
	elseif gunrate <= 500 then
		return 4
	elseif gunrate <= 1000 then
		return 5
	elseif gunrate <= 3000 then
		return 6
	elseif gunrate <= 8000 then
		return 8
	else
		return 4
	end
end
