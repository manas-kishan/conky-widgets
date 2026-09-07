# ⛩️ Conky Widgets Collection

A modular, modern suite of custom Conky desktop widgets designed with high-impact typography and clean aesthetic principles.

Currently featuring the **Okami Time Widget**, rendered with the artistic Japanese brush font **Okami**.

![Conky Okami Widgets Showcase](assets/showcase.png)

---

## 📸 Preview & Layouts

| **Inline Minimalist Layout** (`time-okami.conf`) | **Vertical Stacked Layout** (`time-okami-stacked.conf`) |
| :---: | :---: |
| <img src="assets/preview-inline.png" alt="Inline Layout" width="500"/> | <img src="assets/preview-stacked.png" alt="Stacked Layout" width="300"/> |
| Horizontal brush clock with weekday and full date. | Compact stacked hours and minutes with crimson accent. |

---

## 📦 Prerequisites

Before installing, ensure you have **Conky** and **Git** installed on your Linux distribution:

### Debian / Ubuntu / Linux Mint / Pop!_OS
```bash
sudo apt update
sudo apt install conky-all git fontconfig
```

### Arch Linux / Manjaro
```bash
sudo pacman -S conky git fontconfig
```

### Fedora / RHEL
```bash
sudo dnf install conky git fontconfig
```

---

## 🚀 Installation & Quick Start

### 1. Clone the Repository
Clone this repository to your local machine (e.g. into your home folder or `~/.config/`):

```bash
git clone https://github.com/manas-kishan/conky-widgets.git
cd conky-widgets
```

### 2. One-Click Installation & Launch
Run the installer to automatically register fonts, configure permissions, and launch the widgets:

```bash
chmod +x install.sh control.sh
./install.sh
```

### 3. Launching Widgets
The widgets are modular—you can launch **both together**, or run **either individually**:

```bash
# Launch both Clock and Calendar:
./control.sh st             # (or: ./control.sh start)

# Or launch only the Clock:
./control.sh st clo         # (or: ./control.sh start clock)

# Or launch only the Calendar:
./control.sh st cal         # (or: ./control.sh start calendar)
```

