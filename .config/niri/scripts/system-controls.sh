#!/usr/bin/env bash
# Fuzzel-based System Controls Menu for Niri WM

# 1. Get current states
# Volume
VOL_MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "\[MUTED\]" || true)
VOL_VAL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
if [ "$VOL_MUTE" = "[MUTED]" ]; then
    VOL_STATUS="🔇 Muted (${VOL_VAL}%)"
else
    VOL_STATUS="🔊 ${VOL_VAL}%"
fi

# Brightness
BR_VAL=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
BR_STATUS="🔆 ${BR_VAL}%"

# Wi-Fi
WIFI_STATE=$(nmcli radio wifi)
if [ "$WIFI_STATE" = "enabled" ]; then
    WIFI_STATUS="📶 Wi-Fi: ON"
else
    WIFI_STATUS="📶 Wi-Fi: OFF"
fi

# Bluetooth
BT_STATE=$(bluetoothctl show | grep "Powered: yes" >/dev/null && echo "ON" || echo "OFF")
BT_STATUS="󰂯 Bluetooth: $BT_STATE"

# Build Fuzzel Menu
MENU="🔊 Volume: $VOL_STATUS\n"
MENU+="🔆 Brightness: $BR_STATUS\n"
MENU+="📶 Toggle Wi-Fi ($WIFI_STATUS)\n"
MENU+="󰂯 Toggle Bluetooth ($BT_STATUS)\n"
MENU+="📸 Screenshot & Cut\n"
MENU+="🔒 Lock Screen\n"
MENU+="🚪 Session Menu (wlogout)"

selected=$(echo -e -n "$MENU" | fuzzel --dmenu --prompt="System Controls >> ")

if [ -z "$selected" ]; then
    exit 0
fi

case "$selected" in
    *Volume*)
        VOL_OPTS="🔇 Toggle Mute\n🔊 100%\n🔊 80%\n🔊 60%\n🔊 40%\n🔊 20%"
        vol_sel=$(echo -e -n "$VOL_OPTS" | fuzzel --dmenu --prompt="Adjust Volume >> ")
        if [ "$vol_sel" = "🔇 Toggle Mute" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        elif [ -n "$vol_sel" ]; then
            vol_num=$(echo "$vol_sel" | grep -o "[0-9]\+")
            wpctl set-volume @DEFAULT_AUDIO_SINK@ $(echo "scale=2; $vol_num / 100" | bc)
        fi
        ;;
    *Brightness*)
        BR_OPTS="🔆 Max (100%)\n🔆 High (80%)\n🔆 Medium (50%)\n🔆 Low (20%)\n🔆 Min (5%)"
        br_sel=$(echo -e -n "$BR_OPTS" | fuzzel --dmenu --prompt="Adjust Brightness >> ")
        if [ -n "$br_sel" ]; then
            br_num=$(echo "$br_sel" | grep -o "[0-9]\+")
            brightnessctl set "${br_num}%"
        fi
        ;;
    *Wi-Fi*)
        if [ "$WIFI_STATE" = "enabled" ]; then
            nmcli radio wifi off
            notify-send "System Controls" "Wi-Fi turned OFF"
        else
            nmcli radio wifi on
            notify-send "System Controls" "Wi-Fi turned ON"
        fi
        ;;
    *Bluetooth*)
        if [ "$BT_STATE" = "ON" ]; then
            bluetoothctl power off
            notify-send "System Controls" "Bluetooth turned OFF"
        else
            bluetoothctl power on
            notify-send "System Controls" "Bluetooth turned ON"
        fi
        ;;
    *Screenshot*)
        niri msg action screenshot
        ;;
    *Lock*)
        hyprlock
        ;;
    *Session*)
        pkill wlogout || wlogout -p layer-shell
        ;;
esac
