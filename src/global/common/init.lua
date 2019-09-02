function error_traceback(err)
    print(err)
    print(debug.traceback())
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
    local _post_init_funcs, post_init_funcs = post_init_funcs, {}
    for _, func in ipairs(_post_init_funcs) do
        xpcall(func, error_traceback)
    end

    if #post_init_funcs > 0 then
        post_init()
    end
end

-------------------------------------------------------------------------------
-- POST_DEST
-------------------------------------------------------------------------------
local post_dest_funcs = {}

function register_post_dest(func, ...)
    local para = table.pack(...)
    post_dest_funcs[#post_dest_funcs + 1] = function() func(table.unpack(para)) end
end

function post_dest()
    local _post_dest_funcs, post_dest_funcs = post_dest_funcs, {}
    for _, func in ipairs(_post_dest_funcs) do
        xpcall(func, error_traceback)
    end

    if #post_dest_funcs > 0 then
        post_dest()
    end
end
