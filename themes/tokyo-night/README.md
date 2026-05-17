# Tokyo Night

Source of truth: `colors.toml`. All other per-app files in this directory derive from those colors.

When Journey's theme generator lands (Phase 3 backlog), per-app files will be
regenerated from `colors.toml` at install time instead of being checked in.
Until then, they're pre-baked here.

## Backgrounds

Bundled background images live in `backgrounds/`. Drop your own `.jpg` /
`.png` files there; `journey-menu-background` will pick them up.

The original Omarchy Tokyo Night ships with 6 wallpapers — Journey doesn't
redistribute them. Run `journey-theme-bg-install <file>` to add your own.
