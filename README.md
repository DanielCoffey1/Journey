# Journey Companion

A from-scratch desktop bootstrap for **vanilla Arch Linux + Hyprland**. One curl-pipe and the box looks, feels, and behaves like a fully configured Omarchy-style desktop — but every line of it is Journey's own.

```
curl -fsSL https://get.journey.dev | bash
```

The launcher bound to `SUPER+SPACE` is **Journey Companion** (a Journey-branded walker config). The CLI is `journey`. The on-disk install lives at `~/.local/share/journey/`, user state at `~/.config/journey/`.

---

## Project Roadmap (Resume Checklist)

This README **is** the project todo list. Check items off as they ship. When you come back after a break, the lowest unchecked item is where to pick up.

### Phase 0 — Foundation

- [x] Project skeleton (`bin/`, `default/`, `themes/`, `packages/`, `hooks/`, `install/`)
- [x] README as living roadmap (this file)
- [x] `version` file
- [x] `install.sh` bootstrap (curl-pipe entry point)
- [x] Package lists: `packages/base.packages`, `packages/system.packages`, `packages/aur.packages`
- [x] `bin/journey` — subcommand dispatcher CLI (metadata-driven help)

### Phase 1 — Launcher (Journey Companion)

- [x] `default/walker/config.toml` — 1:1 with current walker config, Journey-branded
- [x] `default/walker/themes/journey-default/layout.xml`
- [x] `default/walker/themes/journey-default/style.css`
- [x] `bin/journey-launch-companion` — bound to SUPER+SPACE
- [x] `bin/journey-restart-companion`, `bin/journey-refresh-companion`
- [x] `default/elephant/{desktopapplications,calc,symbols}.toml` — walker data backend
- [ ] App menu wired up (already comes free via `desktopapplications` provider — verify on a fresh box)

### Phase 2 — Hyprland with 1:1 Keybinds

- [x] `default/hypr/hyprland.conf` — user-side entry that sources defaults + user overrides
- [x] `default/hypr/bindings.conf` — app launcher keybinds (terminal, browser, file manager, webapps, etc.)
- [x] `default/hypr/bindings/utilities.conf` — menus, captures, toggles, notifications, etc.
- [x] `default/hypr/bindings/tiling.conf` — workspaces, focus, resize, groups
- [x] `default/hypr/bindings/media.conf` — volume, brightness, media keys
- [x] `default/hypr/bindings/clipboard.conf` — universal copy/paste/cut
- [x] `default/hypr/{input,looknfeel,envs,windows,autostart}.conf`
- [ ] `default/hypr/apps/*.conf` — per-app window rules (1password, browser, jetbrains, steam, terminals, walker, etc.)

### Phase 3 — Theming

- [x] `themes/tokyo-night/` — current daily-driver theme, pre-generated per-app files
- [x] `bin/journey-theme-list` — shipped + user themes, `*` marks active
- [x] `bin/journey-theme-set` — atomic symlink swap + live service reload
- [x] `bin/journey-theme-current`
- [x] `bin/journey-theme-install` — accepts local dir, archive (.tar.gz/.xz/.bz2/.zip), HTTP/HTTPS, or git URL; supports `--name` and `--activate`
- [x] Symlink-into-`~/.config/journey/current/theme/` mechanism on theme-set
- [x] Live reload on theme-set (hyprctl reload, makoctl reload, waybar SIGUSR2, swaybg respawn, walker restart, swayosd kill, gsettings icon-theme, asusctl RGB)
- [ ] Port remaining 18 themes from Omarchy (catppuccin, gruvbox, nord, rose-pine, kanagawa, ethereal, etc.)
- [ ] Color-token templating so themes generate per-app files at install instead of being pre-baked

### Phase 4 — Menus

