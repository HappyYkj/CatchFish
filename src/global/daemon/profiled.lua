local _prevented = {}
local _callstack = {}
local _rawstats = {}
local _lastclock = 0

-------------------------------------------------------------------------------
---! 内部方法
-------------------------------------------------------------------------------

-- Internal function to calculate a pretty name for the profile output
local function _pretty_name(func)
    -- Only the data collected during the actual run seems to be correct.... why?
    local info = _rawstats[func].func_info
    --local info = debug.getinfo(func)

    local name = ""
    if info.what == "Lua" then
        name = "L:"
    end

    if info.what == "C" then
        name = "C:"
    end

    if info.what == "main" then
        name = " :"
    end

    if info.name == nil then
        name = name .. "<"..tostring(func) .. ">"
    else
        name = name .. info.name
    end

    if info.source then
        name = name .. "@" .. info.source
    elseif info.what == "C" then
        name = name .. "@?"
    else
        name = name .. "@<string>"
    end

    name = name .. ":"
    if info.what == "C" then
        name = name .. "?"
    else
        name = name .. info.linedefined
    end

    return name
end

-- This returns a (possibly empty) function record for the specified function.
-- It is for internal profiler use.
local function _get_func_rec(func, info)
    -- Find the function ref for 'func' or create one
    local ret = _rawstats[func]
    if not ret then
        -- Build a new function statistics table
        ret = {}
        ret.func = func
        ret.count = 0
        ret.time = 0
        ret.anon_child_time = 0
        ret.name_child_time = 0
        ret.children = {}
        ret.children_time = {}
        ret.func_info = info
        _rawstats[func] = ret
    end
    return ret
end

