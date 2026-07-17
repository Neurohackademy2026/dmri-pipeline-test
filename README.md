# dmri-pipeline-test

GitHub tools talk/tutorial: a minimal dMRI (diffusion MRI) QC pipeline used to demonstrate a
full GitHub Actions workflow — container builds, GHCR, release-driven data fetch, caching,
GitHub Pages deployment, and optional email notifications.

## What it is

`process_dmri.py` loads a diffusion MRI scan, computes a mock SNR (signal-to-noise ratio) and
a mock FA (fractional anisotropy) map, and writes:
- `output/qc_slice.png` — mid-axial FA slice image
- `output/stats.json` — SNR, resolution, volume count, PASS/FAIL status (pass threshold: SNR > 10)

Input data, in order of preference:
1. `sample_dmri.nii.gz` downloaded from a GitHub Release asset
2. Stanford HARDI dataset, auto-fetched via `dipy` (cached across runs)
3. Synthetic data, generated on the fly (last-resort fallback, e.g. no network)

Two chained GitHub Actions workflows:
- **`build-container.yml`** — builds the `Dockerfile` and pushes it to GHCR on push to `main`
  (when `Dockerfile` changes) or manual dispatch.
- **`run-pipeline.yml`** — runs the pipeline inside that prebuilt container, builds a small
  HTML report, deploys it to GitHub Pages, and optionally emails the result.

## Setup (after forking)

1. **Enable GitHub Pages** — not inherited by forks. Go to
   Settings → Pages → Build and deployment → Source → **GitHub Actions**.
2. **Check Actions workflow permissions** — `build-container.yml` needs to push to GHCR.
   Go to Settings → Actions → General → Workflow permissions → **Read and write permissions**.
   (A repo's default token permissions can only be narrowed by the workflow YAML, not widened,
   so this must be enabled at the repo/org level.)
3. **(Optional) Real scan data** — create a GitHub Release (tag `v1.0-data` by default) and
   attach a `sample_dmri.nii.gz` asset. Skip this to let the pipeline fall back to the Stanford
   HARDI dataset automatically.
4. **(Optional) Email notifications** — add these repository secrets
   (Settings → Secrets and variables → Actions → New repository secret) to get an email with the
   SNR/status/report link after each run:
   - `MAIL_USERNAME` — sender email address
   - `MAIL_PASSWORD` — app password (not your real account password; for Gmail:
     Google Account → Security → 2-Step Verification → App Passwords)
   - `MAIL_TO` — recipient address
   - `MAIL_SERVER` / `MAIL_PORT` — optional, default to `smtp.gmail.com` / `465`

   If these secrets aren't set, the notify step is skipped silently — nothing breaks.

No image names, package names, or paths need editing — the container image name is derived
from `${{ github.repository }}` automatically.

## How to use

**Automatic**: publish a GitHub Release — `run-pipeline.yml` runs automatically and tries to
pull `sample_dmri.nii.gz` from that release's own assets.

**Manual**: Actions tab → "Execute dMRI Pipeline" → Run workflow. Two optional inputs:
- `release_tag` — which release to pull the data asset from (default `v1.0-data`)
- `asset_name` — name of the data asset to download (default `sample_dmri.nii.gz`)

Leave both blank to use the defaults.

**Result**: once the run finishes, the QC report is live at
`https://<owner>.github.io/<repo>/` (also linked from the run's `deploy-pages` job and the
repo's Environments tab).

## Local development

```bash
pip install numpy nibabel dipy matplotlib
python process_dmri.py
```

Or use the provided `Dockerfile` / `.devcontainer/devcontainer.json` (same dependency set).