- [x] `bin/journey-pick` — shared picker (walker --dmenu / gum / fzf fallback chain)
- [x] `bin/journey-menu` — root menu + subcommand dispatcher (`journey-menu system` → exec `journey-menu-system`)
- [x] `bin/journey-menu-system` — power menu (lock / suspend / hibernate / relaunch hypr / reboot / shutdown / log out). Same as Omarchy's `omarchy menu system`.
- [x] `bin/journey-menu-capture` — region / window / full-screen screenshot (with satty annotation), color picker, OCR, screen record
- [x] `bin/journey-menu-keybindings` — searchable list parsed from Hyprland configs (192 binds today)
- [x] `bin/journey-menu-theme` — picks from `journey-theme-list`, hands off to `journey-theme-set`
- [x] `bin/journey-menu-background` — picks from active theme's `backgrounds/`, swaps symlink, restarts swaybg
- [x] `bin/journey-menu-toggle` — flips marker files; uses `journey-toggle-<name>` script when present
- [x] `bin/journey-menu-hardware` — WiFi / Bluetooth / Audio / Display sub-menu (terminal TUI fallbacks: impala, bluetui, wiremix)
- [x] `bin/journey-menu-share` — focuses LocalSend if running, else launches it
- [x] `bin/journey-menu-reminder-set` — prompts via walker dmenu / gum input, hands off to `journey-reminder add`
- [x] `bin/journey-menu-screenrecord` — single-binding start/stop (gpu-screen-recorder)

### Phase 5 — Hooks

- [x] `bin/journey-hook` runner — `journey-hook <event>` runs all scripts under `~/.config/journey/hooks/<event>/` (and `~/.local/share/journey/hooks/<event>/`)
- [ ] Default hook scripts shipped under `hooks/`: `post-boot`, `post-update`, `theme-set`, `battery-low`, `font-set`
- [ ] `~/.config/journey/hooks/` layout + example/no-op scripts

### Phase 6 — Launchers & Helpers

- [x] `bin/journey-launch-browser` — chromium preferred (`--incognito` for `--private`), firefox / xdg-open fallback chain, honors `$BROWSER`
- [x] `bin/journey-launch-editor` — honors `$EDITOR`, falls back nvim → hx → vim → vi; runs in `journey-launch-terminal`
- [x] `bin/journey-launch-terminal` — opens xdg-terminal-exec in the focused window's cwd
- [x] `bin/journey-launch-webapp` — Chromium `--app=URL`; un-escapes `##` → `#` from hypr binds; `--class` flag
- [x] `bin/journey-launch-or-focus` — focus by class regex (hyprctl + jq), bare-command fallback
- [x] `bin/journey-launch-or-focus-webapp` — uses absolute path to `journey-launch-webapp` (PATH-independent)
- [x] `bin/journey-launch-or-focus-tui` — match by window title
- [x] `bin/journey-launch-tui` — wraps `journey-launch-terminal`
- [x] `bin/journey-launch-audio` (wiremix → pulsemixer → alsamixer)
- [x] `bin/journey-launch-bluetooth` (bluetui → bluetuith → bluetoothctl)
- [x] `bin/journey-launch-wifi` (impala → nmtui)
- [x] `bin/journey-cmd-terminal-cwd` — falls back to `$HOME` when hyprctl/jq missing
- [x] `install.sh` writes `~/.config/environment.d/10-journey.conf` so systemd user / uwsm-app / hyprland exec see `JOURNEY_HOME/bin` on `$PATH`

### Phase 7 — System Integration

