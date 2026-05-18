# Hooks

`journey-hook <event>` runs every executable file in two directories, in order:

1. `~/.local/share/journey/hooks/<event>/` — shipped defaults (this tree)
2. `~/.config/journey/hooks/<event>/` — user overrides / additions

Files are run in sorted-filename order. Numeric prefixes (`00-`, `10-`, `20-`, …) keep ordering predictable. Hooks may exit non-zero — the runner logs the failure and keeps going.

## Events

| Event | Trigger |
|---|---|
| `post-boot`     | End of Hyprland autostart, ~2s after session start (see `default/hypr/autostart.conf`). Used for one-shot notices / cleanups. |
| `post-update`   | After `journey-update` completes successfully. |
| `theme-set`     | After `journey-theme-set` finishes (theme symlinks + services have been reloaded). Env var `JOURNEY_THEME` is *not* set yet — read the name from `~/.config/journey/current/theme.name`. |
| `battery-low`   | Fired by an optional battery watcher when capacity drops below threshold. Not wired by default — see `bin/journey-battery-watch` to opt in. |
| `font-set`      | After a future `journey-font-set` script — reserved for now. |

## Writing a hook

```bash
$ cat > ~/.config/journey/hooks/post-boot/50-my-tasks.sh <<'EOF'
#!/usr/bin/env bash
notify-send "Welcome back" "$(date +%A)"
EOF
$ chmod +x ~/.config/journey/hooks/post-boot/50-my-tasks.sh
```

The next time the event fires, your script will run.

## Reading hook scripts

The runner discovers hooks by directory listing. Files that are not executable are ignored — that's how to disable a shipped hook without deleting it (`chmod -x`).

A non-zero exit logs a warning via stderr but never aborts the chain. If a hook depends on a tool that may not be installed, check for it with `command -v` and exit 0 silently when missing.
