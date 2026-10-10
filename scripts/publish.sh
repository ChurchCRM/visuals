#!/usr/bin/env bash
# Replace the published visuals with the output of one ChurchCRM/CRM capture run.
#
# Needs: GH_TOKEN able to read ChurchCRM/CRM runs and artifacts, and a checkout of
# this repo with a token that can push to main.
# Env:   RUN_ID   capture run to publish. Blank: latest successful run on master.
#        RELEASE  ChurchCRM release the visuals show (x.y.z). Blank: package.json
#                 version at the run's commit.
#
# One release is published at a time. The content is replaced and pushed as a
# single new root commit, so history never grows with each release.
set -euo pipefail

CRM="ChurchCRM/CRM"
RUN_ID="${RUN_ID:-}"
RELEASE="${RELEASE:-}"

if [ -z "$RUN_ID" ]; then
  RUN_ID=$(gh run list -R "$CRM" --workflow marketing-capture-assets.yml --branch master \
    --status success --limit 1 --json databaseId --jq '.[0].databaseId // empty')
  [ -n "$RUN_ID" ] || { echo "::error::No successful capture run on master. Pass run_id." >&2; exit 1; }
fi
commit=$(gh run view "$RUN_ID" -R "$CRM" --json headSha --jq .headSha)

if [ -z "$RELEASE" ]; then
  RELEASE=$(gh api "repos/$CRM/contents/package.json?ref=$commit" --jq .content | base64 -d | jq -r .version)
fi
[[ "$RELEASE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "::error::Release '$RELEASE' is not x.y.z." >&2; exit 1; }
echo "Publishing run $RUN_ID (commit ${commit:0:12}) as release $RELEASE"

in="$(mktemp -d)"
gh run download "$RUN_ID" -R "$CRM" -n "marketing-visuals-$RUN_ID" -D "$in"

[ -s "$in/manifest.json" ] || { echo "::error::The artifact has no manifest.json." >&2; exit 1; }
count=$(jq 'length' "$in/manifest.json")
[ "$count" -gt 0 ] || { echo "::error::The manifest is empty." >&2; exit 1; }
missing=0
while IFS= read -r p; do
  [ -f "$in/$p" ] || { echo "::error::Missing $p" >&2; missing=$((missing + 1)); }
done < <(jq -r '.[] | select(.exists) | .relativePath' "$in/manifest.json")
[ "$missing" -eq 0 ] || { echo "::error::$missing files from the manifest are not in the artifact." >&2; exit 1; }

# Replace the published content. The workflow, scripts and site files stay.
rm -rf screenshots videos manifest.json release.json
cp -R "$in/screenshots" ./screenshots
[ -d "$in/videos" ] && cp -R "$in/videos" ./videos
jq --arg r "$RELEASE" 'map(. + {release: $r})' "$in/manifest.json" > manifest.json
jq -n --arg r "$RELEASE" --arg run "$RUN_ID" --arg c "$commit" --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --slurpfile m manifest.json \
  '{release: $r, runId: ($run | tonumber), commit: $c, publishedAt: $t, entries: ($m[0] | length),
    locales: ([$m[0][].locale] | unique), devices: ([$m[0][].device] | unique)}' > release.json

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git checkout --orphan next
git add -A
git commit -q -m "ChurchCRM $RELEASE visuals (capture run $RUN_ID)"
git push --force origin next:main
echo "Published ChurchCRM $RELEASE: $count entries."
