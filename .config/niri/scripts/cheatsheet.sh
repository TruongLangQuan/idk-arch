#!/usr/bin/env bash
# Fuzzel-based Keyboard Shortcuts Cheatsheet for Niri WM

BINDS="💻 Mod+T           ::  Open Terminal (foot / kitty)
🚀 Mod+D           ::  App Launcher (fuzzel)
🔒 Super+Alt+L     ::  Lock Screen (hyprlock)
📋 Mod+V           ::  Clipboard History
😀 Mod+Period      ::  Emoji Picker
🖼️ Ctrl+Mod+T      ::  Change Wallpaper Menu
📶 Mod+A / Mod+G   ::  Toggle System Controls Dashboard
🔔 Mod+N           ::  Toggle Control Center Sidebar
📊 Mod+M           ::  Toggle Floating Music Visualizer (cava)
📅 Hover Clock     ::  Show Calendar Popup
🚪 Ctrl+Alt+Delete ::  Exit Session Menu (wlogout)
❌ Mod+Q           ::  Close Window
📂 Mod+Tab         ::  Toggle Overview
🎯 Mod+R           ::  Cycle Column Width preset
🎯 Mod+Shift+R     ::  Cycle Column Width preset (reverse)
↔️ Mod+H / Mod+L   ::  Focus Left / Focus Right
↕️ Mod+J / Mod+K   ::  Focus Down / Focus Up
🔄 Mod+Ctrl+H/J/K/L::  Move Window Left / Down / Up / Right
🖥️ Mod+Shift+H/J/K/L:: Move Window to Output Left / Down / Up / Right
🏠 Mod+Home/End    ::  Focus First / Last Column
📸 Print Screen    ::  Full Screenshot
📸 Alt+Print       ::  Window Screenshot
📸 Mod+Shift+S     ::  Interactive Snipping Area"

# Display in Fuzzel
echo -e "$BINDS" | fuzzel --dmenu --prompt="Niri Shortcuts >> "