- [x] `bin/journey-first-run` — idempotent no-op stub; will become onboarding wizard
- [x] `bin/journey-toggle-enabled` — looks for marker files under `~/.local/state/journey/toggles/`
- [x] `bin/journey-toggle-waybar` — marker-driven; autostart.conf respects it
- [x] `bin/journey-toggle-idle` — start/stop hypridle
- [x] `bin/journey-toggle-nightlight` — hyprsunset at 3500K
- [x] `bin/journey-toggle-notification-silencing` — mako do-not-disturb mode
- [x] `bin/journey-toggle-touchpad` — hyprctl device toggle (on/off/toggle)
- [x] `bin/journey-brightness-display` — brightnessctl + synced notification OSD
- [x] `bin/journey-brightness-keyboard` — asusctl preferred, brightnessctl fallback (up/down/cycle)
- [x] `bin/journey-swayosd-client` — auto-starts server on first call, proxies args
- [x] `bin/journey-audio-input-mute` — prefers swayosd, wpctl / pamixer fallback
- [x] `bin/journey-audio-output-switch` — cycles sinks with friendly-name notification
- [x] `bin/journey-capture-screenshot` — region picker → satty annotation → clipboard + file
- [x] `bin/journey-capture-text-extraction` — region picker → tesseract → wl-copy
- [x] `bin/journey-system-lock` — hyprlock with loginctl fallback, no stacking
- [x] `bin/journey-battery-status` — multi-battery, with acpi remaining-time when available
- [x] `bin/journey-weather-status` — wttr.in, honors `$WEATHER_LOCATION`
- [x] `bin/journey-reminder` — add / show / list / clear, stored in `~/.local/state/journey/reminders.txt`
- [x] `bin/journey-powerprofiles-init` — sets balanced (or first available)
- [x] `bin/journey-hyprland-window-pop` — float + pin in one batch
- [x] `bin/journey-hyprland-window-transparency-toggle` — writes hypr snippet, reloads
- [x] `bin/journey-hyprland-window-gaps-toggle` — same pattern (gaps + borders → 0)
- [x] `bin/journey-hyprland-window-single-square-aspect-toggle` — 1:1 single-window aspect on ultrawides
- [x] `bin/journey-hyprland-window-close-all` — close every window on the current workspace
- [x] `bin/journey-hyprland-workspace-layout-toggle` — dwindle → master → scrolling
- [x] `bin/journey-hyprland-monitor-scaling-cycle` — cycle 1.0 → 1.25 → 1.5 → 1.666 → 1.75 → 2.0
- [x] `bin/journey-hyprland-monitor-internal` — on / off / toggle eDP/LVDS/DSI
- [x] `bin/journey-hyprland-monitor-internal-mirror` — mirror internal to first external monitor
- [x] `bin/journey-hyprland-monitor-watch` — listens on `.socket2.sock` for monitor add/remove, reloads hypr
- [x] `bin/journey-hw-external-monitors` — exit-code predicate used by lid-switch keybind
- [x] `bin/journey-transcode` — stub (will get a full ffmpeg menu in Phase 8)

### Phase 8 — Application Configs

- [x] `default/waybar/config.jsonc` + `style.css` — workspaces, clock, weather, indicators, cpu/battery/network/bluetooth/pulseaudio modules; clicks route to `journey-*`
- [x] `default/waybar/indicators/{idle,notification-silencing,screen-recording}.sh` — JSON-emitting waybar custom-module scripts
- [x] `default/waybar/weather.sh` — wttr.in JSON wrapper (waybar custom/weather)
- [x] `default/mako/core.ini` + `config` — theme imports `core.ini` plus its colors
- [x] `default/swayosd/config.toml` + `style.css`
- [x] `default/alacritty/alacritty.toml` — JetBrains Mono Nerd, journey theme import
- [x] `default/ghostty/config` — same conventions; `?`-prefixed theme include tolerates first-boot
- [x] `default/foot/foot.ini`
- [x] `default/btop/btop.conf` — uses `color_theme = "journey"`; install.sh symlinks `~/.config/btop/themes/journey.theme` → active theme's `btop.theme`
- [x] `default/hypr/hyprlock.conf` — theme colors + background from `current/theme/`, `current/background`
- [x] `default/hypr/hypridle.conf` — lock @5min, DPMS @10min, no auto-suspend by default
- [x] `default/fastfetch/config.jsonc` — hardware/software boxes (no omarchy logo)
- [x] `default/starship.toml`
- [x] `default/tmux/tmux.conf`
- [x] `install.sh` `stow_configs` handles bare files at the top level of `default/` (so `default/starship.toml` lands at `~/.config/starship.toml`)
- [x] `install.sh` exports `JOURNEY_PATH` in `environment.d` (waybar uses `$JOURNEY_PATH/default/waybar/...`)
- [x] `bin/journey-system-wake` — paired with hypridle's `after_sleep_cmd`

