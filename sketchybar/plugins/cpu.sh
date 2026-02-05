#!/bin/bash

# Get CPU usage percentage
CORE_USAGE=$(top -l 2 | grep -E "^CPU" | tail -1 | awk '{print $3}' | cut -d. -f1)

# Set white text color
text_color="0xffffffff"

# Default background color (transparent)
bg_color="0x00000000"

# Solarized red for high CPU usage
solarized_red="0xffdc322f"

# Change background color to Solarized red if CPU usage is above 90%
if [ "$CORE_USAGE" -gt 90 ]; then
  bg_color="$solarized_red"
fi

# Use CPU icon instead of text label
cpu_icon="󰘚"

# Update sketchybar
sketchybar --set $NAME icon="$cpu_icon" \
                     label="${CORE_USAGE}%" \
                     label.color="$text_color" \
                     background.color="$bg_color"
