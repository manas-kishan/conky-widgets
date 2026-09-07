# ⛩️ Conky Okami Widgets Collection

A modular, aesthetic suite of desktop widgets for Linux, featuring powerful Japanese calligraphy typography (**Okami** brush font), clean minimalist layouts, and a streamlined CLI control manager.

![Conky Okami Widgets Showcase](assets/showcase.png)

---

## ✨ Features

- **🧩 Truly Modular Design**: Run the **Clock** and **Calendar** together or completely independently without dependencies between them.
- **⚡ Single Config Architecture**: No duplicated configuration files. Each widget utilizes a single dynamic `.conf` file with embedded Lua logic that responds to runtime mode switches.
- **🕒 Multi-Format Clock**: Supports **12-Hour Horizontal** (with inline Crimson AM/PM), **12-Hour Vertical** (stacked), **24-Hour Horizontal**, and **24-Hour Vertical**.
- **📅 Dual-Mode Calendar**:
  - **7-Day Grid (Default)**: Clean horizontal calendar (7 numbers per row) precisely aligned under the Month and Day banner.
  - **Vertical Column**: Artistic vertical list (`01..31`) highlighting today's date in crimson.
- **🕹️ Lightning CLI Manager (`./control.sh`)**: Ultra-short commands (`st`, `sp`, `rs`, `twk--`, `stat`, `ls`), multi-widget batch tweaking, and 1-word presets.
- **🎨 Dynamic Color & Geometry Customization**: Easily tailor accent colors, positioning, margins, and font scaling.
- **🚀 One-Click Installer (`./install.sh`)**: Automated dependency checks, bundled font installation, and live widget startup.

---

## 📸 Preview & Layout Variants

| **Horizontal 12h Clock + 7-Day Grid Calendar (Default)** | **Vertical 12h Clock + Vertical Column Calendar** |
| :---: | :---: |
| <img src="assets/preview-inline.png" alt="Horizontal Inline Layout" width="480"/> | <img src="assets/preview-stacked.png" alt="Vertical Stacked Layout" width="320"/> |
| *Large brush time digits with inline AM/PM and compact 7-day row grid.* | *Stacked hour/minute with vertical date column (01..31).* |

---

## 📦 Prerequisites

Before installation, ensure **Conky** and **FontConfig** are installed on your system:

### Debian / Ubuntu / Linux Mint / Pop!_OS
```bash
sudo apt update
sudo apt install conky-all fontconfig git
```

### Arch Linux / Manjaro
```bash
sudo pacman -S conky fontconfig git
```

### Fedora / RHEL
```bash
sudo dnf install conky fontconfig git
```

---

## 🚀 Quick Start & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/manas-kishan/conky-widgets.git
cd conky-widgets
```

### 2. Run the One-Click Installer
The installer registers the bundled **Okami** font in `~/.local/share/fonts/`, refreshes the font cache, sets executable permissions, initializes configuration in `~/.config/conky/`, and launches the widgets:

```bash
chmod +x install.sh control.sh
./install.sh
```

---

## 🕹️ CLI Control Manager (`./control.sh`)

Manage all widgets from a single root script using intuitive commands and short aliases:

### 1. Lifecycle Commands
```bash
# Start widgets:
./control.sh st                  # Start all widgets
./control.sh st clo              # Start Clock only
./control.sh st cal              # Start Calendar only

# Stop widgets:
./control.sh sp                  # Stop all widgets
./control.sh sp clo              # Stop Clock only
./control.sh sp cal              # Stop Calendar only

# Restart widgets:
./control.sh rs                  # Restart all widgets
./control.sh rs clo              # Restart Clock only
./control.sh rs cal              # Restart Calendar only

# Check status:
./control.sh stat                # View running Conky processes
./control.sh ls                  # List available widgets
```

---

### 2. Layout Tweaks (Individual Widgets)

#### Clock Layouts (`clo`):
```bash
./control.sh twk-- clo 12h-h     # 12-Hour Horizontal (Default)
./control.sh twk-- clo 12h-v     # 12-Hour Vertical (Stacked)
./control.sh twk-- clo 24h-h     # 24-Hour Horizontal (Inline)
./control.sh twk-- clo 24h-v     # 24-Hour Vertical (Stacked)
```

#### Calendar Layouts (`cal`):
```bash
./control.sh twk-- cal grid      # 7-Day Row Grid (Default)
./control.sh twk-- cal col       # Single Vertical Column (01..31)
```

---

### 3. Multi-Item Tweaks (Batch in One Command)

Tweak multiple widgets simultaneously without running separate commands:

```bash
# 1. Shorthand layout pair (fastest):
./control.sh 12h-v grid          # Clock -> 12h Vertical, Calendar -> 7-Day Grid
./control.sh 12h-h col           # Clock -> 12h Horizontal, Calendar -> Column
./control.sh twk-- 24h-h grid    # Clock -> 24h Horizontal, Calendar -> 7-Day Grid

