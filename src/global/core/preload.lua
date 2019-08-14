local __printf = printf
printf = function (fmt, ...)
    print(string.format(tostring(fmt), ...))
end
