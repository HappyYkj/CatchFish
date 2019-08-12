local lanes = require "lanes"
lanes.configure()

---! 初始化随机数
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

require "include.const"

require "global.core.preload"
require "global.core.lfstool"
require "global.common.utils"
require "global.common.init"

if DEBUG_VERSION then
    spdlog.set_level(spdlog.level.debug)
else
    spdlog.set_level(spdlog.level.info)
end

local secs = lanes.now_secs()
load_all("feature")
load_all("object")
load_all("daemon")
load_all("config")
load_all("channel")
load_all("cmd")
local cost = lanes.now_secs() - secs
printf("Load all files OK. cost total secs = %s", cost)

THREAD_D:run_loop()
