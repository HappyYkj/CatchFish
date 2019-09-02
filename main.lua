---! 初始化随机数
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

require "const"
require "global.core.preload"
require "global.core.lfstool"
require "global.common.init"
require "global.common.dump"
require "global.common.utils"
require "global.common.class"
require "global.daemon.serviced"

local config = require "config"
if config.debug then
    spdlog.set_level(spdlog.level.debug)
else
    spdlog.set_level(spdlog.level.info)
end

local secs = os.clock()
load_all("feature")
load_all("object")
load_all("daemon")
load_all("config")
load_all("channel")
load_all("cmd")
load_all("log")
local cost = os.clock() - secs
printf("Load all files OK. cost total secs = %s", cost)

post_init()
SERVICE_D:mainloop()
post_dest()

SERVICE_D:exit()
