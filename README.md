# ⛩️ Conky Okami Widgets

A minimalist, modular desktop widget suite for Linux featuring the Japanese brush font **Okami**.

## 📸 Layouts

### Clock Variants
| 12-Hour Horizontal (Default) | 12-Hour Vertical | 24-Hour Horizontal | 24-Hour Vertical |
| :---: | :---: | :---: | :---: |
| <img src="assets/clock_12h-h.png" width="220" alt="Clock 12h-h"/> | <img src="assets/clock_12h-v.png" width="100" alt="Clock 12h-v"/> | <img src="assets/clock_24h-h.png" width="220" alt="Clock 24h-h"/> | <img src="assets/clock_24h-v.png" width="100" alt="Clock 24h-v"/> |

### Calendar Variants
| 7-Day Row Grid (Default) | Vertical Column (01..31) |
| :---: | :---: |
| <img src="assets/calendar_grid.png" width="320" alt="Calendar Grid"/> | <img src="assets/calendar_column.png" width="160" alt="Calendar Column"/> |

### System Identity
| Hostname & OS Banner |
| :---: |
| <img src="assets/system_identity.png" width="300" alt="System Identity"/> |

---

## ⚡ Quick Start

```bash
# 1. Install system dependencies (Debian/Ubuntu/Mint)
sudo apt install conky-all fontconfig git

# 2. Clone & Install
git clone https://github.com/manas-kishan/conky-widgets.git
cd conky-widgets
./install.sh
```
> ⛩️ **Font Requirement**: This widget uses the Japanese brush font **Okami**. Due to licensing, the font file is not bundled in this repo. Download it for free from **[FontsHut](https://www.fontshut.com/okami-font/)** and install it, or place `Okami.otf` in this folder before running `./install.sh`.

---

## 🕹️ Controls & Cheatsheet (`./control.sh`)

Manage everything from the root `./control.sh` script:

### Common Commands
| Action | Command | Description |
| :--- | :--- | :--- |
| **Start** | `./control.sh st` | Start all widgets (`st clo`, `st cal`, `st sys`) |
| **Stop** | `./control.sh sp` | Stop all widgets (`sp clo`, `sp cal`, `sp sys`) |
| **Restart** | `./control.sh rs` | Reload / apply config changes |
| **Status** | `./control.sh stat` | Check running Conky processes |
| **Interactive** | `./control.sh twk` | Open guided tweak menu |

### Layout Switching
```bash
# Clock Variants (clo)
./control.sh clo 12h-h             # 12-Hour Horizontal (Default)
./control.sh clo 12h-v             # 12-Hour Vertical (Stacked)
./control.sh clo 24h-h             # 24-Hour Horizontal (Inline)
./control.sh clo 24h-v             # 24-Hour Vertical (Stacked)

# Calendar Variants (cal)
./control.sh cal grid              # 7-Day Row Grid (Default)
./control.sh cal col               # Vertical Column (01..31)

# System Identity Variants (sys)
./control.sh sys katana            # Katana Cut: Layered slash over text (Default)
./control.sh sys clean             # Inline Slash: Clean slash between words
./control.sh sys none              # Simple Text: Words without slash
./control.sh sys text LONE WOLF    # Set custom words dynamically

# Multi-Widget Presets & Combos
./control.sh compact              # Preset: 12h-h Clock + 7-Day Grid (Default)
./control.sh stacked              # Preset: 12h-v Clock + Vertical Column
./control.sh tech                 # Preset: 24h-h Clock + 7-Day Grid
./control.sh stacked-24h          # Preset: 24h-v Clock + Vertical Column
./control.sh 12h-v grid           # Custom mix: 12h-v Clock + Grid Calendar
./control.sh 12h-h col            # Custom mix: 12h-h Clock + Column Calendar
```

---

## 🎨 Customization (Colors, Positions & Sizing)

Each widget has a single configuration file:
- **Clock**: `widgets/clock/clock.conf`
- **Calendar**: `widgets/calendar/calendar.conf`
- **System**: `widgets/system/system.conf`

### 1. Colors
Edit the hex values in any `.conf` file:
```lua
color1 = 'E63946',  -- Accent (AM/PM, weekday, today's date, system slash)
color2 = 'F5F5F7',  -- Primary (clock digits, upcoming dates, hostname)
color3 = '8D99AE',  -- Muted (month title, past dates, OS subtitle)
```

### 2. Positioning
Adjust screen placement inside `conky.config` in each file:
- **Clock** (`widgets/clock/clock.conf`):
  ```lua
  alignment = 'top_left',   -- Screen anchor (top_left, top_right, etc.)
  gap_x     = 40,           -- Horizontal distance from screen edge (px)
  gap_y     = 0,            -- Sits at the top of the screen
  ```
- **Calendar** (`widgets/calendar/calendar.conf`):
  ```lua
  alignment = 'top_left',   -- Match clock alignment
  gap_x     = 40,           -- Keep equal to clock to stay aligned flush
  gap_y     = 140,          -- Distance from top (140 puts it under the clock)
  ```
- **System** (`widgets/system/system.conf`):
  ```lua
  alignment = 'top_middle', -- Centered at the top of the screen
  gap_x     = 0,            -- Center anchor (no horizontal offset needed)
  gap_y     = 0,            -- Sits flush at the absolute top of the screen
  ```

### 3. Font Scaling
Change sizes in `conky.text`:
- **Clock digits**: `font Okami:size=120` (horizontal) or `size=84` (vertical)
- **Month/Day banner**: `font Okami:size=28`
- **Calendar numbers**: In `widgets/calendar/okami-calendar.lua` (`size=15` for grid, `size=13` for column)
- **System hostname**: In `widgets/system/system.conf` (`pixelsize=64` for letters, `pixelsize=109` for crimson slash)

> **Tip**: After editing any file, run `./control.sh rs` to reload changes immediately.

---

## 🔄 Autostart on Login

Add this command to your desktop's **Startup Applications** (with a 5–8 second delay):
```bash
/bin/bash -c "sleep 8 && /path/to/conky-widgets/control.sh st"
```

---

## 📄 License
MIT License. Free to use and customize!