### Phase 9 — Package & Update Flow

- [x] `bin/journey-pkg-add` — auto-routes between pacman and yay; `--repo`/`--aur` force, `--yes` for noconfirm
- [x] `bin/journey-pkg-remove` — `pacman -Rs` (handles pacman + yay installs uniformly); `--purge` adds `-nc`
- [x] `bin/journey-pkg-aur-install` — alias for `journey-pkg-add --aur ...`
- [x] `bin/journey-update` — 6 phases: pull → migrate → base pkgs → AUR pkgs → system upgrade (`pacman -Syu` + `yay -Sua`) → `post-update` hook. Flags: `--check`, `--no-pull`, `--no-packages`, `--no-aur`, `--no-system`, `--yes`. Suggests reboot when kernel or hyprland was upgraded. Network failures on `git fetch` degrade gracefully (continue to local steps).
- [x] `bin/journey-version` — print version
- [x] `bin/journey-migrate` — runs `install/migrations/NNN-*.sh` scripts in numeric order; tracks state in `~/.local/state/journey/migrations.done`. Per-file idempotency; abort on first failure

### Phase 10 — Polish

- [ ] First-run welcome screen
- [ ] `journey help` polished output (groups, summaries, examples)
- [ ] CI: shellcheck all `bin/journey-*` scripts
- [ ] `install.sh` idempotency (re-run-safe)
- [ ] Uninstaller (`bin/journey-uninstall`)
- [ ] Hosted install URL + landing page
- [ ] Hardware detection (NVIDIA, Intel, T2 MacBook, Surface, Dell XPS, Framework16) — install matching driver packages from `packages/system.packages` only when needed

---

## How to Pick Back Up

1. Scan the checklist top-down. First `[ ]` is your next task.
2. Phase 0 + 1 + 2 + start of 3 are done — that means a fresh Arch box can run the install, get walker bound to `SUPER+SPACE` as Journey Companion, all hyprland keybinds work (commands they call may be stubs), and Tokyo Night theme is dropped into place.
3. Hottest next items: theme switcher (Phase 3) and the `journey-menu` family (Phase 4) — those unlock the keybinds that currently call into stub commands.

## Layout

```
~/.local/share/journey/         (installed here by install.sh)
├── version
├── bin/                        # journey CLI + all subcommands
├── default/                    # configs stowed into ~/.config/
│   ├── hypr/
│   ├── walker/
│   ├── elephant/
│   ├── waybar/
│   ├── mako/
│   └── ...
├── themes/                     # bundled themes
│   └── tokyo-night/
├── hooks/                      # default hooks
├── install/                    # install helpers, post-install
└── packages/                   # pacman + AUR package lists

~/.config/journey/              (user state, created on first run)
├── current/
│   ├── theme/                  # symlink → themes/<active>/
│   ├── theme.name              # name of active theme
│   └── background              # symlink → active background image
├── branding/                   # user about.txt, screensaver.txt
├── hooks/                      # user-defined hook scripts
└── themes/                     # user custom themes
```

## Naming

- Commands: `journey-<group>-<verb>` (e.g. `journey-theme-set`, `journey-launch-companion`)
- The CLI dispatcher is `journey` — `journey theme set tokyo-night` is equivalent to `journey-theme-set tokyo-night`.
- The launcher binary is **stock `walker`** under the hood; `journey-launch-companion` is the entry point bound to `SUPER+SPACE`.

## License

TBD.
