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

The capture runs in `ChurchCRM/CRM` (`marketing-capture-assets.yml`). Its `master` publish job dispatches **Publish visuals** here with the capture `run_id`; a non-master capture only checks and does not publish. The workflow downloads the artifact, checks the manifest entries marked as existing, replaces the content and pushes a single new root commit to `main`. GitHub Pages serves `main`.

For manual recovery, run **Publish visuals** from this repository’s Actions tab with the intended `run_id` and release input. Verify the capture belongs to the intended released product before publishing. These instructions describe the existing handoff; stricter stable-release/provenance validation is separate work.

Blank inputs mean the latest successful capture on `master` and the version in CRM `package.json`. If the run fails, run it again with the same `run_id`. CRM keeps the capture artifact for a limited time.

Do not edit the published files by hand: the next publish replaces them.