# 2. Explicit widget pairs:
./control.sh twk-- clo 12h-v cal grid
./control.sh twk-- clo 24h-h cal col
```

---

### 4. One-Word Presets

Quickly switch between complete aesthetic combinations:

```bash
./control.sh preset compact      # 12h-h Clock + 7-Day Grid Calendar (Default)
./control.sh preset stacked      # 12h-v Clock + Vertical Column Calendar
./control.sh preset tech         # 24h-h Clock + 7-Day Grid Calendar
./control.sh preset stacked-24h  # 24h-v Clock + Vertical Column Calendar
```

---

### 5. Interactive Menu
Prefer a guided menu? Simply run:
```bash
./control.sh twk
```
From here you can tweak individual widgets or select a full preset combo.

---

## 📁 Repository Structure

```text
conky-widgets/
├── assets/                           # Layout screenshots and showcase preview
├── fonts/
│   └── Okami.otf                     # Bundled Japanese brush font
├── widgets/
│   ├── clock/                        # Standalone Clock module [alias: clo]
│   │   ├── clock.conf                # Unified multi-mode Conky config
│   │   ├── clock.mode                # Shipped default mode
│   │   ├── start.sh                  # Clock launcher
│   │   └── stop.sh                   # Clock terminator
│   └── calendar/                     # Standalone Calendar module [alias: cal]
│       ├── calendar.conf             # Unified multi-mode Conky config
│       ├── calendar.mode             # Shipped default mode
│       ├── okami-calendar.lua        # Pure Lua date generator (grid & column)
│       ├── start.sh                  # Calendar launcher
│       └── stop.sh                   # Calendar terminator
├── install.sh                        # One-click installer & setup script
├── control.sh                        # Central CLI manager (start/stop/tweak/status)
└── README.md
```

---

## 🎨 Customization Guide (Positions, Dimensions & Colors)

All widgets are configured using standard Conky Lua syntax. You can customize screen placement, dimensions, font sizes, and color themes in [widgets/clock/clock.conf](file:///mnt/BA72ED5A72ED1C3F/VS%20Code%20Projects/conky/widgets/clock/clock.conf) and [widgets/calendar/calendar.conf](file:///mnt/BA72ED5A72ED1C3F/VS%20Code%20Projects/conky/widgets/calendar/calendar.conf).

### 1. Positions & Screen Alignment
Each widget's placement is defined inside its `conky.config` table:

```lua
conky.config = {
    alignment = 'top_left',   -- Screen anchor: top_left, top_right, bottom_left, bottom_right, etc.
    gap_x = 40,               -- Horizontal distance in pixels from the screen edge
    gap_y = 140,              -- Vertical distance in pixels from the screen edge
    ...
}
```

- **Horizontal Position (`gap_x`)**:
  - Found in `widgets/clock/clock.conf` and `widgets/calendar/calendar.conf`. Keep both values identical (default: `40`) to keep clock and calendar aligned flush to the left.
- **Vertical Spacing (`gap_y`)**:
  - **Clock**: Dynamically set in `widgets/clock/clock.conf` (`gap_y = 0` for horizontal mode, `gap_y = 20` for vertical stacked mode).
  - **Calendar**: Set in `widgets/calendar/calendar.conf` (`gap_y = 140` by default). Increase this value (e.g. `160`) to add more breathing room under the clock, or decrease it (e.g. `120`) to pull it closer.

---

### 2. Dimensions & Font Sizes

#### A. Window Canvas Boundaries
Set inside `conky.config` of each widget:
```lua
minimum_width  = 380,   -- Minimum canvas width in pixels
maximum_width  = 460,   -- Maximum allowed canvas width
minimum_height = 240,   -- Canvas height (auto-scales with content)
```

#### B. Font Sizes & Micro-Spacing
Fine-tune element scaling in `conky.text`:

* **Clock Digits & AM/PM** (`widgets/clock/clock.conf`):
  ```lua
  ${voffset -65}${offset 24}${color2}${font Okami:size=120}${time %I:%M}${voffset -15}${color1}${font Okami:size=30} ${time %p}${voffset 15}${font}
  ```
  - `size=120`: Main clock digits size.
  - `size=30`: `AM`/`PM` label size.
  - `${voffset <N>}`: Micro-adjusts vertical position (negative moves up, positive moves down).
  - `${offset <N>}`: Shifts text to the right by `N` pixels.

* **Month & Day Heading** (`widgets/calendar/calendar.conf`):
  ```lua
  ${voffset -10}${offset 16}${color3}${font Okami:size=28}${time %B}  ${color2}/  ${color1}${time %A}${font}
  ```
  - `size=28`: Size of the `SEPTEMBER / MONDAY` heading.

* **Calendar Numbers** (`widgets/calendar/okami-calendar.lua`):
  - **7-Day Grid**: Line 40 (`size=15`).
  - **Vertical Column**: Line 70 (`size=13`).
  - **Grid Column Spacing**: Line 16 defines the horizontal pixel alignment for each of the 7 columns:
    ```lua
    local col_xs = {16, 68, 120, 172, 224, 276, 328}
    ```

---

### 3. Color Palettes & Accents

Colors are defined using 6-character hex codes (without `#`) in `widgets/clock/clock.conf` and `widgets/calendar/calendar.conf`:

