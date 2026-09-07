--[[
# ==============================================================================
# Script: okami-calendar.lua
# Description: Generates calendar dates (vertical column or 7-column grid)
# Colors: Slate grey (past), crimson (today), off-white (upcoming)
# ==============================================================================
]]

function conky_calendar_grid()
    local today = tonumber(os.date("%d"))
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day

    -- 7 column horizontal X positions spanning under SEPTEMBER / MONDAY
    local col_xs = {16, 68, 120, 172, 224, 276, 328}
    local lines = {}
    local cur_row = {}
    local col_idx = 1
    local row_num = 0

    for d = 1, days_in_month do
        local d_str = string.format("%02d", d)
        local x = col_xs[col_idx]
        local color
        if d < today then
            color = "${color3}"
        elseif d == today then
            color = "${color1}"
        else
            color = "${color2}"
        end

        table.insert(cur_row, string.format("${goto %d}%s%s", x, color, d_str))
        col_idx = col_idx + 1

        if col_idx > 7 or d == days_in_month then
            local prefix = ""
            if row_num == 0 then
                prefix = "${voffset 14}${font Okami:size=15}"
            else
                prefix = "${voffset -8}"
            end
            table.insert(lines, prefix .. table.concat(cur_row, ""))
            cur_row = {}
            col_idx = 1
            row_num = row_num + 1
        end
    end
    table.insert(lines, "${font}")
    return table.concat(lines, "\n")
end

function conky_calendar_column()
    local today = tonumber(os.date("%d"))
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day
    
    local lines = {}
    for d = 1, days_in_month do
        local d_str = string.format("%02d", d)
        local line
        if d < today then
            line = string.format("${offset 18}${color3}${font Okami:size=13}%s${font}", d_str)
        elseif d == today then
            line = string.format("${offset 18}${color1}${font Okami:size=13}%s${font}", d_str)
        else
            line = string.format("${offset 18}${color2}${font Okami:size=13}%s${font}", d_str)
        end
        if d > 1 then
            line = "${voffset -7}" .. line
        end
        table.insert(lines, line)
    end
    return table.concat(lines, "\n")
end

-- Backwards compatibility alias
function conky_date_column()
    return conky_calendar_column()
end
