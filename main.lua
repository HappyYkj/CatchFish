require "const"
require "global.core.preload"
require "global.core.lfstool"
require "global.daemon.profiled"
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

printf("start post init ...")
local tick = os.clock()
post_init()
local cost = os.clock() - tick
printf("finish init cost tick = %s", cost)

PROFILE_D:start()
SERVICE_D:mainloop()
PROFILE_D:stop()

printf("start post dest ...")
local tick = os.clock()
post_dest()
local cost = os.clock() - tick
printf("finish dest cost tick = %s", cost)

printf("start exit service ...")
local tick = os.clock()
SERVICE_D:exit()
local cost = os.clock() - tick
printf("finish exit service cost tick = %s", cost)

PROFILE_D:report()
