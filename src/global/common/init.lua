local post_init_funcs = {}

function register_post_init(func)
    post_init_funcs[#post_init_funcs + 1] = func
end

function post_init(...)
    for _, func in ipairs(post_init_funcs) do
        pcall(func, ...)
    end
end

dump = require "global.common.dump"