--[[
# ==============================================================================
# Script: okami-calendar.lua
# Description: Generates a vertical date column (01..31) for the current month
# Colors: Slate grey for past, crimson for today, off-white for upcoming
# ==============================================================================
]]

function conky_date_column()
    local today = tonumber(os.date("%d"))
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day
    
    local lines = {}
    for d = 1, days_in_month do
        local d_str = string.format("%02d", d)
        local line
        if d < today then
            -- Past dates: Muted slate grey
            line = string.format("${offset 18}${color3}${font Okami:size=13}%s${font}", d_str)
        elseif d == today then
            -- Today: Accent crimson, aligned within column
            line = string.format("${offset 18}${color1}${font Okami:size=13}%s${font}", d_str)
        else
            -- Upcoming dates: Clean off-white
            line = string.format("${offset 18}${color2}${font Okami:size=13}%s${font}", d_str)
        end
        if d > 1 then
            line = "${voffset -7}" .. line
        end
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end
