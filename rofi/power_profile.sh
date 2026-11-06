#!/usr/bin/env bash

# --- 1. Toggle Logic ---
if pgrep -x "rofi" > /dev/null; then
    pkill rofi
    exit 0
fi

# --- 2. Current Status & System Info ---
CURRENT=$(powerprofilesctl get)

# Fetch live CPU min/max frequencies
if [ -f /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq ]; then
    MIN_KHZ=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq)
    MAX_KHZ=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq)
    MIN_GHZ=$(awk "BEGIN {printf \"%.1f\", $MIN_KHZ / 1000000}")
    MAX_GHZ=$(awk "BEGIN {printf \"%.1f\", $MAX_KHZ / 1000000}")
    FREQ_STR="${MIN_GHZ} - ${MAX_GHZ}GHz"
else
    FREQ_STR="N/A"
fi

# Fetch CPU Temp (Targeting the k10temp kernel module)
TEMP_C="N/A"
for hwmon in /sys/class/hwmon/hwmon*; do
    if [ -f "$hwmon/name" ] && grep -q "k10temp" "$hwmon/name"; then
        if [ -f "$hwmon/temp1_input" ]; then
            TEMP_RAW=$(cat "$hwmon/temp1_input")
            TEMP_C="$((TEMP_RAW / 1000))°C"
            break
        fi
    fi
done

# Fallback if k10temp isn't found
if [ "$TEMP_C" == "N/A" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP_C="$((TEMP_RAW / 1000))°C"
fi

# Combine into one string with a thermometer icon
SYS_INFO="Freq Range: $FREQ_STR    $TEMP_C  "

# --- 3. "Alive" HUD Theme ---
ROFI_OVERRIDE="
    /* 1. Global Reset */
    * {
        font: \"Liquid Crystal 13\";
        background-color: transparent;
        text-color: #cdd6f4;
        margin: 0;
        padding: 0;
        spacing: 0;
    }

    /* 2. Window Container */
    window {
        width: 500px; /* Widened slightly to fit the longer sys info text */
        height: 380px;
        background-image: url(\"/home/polyz/nord_roads2.png\", height);
        border: 2px;
        border-color: rgba(255, 255, 255, 0.08);
        border-radius: 20px;
        anchor: center;
        location: center;
    }

    mainbox {
        orientation: vertical;
        children: [ inputbar, listview ];
        background-color: rgba(30, 30, 46, 0.6);
        padding: 30px;
        spacing: 20px;
    }

    /* 3. Header */
    inputbar {
        children: [ prompt, textbox-freq ];
        orientation: horizontal;
        spacing: 15px;
        margin-bottom: 5px;
    }

    prompt {
        background-image: linear-gradient(to right, #cba6f7, #89b4fa);
        text-color: #1e1e2e;
        padding: 12px;
        border-radius: 12px;
        font: \"Liquid Crystal\";
        horizontal-align: 0.5;
        vertical-align: 0.5;
        expand: false; /* Allows the pill to hug its text, giving the sys info more room */
    }

    /* System Info Display (Text Only) */
    textbox-freq {
        text-color: #cdd6f4;
        padding: 12px;
        font: \"Liquid Crystal\";
        horizontal-align: 0.5;
        vertical-align: 0.5;
        expand: true;
        content: \"$SYS_INFO\";
    }

    /* 4. The List */
    listview {
        layout: vertical;
        lines: 3;
        spacing: 12px;
    }

    /* 5. Explicit State Definitions */
    element {
        orientation: horizontal;
        children: [ element-text ];
        padding: 15px 20px;
        border-radius: 12px;
        border: 1px;
        border-color: transparent;
    }

    element normal.normal, element alternate.normal {
        background-color: rgba(49, 50, 68, 0.7);
        text-color: #cdd6f4;
    }

    element selected.normal {
        background-image: linear-gradient(to right, #313244, #45475a);
        border-color: #cba6f7;
        text-color: #cba6f7;
    }

    element-text {
        vertical-align: 0.5;
        horizontal-align: 0.0;
        text-color: inherit;
    }
"

# --- 4. Content ---
ICO_PERF="󰓅 "
ICO_BAL="󰗑 "
ICO_SAVE="󱩳 "

TXT_PERF="Performance"
TXT_BAL="Balanced"
TXT_SAVE="Power Saver"

OPT_PERF="<span font='16px' weight='bold' color='#f38ba8'>${ICO_PERF}</span>   <span weight='bold'>${TXT_PERF}</span>"
OPT_BAL="<span font='16px' weight='bold' color='#89b4fa'>${ICO_BAL}</span>   <span weight='bold'>${TXT_BAL}</span>"
OPT_SAVE="<span font='16px' weight='bold' color='#a6e3a1'>${ICO_SAVE}</span>   <span weight='bold'>${TXT_SAVE}</span>"

OPTIONS="$OPT_PERF\n$OPT_BAL\n$OPT_SAVE"

# --- 5. Launch ---
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu \
    -markup-rows \
    -p "CURRENT: ${CURRENT^^}" \
    -config /dev/null \
    -theme-str "$ROFI_OVERRIDE")

if [ -z "$CHOICE" ]; then
    exit 0
fi

# --- 6. Apply ---
case "$CHOICE" in
    *"Performance"*)
        powerprofilesctl set performance
        notify-send "System Power" "Switched to Performance Mode "
        ;;
    *"Balanced"*)
        powerprofilesctl set balanced
        notify-send "System Power" "Switched to Balanced Mode "
        ;;
    *"Power Saver"*)
        powerprofilesctl set power-saver
        notify-send "System Power" "Switched to Power Saver "
        ;;
esac
