# install/smoke

A docker-based smoke test that exercises the full Journey install → use → uninstall lifecycle inside a clean Arch container, without touching your real system.

## Run it

```bash
journey-smoke              # build image + run test
journey-smoke --no-build   # reuse the existing image
journey-smoke --shell      # build image + drop into a shell inside it
journey-smoke --keep       # don't `--rm` the container (inspect with `docker exec`)
```

## What it tests

The test runs `install.sh` with `JOURNEY_SKIP_PACKAGES=1` (skips `pacman -Syu` / yay / systemctl — those need network and would dominate the test runtime), then asserts ~50 expectations across 11 phases:

| Phase | What's checked |
|---|---|
| 1.  install            | `install.sh` exits 0 |
| 2.  install tree       | `JOURNEY_HOME/{bin,default,themes,hooks,version}` present |
| 3.  stowed configs     | Each `default/<app>/` landed at `~/.config/<app>/`; `starship.toml` stayed a file; hyprlock/hypridle made it into `hypr/` |
| 4.  theme symlinks     | `current/theme` symlink, `theme.name` marker, btop theme symlink all correct |
| 5.  PATH plumbing      | `environment.d/10-journey.conf` and `.bashrc` include present |
| 6.  hook layout        | 5 shipped event dirs + 5 seeded user-side event dirs |
| 7.  CLI dispatcher     | `journey`, `journey help`, `journey help <cmd>`, `journey version` all functional |
| 8.  theme switcher     | 19 themes listed; `theme set gruvbox` works under "graceful" mode (no hypr daemon) |
| 9.  hook runner        | `journey-hook post-boot` and `journey-hook theme-set` execute cleanly |
| 10. pkg + update help  | `journey pkg add --help`, `journey-migrate --list`, `journey-update --check ...` |
| 11. uninstall          | `journey-uninstall --yes --purge` reverses everything; nothing left behind |

Final line: `N passed, M failed`. Exits non-zero on any failure.

## Why these aren't tested here

These can't be sensibly exercised in a non-graphical container:

- The walker GUI launcher (needs GTK + Wayland)
- Notifications, OSDs, lock screen, screenshots
- Hyprland keybinds (no compositor running)
- Hardware-specific code paths (NVIDIA, brightness, audio, asusctl)
- AUR package builds (`yay` is skipped)
- Real `pacman -Syu` (would take minutes; tested by `journey-update` users in the wild)

For those, a fresh-Arch VM with `curl -fsSL get.journey.dev | bash` is still the canonical "did it really work?" test.
