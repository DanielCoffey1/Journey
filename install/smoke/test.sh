#!/usr/bin/env bash
# Smoke test — runs inside the install/smoke/Dockerfile container.
# Exercises install.sh end-to-end (minus actual package install), then asserts
# the resulting filesystem state, then runs journey-uninstall and verifies
# cleanup. Exits non-zero on the first failed assertion's batch.
set -uo pipefail

SRC="${SRC:-/home/testuser/journey-src}"
JOURNEY_HOME="${JOURNEY_HOME:-$HOME/.local/share/journey}"
JOURNEY_CONFIG="${JOURNEY_CONFIG:-$HOME/.config/journey}"

c_green=$'\033[32m'; c_red=$'\033[31m'; c_dim=$'\033[2m'; c_bold=$'\033[1m'; c_reset=$'\033[0m'

pass=0; fail=0
section() { printf '\n%s== %s ==%s\n' "$c_bold" "$*" "$c_reset"; }
check() {
    local desc="$1" cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        printf '  %s✓%s %s\n' "$c_green" "$c_reset" "$desc"
        (( pass++ ))
    else
        printf '  %s✗%s %s%s    $ %s%s\n' "$c_red" "$c_reset" "$desc" $'\n' "$c_dim$cmd" "$c_reset"
        (( fail++ ))
    fi
}

# --------------------------------------------------------------------------
section "Phase 1: install.sh (JOURNEY_SKIP_PACKAGES=1)"
# --------------------------------------------------------------------------
if ! ( cd "$SRC" && bash ./install.sh ); then
    printf '%s install.sh exited non-zero — aborting%s\n' "$c_red" "$c_reset"
    exit 1
fi

# Bring the just-installed bin/ onto PATH for the rest of the test.
export PATH="$JOURNEY_HOME/bin:$PATH"
export JOURNEY_PATH="$JOURNEY_HOME"

# --------------------------------------------------------------------------
section "Phase 2: install tree"
# --------------------------------------------------------------------------
check "JOURNEY_HOME exists"                                "[[ -d '$JOURNEY_HOME' ]]"
check "bin/journey present and executable"                 "[[ -x '$JOURNEY_HOME/bin/journey' ]]"
check "default/ directory copied"                          "[[ -d '$JOURNEY_HOME/default' ]]"
check "themes/ directory copied"                           "[[ -d '$JOURNEY_HOME/themes' ]]"
check "hooks/ directory copied"                            "[[ -d '$JOURNEY_HOME/hooks' ]]"
check "version file present"                               "[[ -f '$JOURNEY_HOME/version' ]]"

# --------------------------------------------------------------------------
section "Phase 3: stowed user configs"
# --------------------------------------------------------------------------
for app in walker waybar mako hypr alacritty ghostty foot btop tmux swayosd fastfetch elephant; do
    check "~/.config/$app exists"                          "[[ -e '$HOME/.config/$app' ]]"
done
check "~/.config/starship.toml is a file (not dir)"        "[[ -f '$HOME/.config/starship.toml' ]]"
check "hyprlock.conf landed in hypr/"                      "[[ -f '$HOME/.config/hypr/hyprlock.conf' ]]"
check "hypridle.conf landed in hypr/"                      "[[ -f '$HOME/.config/hypr/hypridle.conf' ]]"

# --------------------------------------------------------------------------
section "Phase 4: theme symlinks"
# --------------------------------------------------------------------------
check "current/theme symlink exists"                       "[[ -L '$JOURNEY_CONFIG/current/theme' ]]"
check "theme.name = tokyo-night"                           "[[ \$(cat '$JOURNEY_CONFIG/current/theme.name') == tokyo-night ]]"
check "current/theme points into themes/tokyo-night"       "[[ \$(readlink '$JOURNEY_CONFIG/current/theme') == '$JOURNEY_HOME/themes/tokyo-night' ]]"
check "btop theme symlink"                                 "[[ -L '$HOME/.config/btop/themes/journey.theme' ]]"

