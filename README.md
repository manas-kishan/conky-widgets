# ⛩️ Conky Widgets Collection

A modular, modern suite of custom Conky desktop widgets designed with high-impact typography and clean aesthetic principles.

Currently featuring the **Okami Time Widget**, rendered with the artistic Japanese brush font **Okami**.

---

## 📸 Preview

- **Inline Minimalist Layout** (`time-okami.conf`):
  Large textured brush time digits with day of week and full date.
- **Vertical Stacked Layout** (`time-okami-stacked.conf`):
  Stacked hours and minutes with color-coded accent styling.

---

## 📁 Repository Structure

```text
conky-widgets/
├── fonts/
│   └── Okami.otf                     # Bundled Okami brush font
├── scripts/
│   ├── install_fonts.sh              # Font installer & fontconfig cache updater
│   └── conky-control.sh              # Central CLI manager (start/stop/restart/list)
├── widgets/
│   └── time-okami/
│       ├── time-okami.conf           # Primary inline configuration
│       ├── time-okami-stacked.conf   # Vertical stacked configuration
│       ├── start.sh                  # Widget launcher (supports --stacked)
│       └── stop.sh                   # Widget terminator
├── TROUBLESHOOTING.md                # System file paths & troubleshooting guide
└── README.md
```

---

## 🚀 Quick Start

### 1. Install Fonts
Make sure the bundled fonts are linked to your user font directory:
```bash
./scripts/install_fonts.sh
```

### 2. Launching the Widget
You can launch using either the central manager or the widget's own script:

```bash
# Using the central manager:
./scripts/conky-control.sh start time-okami

# Or directly from the widget directory:
cd widgets/time-okami
./start.sh
```

### 3. Using the Stacked Layout
To launch the vertical stacked layout:
```bash
./widgets/time-okami/start.sh --stacked
```

### 4. Stopping the Widget
```bash
./scripts/conky-control.sh stop time-okami
# or
./widgets/time-okami/stop.sh
```

### 5. Checking Status
```bash
./scripts/conky-control.sh status
```

---

## 🎨 Customization Guide

All configuration files (`time-okami.conf` and `time-okami-stacked.conf`) are written in clean Conky Lua syntax.

### Changing Colors
Look for the color definitions in the config file:
```lua
color1 = 'E63946',  -- Accent color (Day of week, minutes in stacked)
color2 = 'F5F5F7',  -- Primary time digits & date
color3 = '8D99AE',  -- Subtitles / separators
```

Popular accents:
- **Crimson Vermilion** (Default): `E63946`
- **Amber Gold**: `FFA300`
- **Neon Cyan**: `00F0FF`
- **Emerald Mint**: `2EC4B6`

### 12-Hour vs 24-Hour Format
In `time-okami.conf`, find `conky.text`:
- For **24-Hour Time**:
  ```lua
  ${color2}${font Okami:size=72}${time %H:%M}${font}
  ```
- For **12-Hour Time**:
  ```lua
  ${color2}${font Okami:size=72}${time %I:%M}${font}
  ```
- To append **AM/PM**:
  ```lua
  ${color2}${font Okami:size=72}${time %I:%M}${font} ${color1}${font Okami:size=22}${time %p}${font}
  ```

### Adjusting Position & Offsets
Change the gap and alignment values in `conky.config`:
```lua
alignment = 'top_left',   -- Options: 'top_left', 'top_right', 'bottom_left', 'bottom_right', 'middle_middle'
gap_x = 40,               -- Horizontal distance from screen edge (pixels)
gap_y = 40,               -- Vertical distance from screen edge (pixels)
```

---

## 🔄 Autostart on Boot (Linux Mint / Cinnamon)

### Method 1: Cinnamon Startup Applications
1. Open **Startup Applications** from your Cinnamon menu.
2. Click **Add** -> **Custom Command**.
3. Name: `Conky Okami Time`
4. Command:
   ```bash
   /bin/bash -c "sleep 8 && '/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/start.sh'"
   ```
5. Set Delay to `5` or `8` seconds (allows Cinnamon desktop compositor to finish loading).
6. Click **Save**.

### Method 2: Conky Startup Script
If you already use `~/.conky/conky-startup.sh`, simply add:
```bash
conky -c "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/time-okami.conf" &
```

---

## ➕ Adding More Widgets in the Future

The framework is designed to be modular:
1. Create a new folder under `widgets/`, e.g., `widgets/system-stats/` or `widgets/weather/`.
2. Add your `.conf` file and optional `start.sh`/`stop.sh`.
3. The central `./scripts/conky-control.sh` manager will automatically recognize and manage it!

---

## 🔧 Troubleshooting & File Placement

If you experience missing fonts, transparency glitches, or need to know where system files belong on Linux:
👉 See the complete guide in [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

