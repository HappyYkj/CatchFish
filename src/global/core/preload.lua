local __printf = printf
printf = function (fmt, ...)
    print(string.format(tostring(fmt), ...))
end

dump = function (t, prefix)
    prefix = prefix or ""
	for k,v in pairs(t) do
		print(prefix, k, v)
		if type(v) == "table" then
			dump(v, prefix .. "." .. k)
		end
	end
end

traceback = function ( msg )
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end
