# 🔧 Conky Widgets: Troubleshooting & File Placement Guide

This guide details exactly **where files should live on your system**, how Linux and Conky locate them, and **step-by-step troubleshooting** for common issues (fonts, transparency, desktop layering, and autostart).

---

## 📍 Part 1: Where Files Belong on Your Device

Understanding where files reside prevents missing font errors, broken paths, and autostart failures.

### Summary Table

| Asset | Recommended Location on Linux | Alternative / Standard Path |
| :--- | :--- | :--- |
| **Widget Project / Repository** | `/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/` | `~/.conky/` or `~/.config/conky/` |
| **Custom Fonts (`.otf`, `.ttf`)** | `~/.local/share/fonts/` | `~/.fonts/` (legacy) |
| **Desktop Autostart Files** | `~/.config/autostart/` | Cinnamon Startup Applications UI |
| **Legacy Conky Startup Script** | `~/.conky/conky-startup.sh` | N/A |
| **System-wide Conky Defaults** | `/etc/conky/conky.conf` *(do not edit)* | N/A |

---

### Detailed Placement Rules

#### 1. Font Files (`.otf`, `.ttf`)
Conky relies on Linux's **FontConfig** (`libfontconfig`) to look up fonts by family name (`Okami`).
- **Where to place**:
  ```bash
  ~/.local/share/fonts/
  ```
- **How to register after placing**:
  Linux does not immediately see newly pasted fonts until you refresh the cache:
  ```bash
  fc-cache -fv ~/.local/share/fonts
  ```
- **Verification**:
  ```bash
  fc-match "Okami"
  # Expected output: Okami.otf: "Okami" "Regular"
  ```

---

#### 2. Conky Configuration Files (`.conf`)
You have two great ways to store your configurations:

- **Option A (Recommended — Direct in Repo)**:
  Keep configurations directly inside your Git repository:
  ```bash
  /mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/time-okami.conf
  ```
  *Benefit*: All edits are tracked in Git, and you can push your changes to GitHub without copying files around.

- **Option B (Symlink into `~/.conky/`)**:
  If you use tools like Conky Manager:
  ```bash
  mkdir -p ~/.conky/Okami-Time
  ln -s "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/time-okami.conf" ~/.conky/Okami-Time/Okami-Time
  ```

---

#### 3. Autostart On Boot
To make Conky start automatically when you log into Cinnamon:

- **Location**:
  ```bash
  ~/.config/autostart/conky-okami-time.desktop
  ```
