# 🌌 Premium Arch Linux Dotfiles (Niri WM Tiling Environment)

Welcome to your ultimate, highly personalized, and ultra-high-performance **Niri WM** tiling environment! This repository contains all configurations, system package lists (native, AUR, Flatpak), themes, custom control centers, scripts, and wallpapers to deploy your workspace instantly on any Arch Linux machine.

---

## 🎨 Layout Overview
- **Window Manager**: **Niri WM** (minimalist cuộn ngang tiling, `8px` rounded corners, custom monochrome border).
- **Status Bar**: **Waybar** (lightweight monochrome layout, fully integrated month calendar popup).
- **Control Center Sidebar**: **SwayNotificationCenter (swaync)** (gorgeous monochrome dark setting panel with quick settings toggles: Wi-Fi, Bluetooth, Lock Screen, Snipping, Wallpaper).
- **App Launcher**: **Fuzzel** (Space Grotesk & Google Sans Flex typography, `17px` border radius).
- **Session Manager**: **wlogout** (custom Material Icons).
- **Wallpapers**: Loaded with the black-and-white black hole wallpaper via **hyprpaper** block-syntax.
- **Custom Scripts**:
  - `wallpaper-selector.sh` (interactive dmenu wallpaper chooser & randomizer).
  - `system-controls.sh` (brightness, volume, bluetooth, wifi toggles dashboard).
  - `wifi-selector.sh` (scans and connects to Wi-Fi networks).
  - `cheatsheet.sh` (tra cứu phím tắt).

---

## 🚀 Quick Deployment Guide

To deploy this entire desktop environment on a fresh Arch Linux installation, simply open your terminal and run the following command block:

```bash
# Clone the repository
git clone --depth=1 https://codeberg.org/truonglangquan/idk-arch.git
cd idk-arch

# Run the premium automatic installer
./install.sh
```

---

## 📦 What the Installer Does:
1. **System Packages**: Synchronizes and installs all official pacman packages from `packages.txt`.
2. **AUR Integration**: Checks for `yay` and builds it if missing, then installs all AUR helper packages from `aur_packages.txt`.
3. **Flatpak Applications**: Synchronizes and downloads Flatpak applications from `flatpaks.txt`.
4. **Configs & Theme**: Restores all configuration folders (`niri/`, `waybar/`, `swaync/`, `fuzzel/`, `wlogout/`, `nvim/`, `hypr/`, `kitty/`, `fish/`, etc.) into `~/.config/` and sets up your optimized `.vimrc` in `~/`.
5. **Super-Key-Only Tap**: Automatically copies the `keyd` overload configuration to `/etc/keyd/default.conf` and enables `keyd` daemon to map Super-only tap to open Fuzzel launcher.
6. **Default Shell**: Sets `fish` as your default interactive login shell with the Starship prompt activated.

---

## ⌨️ Quick Hotkeys Cheatsheet

| Shortcut | Description | Action |
| :--- | :--- | :--- |
| `Super` (Tap) | **App Launcher** | Opens Fuzzel Search |
| `Mod + Tab` | **Overview** | Toggles workspace scrolling view |
| `Mod + T` | **Terminal** | Spawns Terminal (foot / kitty) |
| `Mod + Q` | **Close Window** | Closes active window |
| `Mod + N` | **Control Center** | Toggles right notification sidebar |
| `Ctrl + Mod + T` | **Change Wallpaper** | Opens Fuzzel Wallpaper selector |
| `Mod + A` / `Mod + G` | **System Dashboard** | Opens volume/brightness Fuzzel controls |
| `Mod + M` | **Music Visualizer** | Spawns a floating sized CAVA terminal |
| `Mod + Shift + S` | **Snipping Tool** | Interactive crop screenshot |
| `Ctrl + Alt + Delete` | **Exit Menu** | Opens wlogout logout/shutdown screen |
| `Mod + /` | **Cheatsheet** | Shows this hotkey cheatsheet |