```lua
-- Color Palette
default_color = 'FFFFFF',
color1 = 'E63946',  -- Accent: Japanese Crimson / Vermilion
color2 = 'F5F5F7',  -- Primary: Clean Off-White
color3 = '8D99AE',  -- Muted: Slate Grey (Separators & Subtitles)
```

#### What Each Color Controls:
| Color Slot | Role | Applied Elements |
| :--- | :--- | :--- |
| **`color1`** | **Accent** | `AM`/`PM` label, Day of week (`MONDAY`), Today's highlighted date |
| **`color2`** | **Primary** | Main clock digits (`10:06`), Slash (`/`), Upcoming calendar days |
| **`color3`** | **Muted** | Month title (`SEPTEMBER`), Past calendar days |

#### Popular Color Themes:
* **Japanese Crimson** (Default):
  ```lua
  color1 = 'E63946'  -- Crimson Accent
  color2 = 'F5F5F7'  -- Off-White
  color3 = '8D99AE'  -- Slate Grey
  ```
* **Cyberpunk / Neon Cyan**:
  ```lua
  color1 = '00F5D4'  -- Neon Cyan Accent
  color2 = 'FFFFFF'  -- Pure White
  color3 = '7209B7'  -- Neon Violet / Deep Purple
  ```
* **Golden Amber**:
  ```lua
  color1 = 'F4A261'  -- Warm Amber Accent
  color2 = 'FAEDCD'  -- Warm Cream White
  color3 = '6C757D'  -- Neutral Grey
  ```
* **Emerald Mint**:
  ```lua
  color1 = '2EC4B6'  -- Emerald Mint Accent
  color2 = 'FDFFFC'  -- Pure Off-White
  color3 = '606C38'  -- Olive Slate
  ```

---

### 4. Applying Changes
After editing any `.conf` or `.lua` file, reload your widgets instantly:
```bash
./control.sh rs
```

---

## 🔄 Autostart on Boot

To automatically start your widgets when logging into your desktop environment, add a short delay (5–8 seconds) to allow your window manager and compositor to initialize first.

### Method 1: Graphical Startup Applications (Cinnamon, GNOME, KDE, XFCE)
1. Open **Startup Applications** from your application menu.
2. Click **Add / +**.
3. Enter:
   - **Name**: `Conky Okami Widgets`
   - **Command**:
     ```bash
     /bin/bash -c "sleep 8 && /path/to/conky-widgets/control.sh st"
     ```
     *(Replace `/path/to/conky-widgets` with your actual repository path, e.g. `/home/username/conky-widgets`).*
   - **Startup delay**: `8` seconds (if available in your GUI).
4. Save and exit.

### Method 2: Standard XDG Autostart Desktop Entry
Create an autostart desktop file:

```bash
mkdir -p ~/.config/autostart
cat << 'EOF' > ~/.config/autostart/conky-okami.desktop
[Desktop Entry]
Type=Application
Name=Conky Okami Widgets
Comment=Launch Okami Conky Widgets on login
Exec=/bin/bash -c "sleep 8 && /path/to/conky-widgets/control.sh st"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```
*(Remember to update `/path/to/conky-widgets` with your real path).*

---

## ➕ Extending & Adding More Widgets

The architecture makes it effortless to add more widgets to your desktop:
1. Create a new directory under `widgets/`, for example `widgets/system/` or `widgets/weather/`.
2. Add your `.conf` file and optional `start.sh` / `stop.sh` scripts.
3. `./control.sh` will auto-discover your new widget:
   ```bash
   ./control.sh ls
   ./control.sh st system
   ./control.sh sp system
   ```

---

## 🔧 Troubleshooting & FAQ

- **Font rendering incorrectly or showing fallback font?**
  Run `./install.sh` to reinstall fonts, or manually refresh the cache:
  ```bash
  fc-cache -fv ~/.local/share/fonts
  ```
- **Conky window has black background instead of transparent?**
  Ensure your desktop environment has a compositor running (e.g. Picom or Cinnamon/Muffin). Verify that `own_window_argb_visual = true` and `own_window_argb_value = 0` in the widget `.conf`.
- **Widget not launching?**
  Run Conky directly in foreground mode to inspect any syntax or parsing errors:
  ```bash
  conky -c "./widgets/clock/clock.conf" -i 1
  conky -c "./widgets/calendar/calendar.conf" -i 1
  ```

---

## 📄 License

This project is open source under the MIT License. Feel free to use, modify, and distribute it for your custom desktop ricing setups!
