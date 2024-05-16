local _, BFI = ...
local U = BFI.utils

---------------------------------------------------------------------
-- number
---------------------------------------------------------------------
local symbol_1K, symbol_10K, symbol_1B
if LOCALE_zhCN then
    symbol_1K, symbol_10K, symbol_1B = "千", "万", "亿"
elseif LOCALE_zhTW then
    symbol_1K, symbol_10K, symbol_1B = "千", "萬", "億"
elseif LOCALE_koKR then
    symbol_1K, symbol_10K, symbol_1B = "천", "만", "억"
end

if BFI.vars.isAsian then
    function U.FormatNumber(n)
        if abs(n) >= 100000000 then
            return string.format("%.3f"..symbol_1B, n/100000000)
        elseif abs(n) >= 10000 then
            return string.format("%.2f"..symbol_10K, n/10000)
        -- elseif abs(n) >= 1000 then
        --     return string.format("%.1f"..symbol_1K, n/1000)
        else
            return n
        end
    end
else
    function U.FormatNumber(n)
        if abs(n) >= 1000000000 then
            return string.format("%.3fB", n/1000000000)
        elseif abs(n) >= 1000000 then
            return string.format("%.2fM", n/1000000)
        elseif abs(n) >= 1000 then
            return string.format("%.1fK", n/1000)
        else
            return n
        end
    end
end

---------------------------------------------------------------------
-- table
---------------------------------------------------------------------
function U.Getn(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function U.GetIndex(t, e)
    for i, v in pairs(t) do
        if e == v then
            return i
        end
    end
    return nil
end

function U.GetKeys(t)
    local keys = {}
    for k in pairs(t) do
        tinsert(keys, k)
    end
    return keys
end

function U.Copy(t)
    local newTbl = {}
    for k, v in pairs(t) do
        if type(v) == "table" then  
            newTbl[k] = U.Copy(v)
        else  
            newTbl[k] = v  
        end  
    end
    return newTbl
end

function U.Contains(t, v)
    for _, value in pairs(t) do
        if value == v then return true end
    end
    return false
end

function U.Insert(t, v)
    local i, done = 1
    repeat
        if not t[i] then
            t[i] = v
            done = true
        end
        i = i + 1
    until done
end

function U.Remove(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            table.remove(t, i)
        end
    end
end

function U.Merge(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then return end
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k]) ~= "table" then t1[k] = {} end
            U.Merge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

function U.RemoveElementsExceptKeys(tbl, ...)
    local keys = {}

    for i = 1, select("#", ...) do
        local k = select(i, ...)
        keys[k] = true
    end

    for k in pairs(tbl) do
        if not keys[k] then
            tbl[k] = nil
        end
    end
end

function U.RemoveElementsByKeys(tbl, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        tbl[k] = nil
    end
end