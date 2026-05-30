#!/usr/bin/env bash
# Fuzzel-based Wallpaper Selector for Niri WM

WALLPAPER_DIR="/home/truonglangquan/.config/wallpapers"
CONF_FILE="/home/truonglangquan/.config/hypr/hyprpaper.conf"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send -u critical "Wallpaper Selector" "Wallpaper directory not found!"
    exit 1
fi

# Get list of files
files=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | sort)

if [ -z "$files" ]; then
    notify-send -u critical "Wallpaper Selector" "No wallpapers found in directory!"
    exit 1
fi

# Prepare menu items
declare -A file_map
menu_items="🎲 Random Wallpaper\n"

while IFS= read -r filepath; do
    filename=$(basename "$filepath")
    # Prettify name for display
    display_name=$(echo "$filename" | sed -e 's/^[0-9]\+[-_]//' -e 's/[-_]/ /g' -e 's/\.[a-zA-Z0-9]\+$//')
    file_map["$display_name"]="$filepath"
    menu_items+="$display_name\n"
done <<< "$files"

# Launch Fuzzel menu
selected=$(echo -e -n "$menu_items" | fuzzel --dmenu --prompt="Select Wallpaper >> ")

if [ -z "$selected" ]; then
    exit 0
fi

selected_file=""
if [ "$selected" = "🎲 Random Wallpaper" ]; then
    selected_file=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
else
    selected_file="${file_map[$selected]}"
fi

if [ -z "$selected_file" ] || [ ! -f "$selected_file" ]; then
    notify-send -u critical "Wallpaper Selector" "Could not find selected wallpaper!"
    exit 1
fi

# Update hyprpaper.conf with modern block syntax which is extremely robust in Niri
cat <<EOF > "$CONF_FILE"
preload = $selected_file
wallpaper {
    monitor = LVDS-1
    path = $selected_file
}
wallpaper {
    monitor = 
    path = $selected_file
}
splash = false
EOF

# Restart hyprpaper
pkill hyprpaper || true
# Let it settle for a microsecond
sleep 0.1
nohup hyprpaper --config "$CONF_FILE" >/dev/null 2>&1 &

# Send notification
notify-send "Wallpaper Selector" "Successfully applied wallpaper: $(basename "$selected_file")"
