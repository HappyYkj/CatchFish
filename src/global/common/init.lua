local post_init_funcs = {}

local error_func = function(err)
    spdlog.error(err)
    spdlog.error(debug.traceback())
end

function register_post_init(func, ...)
    local para = table.pack(...)
    local wrap = function() func(table.unpack(para)) end
    post_init_funcs[#post_init_funcs + 1] = wrap
end

function post_init()
    for _, func in ipairs(post_init_funcs) do
        xpcall(func, error_func)
    end
end

dump = require "global.common.dump"
