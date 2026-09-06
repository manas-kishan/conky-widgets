require 'cairo'

local home = os.getenv("HOME") or ""
local assets_dir = home .. "/.config/conky/time-okami-assets/"

function conky_draw_rotated_day()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    
    local day = conky_parse("${time %A}")
    local img_path = assets_dir .. day .. ".png"
    
    local img = cairo_image_surface_create_from_png(img_path)
    if img ~= nil then
        cairo_save(cr)
        -- Positioned cleanly without clipping, gently overlapping the clock digit
        cairo_set_source_surface(cr, img, 8, 42)
        cairo_paint(cr)
        cairo_restore(cr)
        cairo_surface_destroy(img)
    end
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

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
