local error_func = function(err)
    spdlog.error(err)
    spdlog.error(debug.traceback())
end

-------------------------------------------------------------------------------
-- POST_INIT
-------------------------------------------------------------------------------
local post_init_funcs = {}

function register_post_init(func, ...)
    local para = table.pack(...)
    post_init_funcs[#post_init_funcs + 1] = function() func(table.unpack(para)) end
end

function post_init()
    for _, func in ipairs(post_init_funcs) do
        xpcall(func, error_func)
    end
end

-------------------------------------------------------------------------------
-- POST_DEST
-------------------------------------------------------------------------------
local post_dest_funcs = {}

function register_post_desk(func, ...)
    local para = table.pack(...)
    post_dest_funcs[#post_dest_funcs + 1] = function() func(table.unpack(para)) end
end

function post_dest()
    for _, func in ipairs(post_dest_funcs) do
        xpcall(func, error_func)
    end
end
