# ChurchCRM visuals

The screenshots and videos of ChurchCRM, served at <https://cdn.churchcrm.io/> for churchcrm.io and docs.churchcrm.io. They show **one release**: the latest. Nothing older is kept.

| File | What it is |
|---|---|
| `screenshots/<locale>/<device>/<name>.png` | A screenshot. Locales: ar, de, en, es, fr, pt, ru, zh. Devices: desktop, tablet, mobile. |
| `videos/…` | Recordings and setup videos |
| `manifest.json` | One entry per file: `name`, `title`, `category`, `purpose`, `locale`, `device`, `dark`, `width`, `height`, `sizeBytes`, `relativePath`, `release`. The URL of a file is `https://cdn.churchcrm.io/` plus its `relativePath`. |
| `release.json` | The release, the CRM capture run and commit, when it was published, and counts |

Add `?v=<release>` to a URL so a new release is not served from a cache.

## How it is updated

The capture runs in `ChurchCRM/CRM` ("Marketing: capture assets"). After a release is published, run **Publish visuals** here from the Actions tab. It downloads that capture, checks that every file in the manifest exists, replaces the content, and pushes it as a single new root commit to `main`, so the history never grows with each release. GitHub Pages serves `main`.

Blank inputs mean the latest successful capture on `master` and the version in CRM `package.json`. If the run fails, run it again with the same `run_id`. CRM keeps the capture artifact for a limited time.

Do not edit the published files by hand: the next publish replaces them.
