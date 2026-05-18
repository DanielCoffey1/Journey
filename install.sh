#!/usr/bin/env bash
# Journey Companion bootstrap installer.
# Usage:  curl -fsSL https://get.journey.dev | bash
#         (or)   git clone … && cd journey && ./install.sh
set -euo pipefail

JOURNEY_REPO="${JOURNEY_REPO:-https://github.com/djcoffey/journey.git}"
JOURNEY_BRANCH="${JOURNEY_BRANCH:-main}"
JOURNEY_HOME="${JOURNEY_HOME:-$HOME/.local/share/journey}"
JOURNEY_CONFIG="${JOURNEY_CONFIG:-$HOME/.config/journey}"

c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_reset=$'\033[0m'
log()  { printf '%s==>%s %s\n' "$c_blue"   "$c_reset" "$*"; }
ok()   { printf '%s ✓%s %s\n'  "$c_green"  "$c_reset" "$*"; }
warn() { printf '%s !!%s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
die()  { printf '%s xx%s %s\n' "$c_red"    "$c_reset" "$*" >&2; exit 1; }

require_arch() {
    [[ -f /etc/arch-release ]] || die "Journey Companion targets Arch Linux only."
}

require_not_root() {
    [[ $EUID -ne 0 ]] || die "Run install.sh as your normal user, not root. sudo will be invoked when needed."
}

ensure_sudo() {
    command -v sudo >/dev/null || die "sudo is required."
    log "Cached sudo credentials (you may be prompted for your password)"
    sudo -v
    # keep-alive
    ( while true; do sleep 60; sudo -n true 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "${SUDO_KEEPALIVE_PID:-}" 2>/dev/null || true' EXIT
}

ensure_git() {
    if ! command -v git >/dev/null; then
        log "Installing git"
        sudo pacman -S --needed --noconfirm git
    fi
}

ensure_repo() {
    if [[ -d $JOURNEY_HOME/.git ]]; then
        log "Updating Journey at $JOURNEY_HOME"
        git -C "$JOURNEY_HOME" fetch --quiet origin "$JOURNEY_BRANCH"
        git -C "$JOURNEY_HOME" reset --hard "origin/$JOURNEY_BRANCH"
    elif [[ -d $(dirname "$0") && -f $(dirname "$0")/version && -d $(dirname "$0")/bin ]]; then
        # Running install.sh from an already-checked-out tree (developer flow).
        local src; src="$(cd "$(dirname "$0")" && pwd)"
        if [[ $src != "$JOURNEY_HOME" ]]; then
            log "Copying local checkout from $src → $JOURNEY_HOME"
            mkdir -p "$(dirname "$JOURNEY_HOME")"
            rm -rf "$JOURNEY_HOME"
            cp -a "$src" "$JOURNEY_HOME"
        fi
    else
        log "Cloning Journey to $JOURNEY_HOME"
        mkdir -p "$(dirname "$JOURNEY_HOME")"
        git clone --branch "$JOURNEY_BRANCH" --depth 1 "$JOURNEY_REPO" "$JOURNEY_HOME"
    fi
    ok "Journey source at $JOURNEY_HOME ($(cat "$JOURNEY_HOME/version" 2>/dev/null || echo unknown))"
}

ensure_yay() {
    if command -v yay >/dev/null; then return; fi
    log "Installing yay (AUR helper)"
    sudo pacman -S --needed --noconfirm base-devel git
    local build; build="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$build/yay-bin"
    ( cd "$build/yay-bin" && makepkg -si --noconfirm )
    rm -rf "$build"
}

# Read a package list file, stripping comments and blank lines.
# Hardware-tag filtering ([nvidia] etc.) is applied only for system.packages.
read_packages() {
    local file="$1" filter_tags="${2:-}"
    [[ -f $file ]] || { warn "Missing $file"; return; }
    awk -v filter="$filter_tags" '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }
        {
            # Strip inline comments
            line=$0
            sub(/[[:space:]]+#.*$/, "", line)
            # Extract optional [tag] at end
            tag=""
            if (match(line, /\[[a-zA-Z0-9_-]+\][[:space:]]*$/)) {
                tag=substr(line, RSTART+1, RLENGTH-2)
                gsub(/[[:space:]]+/, "", tag)
                line=substr(line, 1, RSTART-1)
            }
            gsub(/[[:space:]]+$/, "", line)
            gsub(/^[[:space:]]+/, "", line)
            if (line == "") next
            if (tag == "") { print line; next }
            # Tag present: only emit if filter contains tag
            if (filter == "") next
            n = split(filter, parts, " ")
            for (i=1; i<=n; i++) if (parts[i] == tag) { print line; next }
        }
    ' "$file"
}

# Crude hardware probe → space-separated tag list.
detect_hardware_tags() {
    local tags=()
    if command -v lspci >/dev/null; then
        local pci; pci="$(lspci 2>/dev/null || true)"
        grep -qi 'nvidia' <<<"$pci" && tags+=(nvidia)
        grep -qiE 'vga.*intel|3d.*intel' <<<"$pci" && tags+=(intel)
        grep -qiE 'vga.*amd|vga.*ati|3d.*amd' <<<"$pci" && tags+=(amd)
        grep -qi 'broadcom' <<<"$pci" && tags+=(broadcom)
    fi
    local vendor product
    vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
    product="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"
    case "$vendor $product" in
        *Apple*)          tags+=(t2) ;;
        *Microsoft*Surface*) tags+=(surface) ;;
        *Dell*XPS*)       tags+=(dell-xps) ;;
        *ASUS*)           tags+=(asus) ;;
        *Framework*16*)   tags+=(framework16) ;;
    esac
    printf '%s\n' "${tags[*]}"
}

