local string_rep = assert(string.rep)
local string_format = assert(string.format)
local table_concat = assert(table.concat)

local function _table2str(lua_table, raw_table, table_map, n, fold, indent)
    indent = indent or 1
    for k, v in pairs(lua_table) do
        if type(k) == 'string' then
            k = string_format('%q', k)
        else
            k = tostring(k)
        end
        n = n + 1; raw_table[n] = string_rep('    ', indent)
        n = n + 1; raw_table[n] = '['
        n = n + 1; raw_table[n] = k
        n = n + 1; raw_table[n] = ']'
        n = n + 1; raw_table[n] = ' = '
        if type(v) == 'table' then
            if fold and table_map[tostring(v)] then
                n = n + 1; raw_table[n] = tostring(v)
                n = n + 1; raw_table[n] = ',\n'
            else
                table_map[tostring(v)] = true
                n = n + 1; raw_table[n] = '{\n'
                n = _table2str(v, raw_table, table_map, n, fold, indent + 1)
                n = n + 1; raw_table[n] = string_rep('    ', indent)
                n = n + 1; raw_table[n] = '},\n'
            end
        else
            if type(v) == 'string' then
                s = string_format('%q', v)
            else
                s = tostring(v)
            end
            n = n + 1; raw_table[n] = '('
            n = n + 1; raw_table[n] = type(v)
            n = n + 1; raw_table[n] = ') '
            n = n + 1; raw_table[n] = s
            n = n + 1; raw_table[n] = ',\n'
        end
    end
    return n
end

function dump (lua_table, fold)
    local output = lua_table
    if type(lua_table) == 'table' then
        local raw_table = {}
        local table_map = {}
        table_map[tostring(lua_table)] = true
        local n = 0
        n = n + 1; raw_table[n] = '{\n'
        n = _table2str(lua_table, raw_table, table_map, n, fold)
        n = n + 1; raw_table[n] = '}'
        output = table_concat(raw_table, '')
    end
    print (output)
end
