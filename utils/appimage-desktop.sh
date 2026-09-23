#!/bin/bash

set -Eeuo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────

APP_DIR="${HOME}/Apps"

DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}"
DESKTOP_DIR="${DATA_DIR}/applications"
ICON_DIR="${DATA_DIR}/icons/appimage"

MARKER="X-AppImage-Sync=true"

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

log() {
    printf '[appimage-sync] %s\n' "$*"
}

warn() {
    printf '[appimage-sync] WARNING: %s\n' "$*" >&2
}

die() {
    printf '[appimage-sync] ERROR: %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${TMP_DIR:-}" && -d "${TMP_DIR}" ]]; then
        rm -rf -- "${TMP_DIR}"
    fi
}

trap cleanup EXIT

desktop_value() {
    local file="$1"
    local key="$2"

    awk -v wanted="$key" '
        /^\[Desktop Entry\]$/ {
            in_entry=1
            next
        }

        /^\[/ {
            if (in_entry)
                exit
        }

        in_entry && $0 ~ "^[[:space:]]*" wanted "[[:space:]]*=" {
            sub("^[[:space:]]*" wanted "[[:space:]]*=[[:space:]]*", "")
            print
            exit
        }
    ' "$file"
}

sanitize_filename() {
    local value="$1"

    value="${value// /-}"
    value="$(printf '%s' "$value" | tr -cd '[:alnum:]_.-')"

    [[ -n "$value" ]] || value="app"

    printf '%s' "$value"
}

# Creates a unique ID based on the complete AppImage path.
desktop_id() {
    local appimage="$1"
    local base hash

    base="$(basename "$appimage")"
    base="${base%.[Aa][Pp][Pp][Ii][Mm][Aa][Gg][Ee]}"

    base="$(sanitize_filename "$base")"

    hash="$(printf '%s' "$appimage" | sha256sum | cut -c1-10)"

    printf 'appimage-%s-%s' "$base" "$hash"
}

# ──────────────────────────────────────────────────────────────────────────────
# AppImage extraction
# ──────────────────────────────────────────────────────────────────────────────

extract_appimage() {
    local appimage="$1"
    local destination="$2"

    mkdir -p -- "$destination"

    if command -v unsquashfs >/dev/null 2>&1; then
        local offset="$("$appimage" --appimage-offset)"
        unsquashfs -q -d "$destination" -o "$offset" "$appimage"
        return 0
    fi

    # Fallback if squashfs-tools isn't installed.
    local extraction_dir

    extraction_dir="$(dirname "$destination")/squashfs-root"

    if "$appimage" --appimage-extract >/dev/null 2>&1; then
        [[ -d "$extraction_dir" ]] || return 1

        cp -a "$extraction_dir/." "$destination/"
        rm -rf -- "$extraction_dir"

        return 0
    fi

    return 1
}

# ──────────────────────────────────────────────────────────────────────────────
# Desktop file discovery
# ──────────────────────────────────────────────────────────────────────────────

find_desktop_file() {
    local root="$1"

    find "$root" \
        -type f \
        -name '*.desktop' \
        -print -quit 2>/dev/null || true
}

# ──────────────────────────────────────────────────────────────────────────────
# Icon discovery
# ──────────────────────────────────────────────────────────────────────────────

find_icon() {
    local root="$1"
    local desktop_file="${2:-}"

    # AppImage standard icon.
    if [[ -f "$root/.DirIcon" ]]; then
        printf '%s\n' "$root/.DirIcon"
        return 0
    fi

    # Icon referenced by embedded desktop file.
    if [[ -n "$desktop_file" ]]; then
        local icon
        icon="$(desktop_value "$desktop_file" "Icon" || true)"

        if [[ -n "$icon" ]]; then

            # Absolute path.
            if [[ "$icon" = /* && -f "$root$icon" ]]; then
                printf '%s\n' "$root$icon"
                return 0
            fi

            # Relative path.
            if [[ -f "$root/$icon" ]]; then
                printf '%s\n' "$root/$icon"
                return 0
            fi

            # Icon name.
            local found

            found="$(
                find "$root" \
                    -type f \
                    \( \
                        -name "${icon}.png" \
                        -o -name "${icon}.svg" \
                        -o -name "${icon}.svgz" \
                        -o -name "${icon}.xpm" \
                    \) \
                    -print -quit 2>/dev/null || true
            )"

            if [[ -n "$found" ]]; then
                printf '%s\n' "$found"
                return 0
            fi
        fi
    fi

    # Conventional AppDir icon locations.
    find \
        "$root/usr/share/icons" \
        "$root/usr/share/pixmaps" \
        -type f \
        \( \
            -iname '*.png' \
            -o -iname '*.svg' \
            -o -iname '*.svgz' \
        \) \
        -print -quit 2>/dev/null || true
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate desktop entry
# ──────────────────────────────────────────────────────────────────────────────

generate_desktop() {
    local appimage="$1"
    local id="$2"
    local display_name="$3"
    local embedded_desktop="${4:-}"
    local icon_path="${5:-}"

    local name="$display_name"
    local comment="AppImage application"
    local categories="Utility;"
    local terminal="false"
    local startup_wm_class=""

    if [[ -n "$embedded_desktop" ]]; then
        local value

        value="$(desktop_value "$embedded_desktop" "Name" || true)"
        [[ -n "$value" ]] && name="$value"

        value="$(desktop_value "$embedded_desktop" "Comment" || true)"
        [[ -n "$value" ]] && comment="$value"

        value="$(desktop_value "$embedded_desktop" "Categories" || true)"
        [[ -n "$value" ]] && categories="$value"

        value="$(desktop_value "$embedded_desktop" "Terminal" || true)"
        [[ -n "$value" ]] && terminal="$value"

        startup_wm_class="$(desktop_value \
            "$embedded_desktop" \
            "StartupWMClass" || true)"
    fi

    # If there is a collision, preserve the useful "(parent)" suffix even
    # when the embedded desktop file has its own Name.
    if [[ "$display_name" != "$(basename "$appimage" .AppImage)" ]]; then
        name="$display_name"
    fi

    local desktop_file="${DESKTOP_DIR}/${id}.desktop"

    {
        printf '%s\n' '[Desktop Entry]'
        printf '%s\n' 'Type=Application'
        printf 'Name=%s\n' "$name"
        printf 'Comment=%s\n' "$comment"
        printf 'Exec="%s"\n' "$appimage"

        if [[ -n "$icon_path" ]]; then
            printf 'Icon=%s\n' "$icon_path"
        fi

        printf 'Terminal=%s\n' "$terminal"
        printf 'Categories=%s\n' "$categories"

        if [[ -n "$startup_wm_class" ]]; then
            printf 'StartupWMClass=%s\n' "$startup_wm_class"
        fi

        printf '%s\n' "$MARKER"
        printf 'X-AppImage-Path=%s\n' "$appimage"
    } > "$desktop_file"

    chmod 644 "$desktop_file"

    log "registered: $name"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

[[ -d "$APP_DIR" ]] ||
    die "Application directory does not exist: $APP_DIR"

mkdir -p -- "$DESKTOP_DIR" "$ICON_DIR"

TMP_DIR="$(mktemp -d)"

declare -A CURRENT_IDS=()
declare -A NAME_COUNTS=()
declare -A DISPLAY_NAMES=()

shopt -s nullglob

# ──────────────────────────────────────────────────────────────────────────────
# Collect AppImages
# ──────────────────────────────────────────────────────────────────────────────

appimages=(
    "$APP_DIR"/*.AppImage
    "$APP_DIR"/*.appimage
)

# Count duplicate filenames.
for appimage in "${appimages[@]}"; do
    [[ -f "$appimage" ]] || continue

    filename="$(basename "$appimage")"
    filename="${filename%.[Aa][Pp][Pp][Ii][Mm][Aa][Gg][Ee]}"

    (( NAME_COUNTS["$filename"]++ )) || true
done

# ──────────────────────────────────────────────────────────────────────────────
# Process AppImages
# ──────────────────────────────────────────────────────────────────────────────

for appimage in "${appimages[@]}"; do

    [[ -f "$appimage" ]] || continue

    filename="$(basename "$appimage")"
    filename="${filename%.[Aa][Pp][Pp][Ii][Mm][Aa][Gg][Ee]}"

    id="$(desktop_id "$appimage")"

    CURRENT_IDS["$id"]=1

    # Handle duplicate filenames.
    display_name="$filename"

    if (( NAME_COUNTS["$filename"] > 1 )); then
        parent="$(basename "$(dirname "$appimage")")"
        display_name="${filename} (${parent})"
    fi

    DISPLAY_NAMES["$id"]="$display_name"

    # Make AppImage executable.
    if [[ ! -x "$appimage" ]]; then
        warn "making executable: $appimage"
        chmod +x -- "$appimage"
    fi

    extract_dir="${TMP_DIR}/${id}"

    log "processing: $appimage"

    if ! extract_appimage "$appimage" "$extract_dir"; then
        warn "could not extract AppImage: $appimage"
        continue
    fi

    embedded_desktop="$(find_desktop_file "$extract_dir")"
    icon_path="$(find_icon "$extract_dir" "$embedded_desktop")"

    installed_icon=""

    if [[ -n "$icon_path" && -f "$icon_path" ]]; then
        extension="${icon_path##*.}"

        installed_icon="${ICON_DIR}/${id}.${extension}"

        cp -L -- "$icon_path" "$installed_icon"
        chmod 644 "$installed_icon"
    fi

    generate_desktop \
        "$appimage" \
        "$id" \
        "$display_name" \
        "$embedded_desktop" \
        "$installed_icon"
done

# ──────────────────────────────────────────────────────────────────────────────
# Remove stale generated entries
# ──────────────────────────────────────────────────────────────────────────────

for desktop_file in "$DESKTOP_DIR"/appimage-*.desktop; do
    [[ -f "$desktop_file" ]] || continue

    # Never touch files that weren't generated by us.
    grep -Fxq "$MARKER" "$desktop_file" || continue

    filename="$(basename "$desktop_file" .desktop)"

    if [[ -z "${CURRENT_IDS[$filename]+x}" ]]; then

        log "removing stale entry: $filename"

        rm -f -- "$desktop_file"

        # Remove any icon belonging to this entry.
        rm -f -- \
            "$ICON_DIR/$filename.png" \
            "$ICON_DIR/$filename.svg" \
            "$ICON_DIR/$filename.svgz" \
            "$ICON_DIR/$filename.xpm"
    fi
done

# ──────────────────────────────────────────────────────────────────────────────
# Refresh desktop database
# ──────────────────────────────────────────────────────────────────────────────

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

log "sync complete"