### 4. Customizing & Tweaking Widgets
You can customize and tweak every widget element directly from [`control.sh`](file:///mnt/BA72ED5A72ED1C3F/VS%20Code%20Projects/conky/control.sh).

#### Clock Layouts (`clo`):
```bash
# 12-Hour Horizontal (Default inline)
./control.sh twk-- clo 12h-h     # (or: ./control.sh twk 12h-h)

# 12-Hour Vertical (Stacked)
./control.sh twk-- clo 12h-v     # (or: ./control.sh twk 12h-v)

# 24-Hour Horizontal (Inline)
./control.sh twk-- clo 24h-h     # (or: ./control.sh twk 24h-h)

# 24-Hour Vertical (Stacked)
./control.sh twk-- clo 24h-v     # (or: ./control.sh twk 24h-v)
```

#### Calendar Layouts (`cal`):
```bash
# 7-Day Grid (7 numbers per row left-to-right under Month & Day - Default)
./control.sh twk-- cal grid      # (or: ./control.sh twk cal grid)

# Single Vertical Column (01..31)
./control.sh twk-- cal col       # (or: ./control.sh twk cal col)
```

#### Multi-Item Tweaks (Batch in One Command):
You can tweak multiple widgets at the same time:
```bash
# Explicit widget pairs:
./control.sh twk-- clo 12h-v cal grid

# Ultra-short direct combo:
./control.sh twk-- 12h-v grid
./control.sh 12h-v col

# Multi-widget Presets:
./control.sh preset compact      # 12h-h Clock + 7-Day Grid Calendar (Default)
./control.sh preset stacked      # 12h-v Clock + Vertical Column Calendar
./control.sh preset tech         # 24h-h Clock + 7-Day Grid Calendar
./control.sh preset stacked-24h  # 24h-v Clock + Vertical Column Calendar
```

#### Interactive Tweak Menu:
```bash
./control.sh twk                 # (or: ./control.sh tweak)
```

### 5. Stopping or Restarting Widgets
```bash
# Stop all widgets:
./control.sh sp                  # (or: ./control.sh stop)

# Stop an individual widget:
./control.sh sp clo              # Stop clock
./control.sh sp cal              # Stop calendar

# Restart all widgets:
./control.sh rs                  # (or: ./control.sh restart)

# Check status of running widgets:
./control.sh stat                # (or: ./control.sh status)
```

---

## 📁 Repository Structure

```text
conky-widgets/
├── assets/                           # Layout screenshots and showcase preview
├── fonts/
│   └── Okami.otf                     # Bundled Okami brush font
├── widgets/
│   ├── clock/                        # Standalone Clock module [alias: clo]
│   │   ├── clock.conf                # Single unified config (12h/24h, horiz/vert)
│   │   ├── start.sh                  # Clock launcher
│   │   └── stop.sh                   # Clock terminator
│   └── calendar/                     # Standalone Calendar module [alias: cal]
│       ├── calendar.conf             # Month / Day header with dynamic date column
│       ├── okami-calendar.lua        # Vertical date column Lua script
│       ├── start.sh                  # Calendar launcher
│       └── stop.sh                   # Calendar terminator
├── install.sh                        # One-click installer & setup script
├── control.sh                        # Central CLI manager (start/stop/restart/tweak/status)
└── README.md
```

---

## 🎨 Customization Guide

All configuration files are written in standard, clean Conky Lua syntax.

### Changing Colors
Open `widgets/clock/clock.conf` or `widgets/calendar/calendar.conf` and edit the color variables:

```lua
color1 = 'E63946',  -- Accent color (Day of week / AM-PM indicator)
color2 = 'F5F5F7',  -- Primary time digits & upcoming dates
color3 = '8D99AE',  -- Subtitles / past dates
```

Popular accent colors:
- **Crimson Vermilion** (Default): `E63946`
- **Amber Gold**: `FFA300`
- **Neon Cyan**: `00F0FF`
- **Emerald Mint**: `2EC4B6`
- **Purple Orchid**: `9D4EDD`

### 12-Hour vs 24-Hour Format
In `widgets/clock/clock.conf`, find `conky.text`:

- **12-Hour Format with AM/PM** (Default):
  ```lua
  ${voffset -65}${offset 24}${color2}${font Okami:size=120}${time %I:%M}${voffset -15}${color1}${font Okami:size=30} ${time %p}${voffset 15}${font}
  ```
- **24-Hour Format**:
  ```lua
  ${voffset -65}${offset 24}${color2}${font Okami:size=120}${time %H:%M}${font}
  ```

### Position & Screen Offsets
Modify the window placement parameters inside `conky.config`:

```lua
alignment = 'top_left',   -- Options: 'top_left', 'top_right', 'bottom_left', 'bottom_right', 'middle_middle'
gap_x = 40,               -- Horizontal offset from screen edge (pixels)
gap_y = 40,               -- Vertical offset from screen edge (pixels)
```

---

## 🔄 Autostart on Boot (Any Linux Desktop)

Because Conky needs your desktop environment and window compositor to finish loading before drawing, a small startup delay (5–10 seconds) is recommended.

### Method 1: Graphical Startup Applications (GNOME, Cinnamon, KDE, XFCE)
1. Open your desktop's **Startup Applications** (or **Autostart**) settings.
2. Click **Add / New**.
3. Fill in the fields:
   - **Name**: `Conky Okami Widgets`
   - **Command**:
     ```bash
     /bin/bash -c "sleep 8 && /path/to/conky-widgets/control.sh st"
     ```
     *(Replace `/path/to/conky-widgets` with your actual cloned repository path, e.g. `/home/yourusername/conky-widgets`).*
   - **Delay**: `8` seconds (if supported by your UI).
4. Save and exit.

### Method 2: Standard XDG Autostart Desktop File
Create an autostart desktop entry:

```bash
mkdir -p ~/.config/autostart
nano ~/.config/autostart/conky-okami.desktop
```

Paste the following (make sure to replace `/path/to/conky-widgets` with your actual path):

```ini
[Desktop Entry]
Type=Application
Name=Conky Okami Widgets
Comment=Launch Okami Conky Widgets on login
Exec=/bin/bash -c "sleep 8 && /path/to/conky-widgets/control.sh st"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
```

---

## ➕ Adding More Widgets

The project structure is built to scale modularly:
1. Create a new directory under `widgets/`, for example `widgets/system-stats/` or `widgets/weather/`.
2. Place your `.conf` files and optional `start.sh`/`stop.sh` inside.
3. `./control.sh` will automatically detect your new widget:
   ```bash
   ./control.sh ls
   ./control.sh st system-stats
   ```

---

## 🔧 Troubleshooting

- **Font not showing properly?** Re-run `./install.sh` to refresh the fontconfig cache.
- **Widget not launching?** Run Conky in the foreground to view any errors:
   ```bash
   conky -c "./widgets/clock/clock.conf" -i 1
   # or
   conky -c "./widgets/calendar/calendar.conf" -i 1
   ```
- **Transparency / compositor issues?** Ensure your desktop compositor is enabled, and verify `own_window_transparent = false` and `own_window_argb_visual = true` in the configuration.

---

## 📄 License

This project is open source. Feel free to customize and expand upon it for your desktop setups!