--
-- This is the main by-function-call function of the profiler and should not
-- be called except by the hook wrapper
--
local function _profiler_hook_wrapper_by_call(action)
    -- Since we can obtain the 'function' for the item we've had call us, we can use that...
    local caller_info = debug.getinfo(3)
    if caller_info == nil then
        print "No caller_info"
        return
    end

    -- Retrieve the most recent activation record...
    local latest_ar = nil
    if #_callstack > 0 then
        latest_ar = _callstack[#_callstack]
    end

    -- Are we allowed to profile this function?
    local should_not_profile = 0
    for k,v in pairs(_prevented) do
        if k == caller_info.func then
            should_not_profile = v
        end
    end

    -- Also check the top activation record...
    if latest_ar then
        if latest_ar.should_not_profile == 2 then
            should_not_profile = 2
        end
    end

    -- Now then, are we in 'call' or 'return' ?
    -- print("Profile:", caller_info.name, "SNP:", should_not_profile, "Action:", action )
    if action == "call" then
        -- Making a call...
        local this_ar = {}
        this_ar.should_not_profile = should_not_profile
        this_ar.parent_ar = latest_ar
        this_ar.anon_child = 0
        this_ar.name_child = 0
        this_ar.children = {}
        this_ar.children_time = {}
        this_ar.clock_start = os.clock()
        -- Last thing to do on a call is to insert this onto the ar stack...
        table.insert(_callstack, this_ar)
    else
        local this_ar = latest_ar
        if this_ar == nil then
            -- No point in doing anything if no upper activation record
            return
        end

        -- Right, calculate the time in this function...
        this_ar.clock_end = os.clock()
        this_ar.this_time = this_ar.clock_end - this_ar.clock_start

        -- Now, if we have a parent, update its call info...
        if this_ar.parent_ar then
            this_ar.parent_ar.children[caller_info.func] = (this_ar.parent_ar.children[caller_info.func] or 0) + 1
            this_ar.parent_ar.children_time[caller_info.func] = (this_ar.parent_ar.children_time[caller_info.func] or 0) + this_ar.this_time

            if caller_info.name == nil then
                this_ar.parent_ar.anon_child = this_ar.parent_ar.anon_child + this_ar.this_time
            else
                this_ar.parent_ar.name_child = this_ar.parent_ar.name_child + this_ar.this_time
            end
        end

        -- Now if we're meant to record information about ourselves, do so...
        if this_ar.should_not_profile == 0 then
            local inforec = _get_func_rec(caller_info.func)
            inforec.count = inforec.count + 1
            inforec.time = inforec.time + this_ar.this_time
            inforec.anon_child_time = inforec.anon_child_time + this_ar.anon_child
            inforec.name_child_time = inforec.name_child_time + this_ar.name_child
            inforec.func_info = caller_info
            for k,v in pairs(this_ar.children) do
                inforec.children[k] = (inforec.children[k] or 0) + v
                inforec.children_time[k] = (inforec.children_time[k] or 0) + this_ar.children_time[k]
            end
        end

        -- Last thing to do on return is to drop the last activation record...
        table.remove(_callstack, #_callstack)
    end
end

--
-- This is the main by-time internal function of the profiler and should not
-- be called except by the hook wrapper
--
local function _profiler_hook_wrapper_by_time(action)
    -- we do this first so we add the minimum amount of extra time to this call
    local timetaken = os.clock() - _lastclock

    local depth = 3
    local at_top = true
    local last_caller
    local caller = debug.getinfo(depth)
    while caller do
        if not caller.func then
             caller.func = "(tail call)"
        end

        if _prevented[caller.func] == nil then
            local info = _get_func_rec(caller.func, caller)
            info.count = info.count + 1
            info.time = info.time + timetaken

            if last_caller then
                -- we're not the head, so update the "children" times also
                if last_caller.name then
                    info.name_child_time = info.name_child_time + timetaken
                else
                    info.anon_child_time = info.anon_child_time + timetaken
                end

                info.children[last_caller.func] = (info.children[last_caller.func] or 0) + 1
                info.children_time[last_caller.func] = (info.children_time[last_caller.func] or 0) + timetaken
            end
        end

        depth = depth + 1
        last_caller = caller
        caller = debug.getinfo(depth)
    end

    _lastclock = os.clock()
end

-------------------------------------------------------------------------------
---! 对外接口
-------------------------------------------------------------------------------
PROFILE_D = {}

--
-- This function starts the profiler.  It will do nothing
-- if this (or any other) profiler is already running.
--
function PROFILE_D:start(variant, sampledelay)
    variant = variant or "time"

    if variant ~= "time" and variant ~= "call" then
      print("Profiler method must be 'time' or 'call'.")
      return
    end

    -- _callstack, _rawstats = {}, {}

    self.variant = variant
    if self.variant == "time" then
        _lastclock = os.clock()
        debug.sethook(_profiler_hook_wrapper_by_time, "cr", sampledelay or 100000)
    elseif self.variant == "call" then
        debug.sethook(_profiler_hook_wrapper_by_call, "cr")
    end
end

--
-- This function stops the profiler.  It will do nothing
-- if a profiler is not running, and nothing if it isn't
-- the currently running profiler.
--
function PROFILE_D:stop()
    -- Stop the profiler.
    debug.sethook()
end

--
-- This writes a profile report to the output file object.  If
-- sort_by_total_time is nil or false the output is sorted by
-- the function time minus the time in it's children.
--
function PROFILE_D:report(outfile, sort_by_total_time)
    outfile = outfile or io.stdout

    -- This is pretty awful.
    local terms = {}
    if self.variant == "time" then
        terms.capitalized = "Sample"
        terms.single = "sample"
        terms.pastverb = "sampled"
    elseif self.variant == "call" then
        terms.capitalized = "Call"
        terms.single = "call"
        terms.pastverb = "called"
    else
        assert(false)
    end

    local total_time = 0
    local ordering = {}
    for func,record in pairs(_rawstats) do
        table.insert(ordering, func)
    end

    if sort_by_total_time then
        table.sort(ordering, function(a,b)
            return _rawstats[a].time > _rawstats[b].time
        end)
    else
        table.sort(ordering, function(a,b)
            local arec = _rawstats[a]
            local brec = _rawstats[b]
            local atime = arec.time - (arec.anon_child_time + arec.name_child_time)
            local btime = brec.time - (brec.anon_child_time + brec.name_child_time)
            return atime > btime
        end)
    end

    outfile:write("Lua Profile output created by profiled.lua. Copyright HappyServer 2019\n")
    for i=1,#ordering do
        local func = ordering[i]
        local record = _rawstats[func]
        local thisfuncname = _pretty_name(func)
        if string.len(thisfuncname) < 42 then
            local str = string.rep("-", math.floor((42 - string.len(thisfuncname))/2))
            thisfuncname = string.format("%s %s %s", str, thisfuncname, str)
        end

        total_time = total_time + (record.time - (record.anon_child_time + record.name_child_time))

        local timeinself = record.time - (record.anon_child_time + record.name_child_time)
        outfile:write(string.format("-------------------%s-------------------\n", thisfuncname))
        outfile:write(string.format("%s count:         %4d\n", terms.capitalized, record.count))
        outfile:write(string.format("Time spend total:       %4.3fs\n", record.time))
        outfile:write(string.format("Time spent in children: %4.3fs\n", record.anon_child_time + record.name_child_time))
        outfile:write(string.format("Time spent in self:     %4.3fs\n", timeinself))
        outfile:write(string.format("Time spent per %s:  %4.5fs/%s\n", terms.single, record.time/record.count, terms.single))
        outfile:write(string.format("Time spent in self per %s:  %4.5fs/%s\n", terms.single, timeinself/record.count, terms.single))

        -- Report on each child in the form
        -- Child  <funcname> called n times and took a.bs
        local added_blank = 0
        for k,v in pairs(record.children) do
            if _prevented[k] == nil or _prevented[k] == 0 then
                if added_blank == 0 then
                    outfile:write("\n") -- extra separation line
                    added_blank = 1
                end

                local thisfuncname = _pretty_name(k)
                outfile:write(string.format("Child %s %s %s %6d times. Took %4.5fs\n",
                                            thisfuncname,
                                            string.rep(" ", 41-string.len(thisfuncname)),
                                            terms.pastverb,
                                            v,
                                            record.children_time[k]))
            end
        end
        outfile:write("\n") -- extra separation line
        outfile:flush()
    end
    outfile:write("\n\n")
    outfile:write(string.format("Total time spent in profiled functions: %5.3gs\n",total_time))
    outfile:write("\n\nEND\n")
    outfile:flush()
end

--
-- This writes the profile to the output file object as
-- loadable Lua source.
--
function PROFILE_D:lua_report(outfile)
    outfile = outfile or io.stdout

    -- Purpose: Write out the entire raw state in a cross-referenceable form.
    local ordering = {}
    local functonum = {}
    for func,record in pairs(_rawstats) do
        table.insert(ordering, func)
        functonum[func] = #ordering
    end

    outfile:write("-- Profile generated by profiled.lua. Copyright HappyServer 2019\n\n")

    outfile:write("-- Function names\nfuncnames = {}\n")
    for i=1,#ordering do
        outfile:write(string.format("funcnames[%d] = %s\n", i, _pretty_name(ordering[i])))
    end
    outfile:write("\n")

    outfile:write("-- Function times\nfunctimes = {}\n")
    for i=1,#ordering do
        local record = _rawstats[ordering[i]]
        outfile:write(string.format("functimes[%d] = { tot=%s, achild=%s, nchild=%s, count=%s }\n",
                      i, record.time, record.anon_child_time, record.name_child_time, record.count))
    end
    outfile:write("\n")

    outfile:write("-- Child links\nchildren = {}\n")
    for i=1,#ordering do
        local numarr = {}
        local record = _rawstats[ordering[i]]
        for k,v in pairs(record.children) do
            if functonum[k] then -- non-recorded functions will be ignored now
                table.insert(numarr, functonum[k])
            end
        end
        outfile:write(string.format("children[%d] = { " .. string.rep("%s,", #numarr) .. " }\n", i, table.unpack(numarr)))
    end
    outfile:write("\n")

    outfile:write("-- Child call counts\nchildcounts = {}\n")
    for i=1,#ordering do
        local numarr = {}
        local record = _rawstats[ordering[i]]
        for k,v in pairs(record.children) do
            if functonum[k] then -- non-recorded functions will be ignored now
                table.insert(numarr, v)
            end
        end
        outfile:write(string.format("childcounts[%d] = { " .. string.rep("%s,", #numarr) .. " }\n", i, table.unpack(numarr)))
    end
    outfile:write("\n")

    outfile:write("-- Child call time\nchildtimes = {}\n")
    for i=1,#ordering do
        local numarr = {}
        local record = _rawstats[ordering[i]]
        for k,v in pairs(record.children) do
            if functonum[k] then -- non-recorded functions will be ignored now
                table.insert(numarr, record.children_time[k])
            end
        end
        outfile:write(string.format("childtimes[%d] = { " .. string.rep("%s,", #numarr) .. " }\n", i, table.unpack(numarr)))
    end
    outfile:write("\n")

    outfile:write("\n-- That is all.\n\n")
    outfile:flush()
end

--
-- This allows you to specify functions which you do
-- not want profiled.  Setting level to 1 keeps the
-- function from being profiled.  Setting level to 2
-- keeps both the function and its children from
-- being profiled.
--
-- BUG: 2 will probably act exactly like 1 in "time" mode.
-- If anyone cares, let me (zorba) know and it can be fixed.
--
function PROFILE_D:prevent(func, level)
    _prevented[func] = level or 1
end

for _, func in pairs(PROFILE_D) do
    _prevented[func] = 2
end