install_packages() {
    local tags; tags="$(detect_hardware_tags)"
    [[ -n $tags ]] && log "Detected hardware tags: $tags" || log "No special hardware tags detected"

    log "Installing system / driver packages (pacman)"
    mapfile -t sys < <(read_packages "$JOURNEY_HOME/packages/system.packages" "$tags")
    [[ ${#sys[@]} -gt 0 ]] && sudo pacman -S --needed --noconfirm "${sys[@]}"

    log "Installing base packages (pacman)"
    mapfile -t base < <(read_packages "$JOURNEY_HOME/packages/base.packages")
    [[ ${#base[@]} -gt 0 ]] && sudo pacman -S --needed --noconfirm "${base[@]}"

    log "Installing AUR packages (yay)"
    # Same hardware-tag filtering as the pacman lists, so [t2]/[framework16]/etc.
    # AUR entries only fire on matching hardware.
    mapfile -t aur < <(read_packages "$JOURNEY_HOME/packages/aur.packages" "$tags")
    [[ ${#aur[@]} -gt 0 ]] && yay -S --needed --noconfirm "${aur[@]}"
}

stow_configs() {
    log "Stowing default configs into ~/.config/"
    mkdir -p "$HOME/.config" "$JOURNEY_CONFIG/current" "$JOURNEY_CONFIG/themes" "$JOURNEY_CONFIG/branding"

    # Seed user-side hook directories so users have a discoverable place to
    # drop their own scripts. Shipped defaults live at $JOURNEY_HOME/hooks/.
    mkdir -p "$JOURNEY_CONFIG/hooks"
    local event
    for event in post-boot post-update theme-set battery-low font-set; do
        mkdir -p "$JOURNEY_CONFIG/hooks/$event"
    done
    if [[ ! -f $JOURNEY_CONFIG/hooks/README.md ]]; then
        cat >"$JOURNEY_CONFIG/hooks/README.md" <<'EOF'
# Your hooks

Drop executable scripts into the event subdirectories here. They run after the
shipped hooks at `~/.local/share/journey/hooks/<event>/`. See that directory's
README for the full contract.
EOF
    fi

    # Both directories and bare files under default/ get installed as
    # ~/.config/<name>. Existing user content is moved aside (not overwritten),
    # so reinstalls remain reversible. If the destination is already byte-for-byte
    # identical to the source (e.g. the user just ran install.sh twice in a
    # row), we skip both the backup and the copy — keeps re-installs idempotent
    # and avoids accumulating *.pre-journey.* directories.
    local entry name dst backup
    for entry in "$JOURNEY_HOME"/default/*; do
        [[ -e $entry ]] || continue
        name="$(basename "$entry")"
        dst="$HOME/.config/$name"

        if [[ -e $dst ]] && diff -rq "$entry" "$dst" >/dev/null 2>&1; then
            continue
        fi

        if [[ -e $dst && ! -L $dst ]]; then
            backup="${dst}.pre-journey.$(date +%s)"
            warn "Backing up existing $dst → $backup"
            mv "$dst" "$backup"
        fi
        rm -rf "$dst"
        cp -a "$entry" "$dst"
    done
}

link_path() {
    # Make $JOURNEY_HOME/bin discoverable from three places:
    #   1. Interactive shells (.bashrc / .zshrc, via path.sh)
    #   2. systemd user units & uwsm-app launches (environment.d)
    #   3. hyprland's exec environment (inherits from systemd user env)
    local snippet="$JOURNEY_CONFIG/path.sh"
    mkdir -p "$JOURNEY_CONFIG"
    cat >"$snippet" <<EOF
# Added by Journey Companion installer
case ":\$PATH:" in
    *":$JOURNEY_HOME/bin:"*) ;;
    *) PATH="$JOURNEY_HOME/bin:\$PATH" ;;
esac
export PATH
EOF
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        [[ -f $rc ]] || continue
        grep -qF "$snippet" "$rc" 2>/dev/null && continue
        printf '\n# Journey Companion\n[ -f %q ] && . %q\n' "$snippet" "$snippet" >>"$rc"
    done

    # systemd user env — picked up by uwsm-app, hyprland exec-once, etc.
    # JOURNEY_PATH is exported here so that config files (waybar etc.) can
    # reference shipped scripts as `$JOURNEY_PATH/default/...`.
    mkdir -p "$HOME/.config/environment.d"
    cat >"$HOME/.config/environment.d/10-journey.conf" <<EOF
# Added by Journey Companion installer.
# Re-running install.sh overwrites this file.
PATH=$JOURNEY_HOME/bin:\${PATH}
JOURNEY_PATH=$JOURNEY_HOME
EOF
}

apply_default_theme() {
    log "Setting default theme to tokyo-night"
    if [[ -x $JOURNEY_HOME/bin/journey-theme-set ]]; then
        PATH="$JOURNEY_HOME/bin:$PATH" "$JOURNEY_HOME/bin/journey-theme-set" tokyo-night || warn "journey-theme-set failed"
    else
        ln -sfn "$JOURNEY_HOME/themes/tokyo-night" "$JOURNEY_CONFIG/current/theme"
        echo tokyo-night >"$JOURNEY_CONFIG/current/theme.name"
    fi

    # btop reads themes only from $XDG_CONFIG_HOME/btop/themes/. Symlink the
    # active theme's btop.theme there so theme-set "just works" for btop too.
    mkdir -p "$HOME/.config/btop/themes"
    ln -sfn "$JOURNEY_CONFIG/current/theme/btop.theme" "$HOME/.config/btop/themes/journey.theme"
}

enable_services() {
    log "Enabling system services"
    for svc in NetworkManager.service bluetooth.service docker.service cups.service sddm.service; do
        if systemctl list-unit-files "$svc" >/dev/null 2>&1; then
            sudo systemctl enable "$svc" || true
        fi
    done
}

run_post_install() {
    if [[ -x $JOURNEY_HOME/bin/journey-first-run ]]; then
        "$JOURNEY_HOME/bin/journey-first-run" || true
    fi
}

main() {
    require_arch
    require_not_root
    ensure_sudo
    ensure_git
    ensure_repo
    # JOURNEY_SKIP_PACKAGES=1 short-circuits anything that touches pacman/yay
    # or systemd. Used by install/smoke/test.sh and by users who want to
    # manage packages themselves.
    if [[ -z ${JOURNEY_SKIP_PACKAGES:-} ]]; then
        ensure_yay
        install_packages
    fi
    stow_configs
    link_path
    apply_default_theme
    [[ -z ${JOURNEY_SKIP_PACKAGES:-} ]] && enable_services
    run_post_install

    ok "Journey Companion installed."
    cat <<'EOF'

  Next steps:
    1. Log out and log back in (or reboot) to start a fresh Hyprland session.
    2. Once in Hyprland: SUPER+SPACE → Journey Companion (the launcher).
    3. Run `journey help` to explore the CLI.
EOF
}

main "$@"
