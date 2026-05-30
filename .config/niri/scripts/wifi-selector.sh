#!/usr/bin/env bash
# Fuzzel-based Wi-Fi Selector for Niri WM

# Get list of Wi-Fi networks
wifi_list=$(nmcli --fields SSID,SECURITY,ACTIVE device wifi list | tail -n +2)

if [ -z "$wifi_list" ]; then
    notify-send "Wi-Fi Selector" "No networks found!"
    exit 1
fi

# Prettify list for Fuzzel
menu_list=""
declare -A security_map
declare -A ssid_map

while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue
    
    # Extract fields
    active=$(echo "$line" | awk '{print $NF}')
    if [ "$active" = "yes" ]; then
        ssid=$(echo "$line" | sed 's/  \+/ /g' | cut -d' ' -f1-$(( $(echo "$line" | awk '{print NF}') - 3 )))
        security=$(echo "$line" | sed 's/  \+/ /g' | awk '{print $(NF-2)}')
        display="🟢 $ssid (Connected)"
    else
        ssid=$(echo "$line" | sed 's/  \+/ /g' | cut -d' ' -f1-$(( $(echo "$line" | awk '{print NF}') - 2 )))
        security=$(echo "$line" | sed 's/  \+/ /g' | awk '{print $(NF-1)}')
        display="📶 $ssid ($security)"
    fi
    
    security_map["$display"]="$security"
    ssid_map["$display"]="$ssid"
    menu_list+="$display\n"
done <<< "$wifi_list"

# Show Fuzzel menu
selected=$(echo -e -n "$menu_list" | sort -u | fuzzel --dmenu --prompt="Select Wi-Fi >> ")

if [ -z "$selected" ]; then
    exit 0
fi

chosen_ssid="${ssid_map[$selected]}"
chosen_security="${security_map[$selected]}"

if [[ "$selected" == *"🟢"* ]]; then
    # Offer to disconnect
    act=$(echo -e "🚪 Disconnect\n❌ Cancel" | fuzzel --dmenu --prompt="Manage $chosen_ssid >> ")
    if [ "$act" = "🚪 Disconnect" ]; then
        nmcli device disconnect wlan0 || nmcli device disconnect $(nmcli device | grep wifi | awk '{print $1}' | head -n 1)
        notify-send "Wi-Fi Selector" "Disconnected from $chosen_ssid"
    fi
    exit 0
fi

# Check if network is open or secure
if [[ "$chosen_security" == "--" ]]; then
    notify-send "Wi-Fi Selector" "Connecting to open network: $chosen_ssid..."
    if nmcli device wifi connect "$chosen_ssid"; then
        notify-send "Wi-Fi Selector" "Connected successfully to $chosen_ssid!"
    else
        notify-send -u critical "Wi-Fi Selector" "Failed to connect to $chosen_ssid"
    fi
else
    # Ask for password
    password=$(fuzzel --dmenu --password --prompt="Enter Password for $chosen_ssid >> ")
    if [ -n "$password" ]; then
        notify-send "Wi-Fi Selector" "Connecting to $chosen_ssid..."
        if nmcli device wifi connect "$chosen_ssid" password "$password"; then
            notify-send "Wi-Fi Selector" "Connected successfully to $chosen_ssid!"
        else
            notify-send -u critical "Wi-Fi Selector" "Failed to connect to $chosen_ssid"
        fi
    fi
fi
