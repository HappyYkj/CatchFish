---! 加载默认方法
require "global.common.init"
require "global.common.dump"
require "global.common.class"

local utils = require "pl.utils"

---! 默认加载 string 扩展包
utils.import("pl.stringx", string)

---! 默认加载 table 扩展包
utils.import("pl.tablex", table)

function printf(fmt, ...)
    print(string.format(tostring(fmt), ...))
end

function error_traceback(err)
    print(err)
    print(debug.traceback())
end

function randomchoice(t)
    return t[math.random(#t)]
end

function weightedchoice(t)
    local sum = 0
    for _, v in pairs(t) do
        assert(v >= 0, "weight value less than zero")
        sum = sum + v
    end
    assert(sum ~= 0, "all weights are zero")
    local rnd = random(sum)
    for k, v in pairs(t) do
        if rnd < v then return k end
        rnd = rnd - v
    end
end

---! 初始化随机数
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
