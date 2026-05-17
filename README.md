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
- [ ] `bin/journey-theme-list`
- [ ] `bin/journey-theme-set`
- [ ] `bin/journey-theme-current`
- [ ] `bin/journey-theme-install` (install custom theme from file/URL)
- [ ] Symlink-into-`~/.config/journey/current/theme/` mechanism on theme-set
- [ ] Live reload (refresh walker, mako, waybar, swayosd on theme-set)
- [ ] Port remaining 18 themes from Omarchy (catppuccin, gruvbox, nord, rose-pine, kanagawa, ethereal, etc.)
- [ ] Color-token templating so themes generate per-app files at install instead of being pre-baked

### Phase 4 — Menus

- [ ] `bin/journey-menu` — root menu dispatcher
- [ ] `bin/journey-menu-power` (lock / suspend / restart / shut down / log out)
- [ ] `bin/journey-menu-system`
- [ ] `bin/journey-menu-capture` (screenshot / screen record / OCR)
- [ ] `bin/journey-menu-keybindings` (pretty-printed list of all binds)
- [ ] `bin/journey-menu-theme`
- [ ] `bin/journey-menu-background`
- [ ] `bin/journey-menu-toggle`
- [ ] `bin/journey-menu-hardware`
- [ ] `bin/journey-menu-share`
- [ ] `bin/journey-menu-reminder-set`
- [ ] `bin/journey-menu-screenrecord`

### Phase 5 — Hooks

- [x] `bin/journey-hook` runner — `journey-hook <event>` runs all scripts under `~/.config/journey/hooks/<event>/` (and `~/.local/share/journey/hooks/<event>/`)
- [ ] Default hook scripts shipped under `hooks/`: `post-boot`, `post-update`, `theme-set`, `battery-low`, `font-set`
- [ ] `~/.config/journey/hooks/` layout + example/no-op scripts

### Phase 6 — Launchers & Helpers

- [ ] `bin/journey-launch-browser`
- [ ] `bin/journey-launch-editor`
- [ ] `bin/journey-launch-terminal`
- [ ] `bin/journey-launch-webapp` (handles `##` → `#` escaping for hyprland binds)
- [ ] `bin/journey-launch-or-focus` / `journey-launch-or-focus-webapp` / `journey-launch-or-focus-tui`
- [ ] `bin/journey-launch-tui` (generic TUI app launcher)
- [ ] `bin/journey-launch-audio` / `journey-launch-bluetooth` / `journey-launch-wifi`
- [x] `bin/journey-cmd-terminal-cwd` — falls back to `$HOME` when hyprctl/jq missing

### Phase 7 — System Integration

- [x] `bin/journey-first-run` — idempotent no-op stub; will become onboarding wizard
- [x] `bin/journey-toggle-enabled` — looks for marker files under `~/.local/state/journey/toggles/`
- [ ] `bin/journey-hyprland-monitor-watch` (auto-redetect monitors)
- [ ] `bin/journey-hyprland-monitor-internal` (toggle laptop display)
- [ ] `bin/journey-hyprland-monitor-scaling-cycle`
- [ ] `bin/journey-hyprland-window-{pop,transparency-toggle,gaps-toggle,single-square-aspect-toggle,close-all}`
- [ ] `bin/journey-hyprland-workspace-layout-toggle`
- [ ] `bin/journey-toggle-{waybar,idle,nightlight,notification-silencing,touchpad}`
- [ ] `bin/journey-brightness-display` / `journey-brightness-keyboard`
- [ ] `bin/journey-swayosd-client` (wrapper around `swayosd-client` with journey defaults)
- [ ] `bin/journey-audio-{input-mute,output-switch}`
- [ ] `bin/journey-capture-{screenshot,text-extraction}`
- [ ] `bin/journey-system-lock`
- [ ] `bin/journey-battery-status` / `journey-weather-status`
- [ ] `bin/journey-reminder`
- [ ] `bin/journey-powerprofiles-init`
- [ ] `bin/journey-transcode`

### Phase 8 — Application Configs

- [ ] `default/waybar/{config.jsonc,style.css}`
- [ ] `default/mako/core.ini`
- [ ] `default/swayosd/`
- [ ] `default/alacritty/alacritty.toml`
- [ ] `default/ghostty/config`
- [ ] `default/foot/foot.ini`
- [ ] `default/btop/btop.conf`
- [ ] `default/hypridle/config`
- [ ] `default/hyprlock/config`
- [ ] `default/fastfetch/config.jsonc`
- [ ] `default/starship.toml`
- [ ] `default/tmux/tmux.conf`

### Phase 9 — Package & Update Flow

- [ ] `bin/journey-pkg-add` / `journey-pkg-remove` / `journey-pkg-aur-install`
- [ ] `bin/journey-update` — `git pull` + run pacman/yay + run `post-update` hook
- [x] `bin/journey-version` — print version
- [ ] `bin/journey-migrate` — schema migrations between Journey versions

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
