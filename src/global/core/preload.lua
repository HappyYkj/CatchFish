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

---! 初始化随机数
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