- **File content example**:
  ```ini
  [Desktop Entry]
  Type=Application
  Exec=/bin/bash -c "sleep 8 && '/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/start.sh'"
  Hidden=false
  NoDisplay=false
  X-GNOME-Autostart-enabled=true
  Name=Conky Okami Time
  Comment=Launch Okami Conky Widget on login
  ```
  *(The `sleep 8` delay is essential to ensure Cinnamon's window manager and desktop compositor finish loading before Conky attaches).*

---

## 🛠️ Part 2: Step-by-Step Troubleshooting

### Diagnostic Quick-Check (Run this first!)
Run this single command to diagnose your setup in 3 seconds:

```bash
echo "=== 1. Process Check ===" && pgrep -a conky && \
echo "=== 2. Font Check ===" && fc-match "Okami" && \
echo "=== 3. Syntax Dry Run ===" && conky -c "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/time-okami.conf" -i 1
```

If any step outputs an error, check the specific section below.

---

### Issue 1: Conky Exits Immediately or Doesn't Show Up

#### Cause:
1. Syntax error in the Lua configuration file.
2. Background process terminated with `SIGHUP` when the terminal window closed.
3. Path to configuration file is wrong or inaccessible.

#### How to Troubleshoot:
1. **Run in Foreground with Debugging**:
   Never rely only on background scripts when debugging. Run Conky in the foreground:
   ```bash
   conky -c "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/widgets/time-okami/time-okami.conf" -D
   ```
   - If there is a Lua syntax error (e.g. missing comma, unmatched bracket), Conky will print the exact line number.
   - `-D` prints detailed debug information about window creation, XFT, and geometry.

2. **Ensure proper detachment**:
   If Conky only runs while the terminal is open and closes when the terminal closes, use `setsid`:
   ```bash
   setsid conky -c "/path/to/time-okami.conf" </dev/null >/dev/null 2>&1 &
   ```

---

### Issue 2: Font Shows as Generic Monospace or Displays Question Marks (`?`)

#### Cause:
1. **Generic Monospace**: FontConfig cannot find `"Okami"` in its font directories, so it falls back to the system default font.
2. **Question Mark `?`**: The text contains characters not present in the font glyph table (e.g. the pipe symbol `|`, special emojis, or unsupported symbols).

#### How to Troubleshoot:
1. **Check if FontConfig knows about the font**:
   ```bash
   fc-list : family | grep -i "Okami"
   ```
   If nothing is returned, install the font:
   ```bash
   cp "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky/fonts/Okami.otf" ~/.local/share/fonts/
   fc-cache -fv ~/.local/share/fonts
   ```

2. **Character Set Limitations**:
   The **Okami brush font** contains:
   - Digits (`0-9`)
   - Letters (`A-Z`, `a-z`)
   - Common punctuation: colon `:`, comma `,`, period `.`, slash `/`, hyphen `-`.
   - **Does NOT contain**: pipe `|`, curly braces `{}`, or degree symbols `°`.
   - *Fix*: Use `/` or `-` as separators instead of `|`.

---

### Issue 3: Solid Black or Opaque Box Behind the Widget (No Transparency)

#### Cause:
Cinnamon compositing or incorrect Conky window parameters.

#### How to Troubleshoot:
Open `time-okami.conf` and verify these exact settings:
```lua
own_window = true,
own_window_type = 'normal',        -- Works best on Cinnamon/GNOME
own_window_transparent = false,     -- Must be false when ARGB is used
own_window_argb_visual = true,      -- Enables 32-bit true alpha channel
own_window_argb_value = 0,          -- 0 = 100% transparent background
own_window_colour = '000000',
double_buffer = true,
```
> [!IMPORTANT]
> If you set `own_window_transparent = true` while `own_window_argb_visual = true`, transparency may break on modern compositors. Keep `own_window_transparent = false` and `own_window_argb_value = 0`.

---

### Issue 4: Conky Vanishes When Pressing "Show Desktop" (Super+D)

#### Cause:
The window type is set to `normal` instead of `desktop`, or window hints do not tell Cinnamon to keep the window docked below all layers.

#### How to Troubleshoot:
1. **Check Window Hints**:
   Ensure `time-okami.conf` includes:
   ```lua
   own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
   ```
2. **Alternative Window Types for Cinnamon**:
   If pressing `Super + D` ("Show Desktop") still minimizes Conky, change `own_window_type` in the config:
   - Try: `own_window_type = 'desktop'`
   - Or try: `own_window_type = 'dock'`

---

### Issue 5: Widget is Cut Off or Text Overlaps

#### Cause:
`minimum_width` or `minimum_height` is smaller than the rendered text, or `voffset` moved a line too close to the previous line.

#### How to Troubleshoot:
1. Increase `minimum_width` or `maximum_width`:
   ```lua
   minimum_width = 420,
   maximum_width = 550,
   ```
2. Adjust `voffset` in `conky.text`:
   - Positive `${voffset 10}` pushes text **down**.
   - Negative `${voffset -15}` pulls text **up**.
   - Adjust in increments of 5 pixels until aligned.

---

### Issue 6: Multiple Conky Widgets Colliding / Killing Each Other

#### Cause:
Running `killall conky` kills every widget, including Gotham or any other monitor you have running.

#### How to Troubleshoot:
1. Use targeted process management by passing the config file path to `pkill`:
   ```bash
   # Stop ONLY the Okami widget:
   pkill -f "conky -c .*time-okami"

   # Stop ONLY Gotham:
   pkill -f "conky -c .*Gotham"
   ```
2. Or use the built-in control script:
   ```bash
   ./scripts/conky-control.sh stop time-okami
   ```

---

## 📋 Emergency Reset

If Conky becomes unresponsive or you want a completely fresh start:

```bash
# 1. Kill all running conky processes
killall -9 conky 2>/dev/null || true

# 2. Refresh font cache
fc-cache -f ~/.local/share/fonts

# 3. Launch Okami Time Widget cleanly
cd "/mnt/BA72ED5A72ED1C3F/VS Code Projects/conky"
./widgets/time-okami/start.sh

# 4. Verify it is running
pgrep -a conky
```