# --------------------------------------------------------------------------
section "Phase 5: PATH plumbing"
# --------------------------------------------------------------------------
check "environment.d snippet written"                      "[[ -f '$HOME/.config/environment.d/10-journey.conf' ]]"
check "snippet exports JOURNEY_HOME's bin"                 "grep -qF '$JOURNEY_HOME/bin' '$HOME/.config/environment.d/10-journey.conf'"
check "snippet exports JOURNEY_PATH"                       "grep -qF 'JOURNEY_PATH=' '$HOME/.config/environment.d/10-journey.conf'"
check "path.sh include in .bashrc"                         "grep -qF 'Journey Companion' '$HOME/.bashrc'"

# --------------------------------------------------------------------------
section "Phase 6: hook layout"
# --------------------------------------------------------------------------
for event in post-boot post-update theme-set battery-low font-set; do
    check "shipped hooks/$event exists"                    "[[ -d '$JOURNEY_HOME/hooks/$event' ]]"
    check "user-side hooks/$event seeded"                  "[[ -d '$JOURNEY_CONFIG/hooks/$event' ]]"
done

# --------------------------------------------------------------------------
section "Phase 7: CLI dispatcher"
# --------------------------------------------------------------------------
# Capture once so failing grep tests can dump the actual content.
journey help >/tmp/help.out 2>&1 || true

check "'journey' exits 0"                                  "journey >/dev/null"
check "'journey help' mentions launch group"               "grep -q '^launch:' /tmp/help.out"
check "'journey help' mentions menu group"                 "grep -q '^menu:' /tmp/help.out"
check "'journey help' mentions theme group"                "grep -q '^theme:' /tmp/help.out"
check "'journey version' prints non-empty"                 "[[ -n \"\$(journey version 2>/dev/null)\" ]]"
check "'journey help launch companion' resolves"           "journey help launch companion 2>&1 | grep -q 'launch companion'"

# Diagnostic: if any of the help-group checks fail, show what we actually got.
if ! grep -q '^launch:' /tmp/help.out 2>/dev/null; then
    printf '\n%s[diagnostic] journey help output (first 60 lines, with line markers):%s\n' "$c_dim" "$c_reset"
    head -60 /tmp/help.out | cat -A | sed 's/^/    /'
fi

# --------------------------------------------------------------------------
section "Phase 8: theme switcher"
# --------------------------------------------------------------------------
journey theme list --names-only >/tmp/themes.out 2>&1 || true
check "theme list shows 19 themes"                         "[[ \$(wc -l </tmp/themes.out) -eq 19 ]]"
check "theme list shows gruvbox"                           "grep -qx gruvbox /tmp/themes.out"

if ! grep -qx gruvbox /tmp/themes.out 2>/dev/null; then
    printf '\n%s[diagnostic] theme list output (with line markers):%s\n' "$c_dim" "$c_reset"
    cat -A /tmp/themes.out | sed 's/^/    /'
fi
check "theme current is tokyo-night"                       "[[ \$(journey theme current) == tokyo-night ]]"
check "theme set gruvbox succeeds (graceful)"              "journey theme set gruvbox"
check "theme current is gruvbox after switch"              "[[ \$(journey theme current) == gruvbox ]]"
check "current/theme now points to gruvbox"                "[[ \$(readlink '$JOURNEY_CONFIG/current/theme') == '$JOURNEY_HOME/themes/gruvbox' ]]"

# --------------------------------------------------------------------------
section "Phase 9: hook runner"
# --------------------------------------------------------------------------
check "post-boot hook chain runs cleanly"                  "journey-hook post-boot"
check "theme-set hook chain runs cleanly"                  "journey-hook theme-set"

# --------------------------------------------------------------------------
section "Phase 10: package + update help flows"
# --------------------------------------------------------------------------
check "'journey pkg add --help' returns 0"                 "journey pkg add --help"
check "'journey pkg remove --help' returns 0"              "journey pkg remove --help"
check "'journey-migrate --list' returns 0"                 "journey-migrate --list"
check "'journey-update --check --no-pull --no-packages --no-aur --no-system' returns 0" \
    "journey-update --check --no-pull --no-packages --no-aur --no-system"

