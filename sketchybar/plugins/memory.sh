#!/bin/bash

# Get memory usage information using vm_stat
vm_stat_output=$(vm_stat)

# Extract page size
page_size=$(vm_stat | head -1 | grep -o '[0-9]\+')

# Extract the necessary memory statistics
pages_free=$(echo "$vm_stat_output" | grep "Pages free:" | awk '{print $3}' | tr -d '.')
pages_active=$(echo "$vm_stat_output" | grep "Pages active:" | awk '{print $3}' | tr -d '.')
pages_inactive=$(echo "$vm_stat_output" | grep "Pages inactive:" | awk '{print $3}' | tr -d '.')
pages_speculative=$(echo "$vm_stat_output" | grep "Pages speculative:" | awk '{print $3}' | tr -d '.')
pages_wired=$(echo "$vm_stat_output" | grep "Pages wired down:" | awk '{print $4}' | tr -d '.')
pages_compressed=$(echo "$vm_stat_output" | grep "Pages occupied by compressor:" | awk '{print $5}' | tr -d '.')
pages_purgeable=$(echo "$vm_stat_output" | grep "Pages purgeable:" | awk '{print $3}' | tr -d '.')
pages_file_backed=$(echo "$vm_stat_output" | grep "File-backed pages:" | awk '{print $3}' | tr -d '.')

# Calculate app memory (excluding cache)
# App memory = active + wired - purgeable
app_memory=$((pages_active + pages_wired - pages_purgeable))

# Calculate total memory
total_memory=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired + pages_compressed))

# Calculate percentage of app memory (excluding cache)
used_percentage=$((app_memory * 100 / total_memory))

# Solarized color scheme
# base03    #002b36  0x002b36ff
# base02    #073642  0x073642ff
# base01    #586e75  0x586e75ff
# base00    #657b83  0x657b83ff
# base0     #839496  0x839496ff
# base1     #93a1a1  0x93a1a1ff
# base2     #eee8d5  0xeee8d5ff
# base3     #fdf6e3  0xfdf6e3ff
# yellow    #b58900  0xb58900ff
# orange    #cb4b16  0xcb4b16ff
# red       #dc322f  0xdc322fff
# magenta   #d33682  0xd33682ff
# violet    #6c71c4  0x6c71c4ff
# blue      #268bd2  0x268bd2ff
# cyan      #2aa198  0x2aa198ff
# green     #859900  0x859900ff

# Set white text color
text_color="0xffffffff"

# Default background color (transparent)
bg_color="0x00000000"

# Change background color to Solarized red if memory usage is above 80%
if [ "$used_percentage" -gt 80 ]; then
  bg_color="0xdc322fff"
fi

# For testing without sketchybar
if [[ -z "$NAME" ]]; then
  echo "Memory: ${used_percentage}%"
else
  # Output for sketchybar
  sketchybar --set $NAME icon="󰍛" \
                         label="${used_percentage}%" \
                         label.color="$text_color" \
                         background.color="$bg_color"
fi
