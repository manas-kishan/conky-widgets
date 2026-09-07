--[[
# ==============================================================================
# Script: okami-calendar.lua
# Description: Generates calendar dates (vertical column or 7-column grid)
# Column positions: left (under month) or right (under weekday)
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

function conky_calendar_column(pos)
    local today = tonumber(os.date("%d"))
    local year = tonumber(os.date("%Y"))
    local month = tonumber(os.date("%m"))
    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day

    pos = pos and string.lower(pos) or ""
    if pos == "" then
        local home = os.getenv("HOME") or ""
        local mode_file = home .. "/.config/conky/calendar.mode"
        local f = io.open(mode_file, "r")
        if f then
            local line = f:read("*l")
            if line and line:match("%S") then
                pos = line:match("^%s*(.-)%s*$"):lower()
            end
            f:close()
        end
    end

    local is_right = (pos == "right" or pos == "r" or pos == "col-right" or pos == "col-r" or pos == "vertical-right")
    local x_tag = is_right and "${goto 328}" or "${offset 18}"

    local lines = {}
    for d = 1, days_in_month do
        local d_str = string.format("%02d", d)
        local color
        if d < today then
            color = "${color3}"
        elseif d == today then
            color = "${color1}"
        else
            color = "${color2}"
        end
        local line = string.format("%s%s${font Okami:size=13}%s${font}", x_tag, color, d_str)
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