# --------------------------------------------------------------------------
section "Phase 11: uninstall"
# --------------------------------------------------------------------------
if ! journey-uninstall --yes --purge; then
    printf '%s journey-uninstall failed%s\n' "$c_red" "$c_reset"
    (( fail++ ))
fi
check "JOURNEY_HOME removed"                               "[[ ! -d '$JOURNEY_HOME' ]]"
check "JOURNEY_CONFIG removed"                             "[[ ! -d '$JOURNEY_CONFIG' ]]"
check "environment.d snippet removed"                      "[[ ! -f '$HOME/.config/environment.d/10-journey.conf' ]]"
check "stowed walker config removed"                       "[[ ! -d '$HOME/.config/walker' ]]"
check ".bashrc has no Journey lines"                       "! grep -qF 'Journey Companion' '$HOME/.bashrc'"

# --------------------------------------------------------------------------
section "Phase 12: curl-pipe install path (file:// git remote)"
# --------------------------------------------------------------------------
# Simulates the `curl -fsSL .../install.sh | bash` flow:
#   - install.sh runs from /tmp (no project checkout in its dirname)
#   - JOURNEY_REPO is overridden to point at a file:// git remote
#     (built from the project source so the test is hermetic)
#   - install.sh's ensure_repo falls through to `git clone $JOURNEY_REPO`
cp_home="/tmp/cp-home"
git_remote="/tmp/journey-remote"
standalone_installer="/tmp/install-standalone.sh"
rm -rf "$cp_home" "$git_remote" "$standalone_installer"
mkdir -p "$cp_home"

# Build a fresh local git repo with the current source on `master`.
cp -a "$SRC" "$git_remote"
(
    cd "$git_remote" && rm -rf .git
    git init -q -b master 2>/dev/null || { git init -q && git symbolic-ref HEAD refs/heads/master; }
    git add -A
    git -c user.email=t@t -c user.name=t commit -qm "snapshot"
) || { printf '%s✗%s could not build local git remote\n' "$c_red" "$c_reset"; (( fail++ )); }

# Copy install.sh somewhere with no `version` / `bin/` siblings, so the
# developer-flow short-circuit in ensure_repo skips and we hit `git clone`.
cp "$SRC/install.sh" "$standalone_installer"

# Run the simulated curl-pipe.
if HOME="$cp_home" \
   JOURNEY_HOME="$cp_home/.local/share/journey" \
   JOURNEY_CONFIG="$cp_home/.config/journey" \
   JOURNEY_REPO="file://$git_remote" \
   JOURNEY_BRANCH=master \
   JOURNEY_SKIP_PACKAGES=1 \
   bash "$standalone_installer" >/tmp/cp-install.log 2>&1; then
    printf '  %s✓%s curl-pipe install completed\n' "$c_green" "$c_reset"; (( pass++ ))
else
    printf '  %s✗%s curl-pipe install FAILED — last 30 log lines:\n' "$c_red" "$c_reset"; (( fail++ ))
    tail -30 /tmp/cp-install.log | sed 's/^/    /'
fi

check "cloned tree has bin/journey (curl-pipe)"            "[[ -x '$cp_home/.local/share/journey/bin/journey' ]]"
check "cloned tree has version file (curl-pipe)"           "[[ -f '$cp_home/.local/share/journey/version' ]]"
check "default theme symlinked (curl-pipe)"                "[[ -L '$cp_home/.config/journey/current/theme' ]]"
check "tokyo-night theme present (curl-pipe)"              "[[ -d '$cp_home/.local/share/journey/themes/tokyo-night' ]]"
check "environment.d snippet written (curl-pipe)"          "[[ -f '$cp_home/.config/environment.d/10-journey.conf' ]]"
check "JOURNEY_HOME in env.d snippet points at curl-pipe home" \
    "grep -qF '$cp_home/.local/share/journey/bin' '$cp_home/.config/environment.d/10-journey.conf'"

# --------------------------------------------------------------------------
printf '\n%s%d passed, %d failed%s\n' "$c_bold" "$pass" "$fail" "$c_reset"
exit "$(( fail > 0 ? 1 : 0 ))"
