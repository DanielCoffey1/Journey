# install/

Holds installer-side assets that aren't run on every user's machine.

| File / dir | Purpose |
|---|---|
| `landing-page.html` | Starter HTML for `get.journey.dev`. Whoever hosts the curl-pipe endpoint should serve this *and* the contents of `install.sh` at the root so `curl -fsSL https://get.journey.dev` returns the installer body. |
| `migrations/` | Per-version upgrade scripts run by `journey-migrate`. Empty for v0. Names follow `NNN-short-description.sh` for ordering. Each script must be idempotent — once recorded as applied (in `~/.local/state/journey/migrations.done`) it never runs again. |

## Hosting layout for `get.journey.dev`

The simplest setup (Cloudflare Pages / Netlify / nginx):

```
public/
├── index.html              ← copy of install/landing-page.html
└── install.sh              ← copy of install.sh
```

Configure content-type rules:
- `index.html` → `text/html`
- `install.sh` → `text/plain`

Set up `/` to serve the install script when the User-Agent is `curl`/`wget`, and the HTML otherwise. nginx example:

```nginx
location = / {
    if ($http_user_agent ~* "(curl|wget)") {
        rewrite ^ /install.sh break;
    }
    try_files /index.html =404;
}
```
