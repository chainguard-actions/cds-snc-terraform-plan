<!-- markdownlint-disable -->

# Hardening Report: cds-snc--terraform-plan/v5.0.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cds-snc--terraform-plan/v5.0.2** was hardened automatically. 8 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): `${{ github.repository }}` is interpolated directly inside a `run:` shell script. The expression `full_repo="${{ github.repository }}"` is expanded by the YAML template engine before the shell sees it, allowing an attacker-controlled repository name to inject shell metacharacters.

Locations:

- `.github/workflows/ossf-scorecard.yml:33`

### script-injection (severity: high)

Sub-rule (a): `${{ github.repository }}` is interpolated directly inside two `run:` shell scripts. In the 'Upload zip to S3 bucket' step: `ZIP_FILE=\`basename ${{ github.repository }}\`` and `aws s3 cp ... s3://${{ secrets.AWS_S3_BACKUP_BUCKET }}/${{ github.repository }}/...`. In the 'Notify Slack channel' step: `${{ github.repository }}` is embedded in a JSON string passed to curl. These allow injection via the repository name.

Locations:

- `.github/workflows/s3-backup.yml:30`
- `.github/workflows/s3-backup.yml:35`

### script-injection (severity: high)

Sub-rule (a): `${{ env.TRUFFLEHOG_VERSION }}` is interpolated directly inside a `run:` shell script in the 'Install TruffleHog' step: `| sh -s -- -b /usr/local/bin v${{ env.TRUFFLEHOG_VERSION }}`. Any expression inside `${{ }}` is expanded by the YAML template engine before the shell executes it, enabling injection.

Locations:

- `.github/workflows/pr-test.yaml:130`

### unsafe-shell (severity: high)

The 'Install TruffleHog' step downloads a remote install script and pipes it directly to `sh`: `curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- ...`. The script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `.github/workflows/pr-test.yaml:129`

### missing-permissions (severity: medium)

The workflow has no top-level `permissions:` key and the only job (`sync-labels`) also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad.

Locations:

- `.github/workflows/labels.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level `permissions:` key and the only job (`ci`) also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad.

Locations:

- `.github/workflows/ci.yaml:1`

### missing-permissions (severity: medium)

The workflow has no top-level `permissions:` key and the only job (`drift-detector-empty-resource`) also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad.

Locations:

- `.github/workflows/test-drift-detector.yml:1`

### unpinned-uses (severity: high)

Three `uses:` references in the example workflow use mutable tag-based refs instead of immutable 40-character commit SHAs, making them vulnerable to supply-chain attacks if the referenced tags are moved: `actions/checkout@v4`, `cds-snc/terraform-tools-setup@v1`, `cds-snc/terraform-plan@v1`.

Locations:

- `examples/drift-detection.yml:16`
- `examples/drift-detection.yml:20`
- `examples/drift-detection.yml:24`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell, missing-permissions, unpinned-uses

**Notes:**

Fixed all 8 findings across 6 files:

1. ossf-scorecard.yml (script-injection): Moved `${{ github.repository }}` into env var `GITHUB_REPOSITORY_NAME` and referenced it as `$GITHUB_REPOSITORY_NAME` in the shell script.

2. s3-backup.yml (script-injection): Moved `${{ github.repository }}` into `REPO_NAME` env var and `${{ secrets.AWS_S3_BACKUP_BUCKET }}`/`${{ secrets.SLACK_NOTIFY_WEBHOOK }}` into env vars for both affected steps.

3. pr-test.yaml (unsafe-shell + script-injection): Downloaded TruffleHog install script to `/tmp/trufflehog-install.sh` first then executed it separately (fixing curl|sh pipe), and moved `${{ env.TRUFFLEHOG_VERSION }}` into env var `TRUFFLEHOG_INSTALL_VERSION`.

4. labels.yml (missing-permissions): Added top-level `permissions: issues: write, pull-requests: write` (needed for label management).

5. ci.yaml (missing-permissions): Added top-level `permissions: contents: read`.

6. test-drift-detector.yml (missing-permissions): Added top-level `permissions: contents: read, pull-requests: write`.

7. examples/drift-detection.yml (unpinned-uses): Pinned all three action refs to full commit SHAs: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4, cds-snc/terraform-tools-setup@cc15ce9039f6c37c592fb9930b70466b229d2e9b # v1, cds-snc/terraform-plan@1519c0074bc5bee9e949c7d1d4d7636a75c2479e # v1.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Fixed the invalid 41-character SHA for `slackapi/slack-github-action` in `.github/workflows/test-drift-detector.yml` (line 34). The ref `91efab103c0de0a537f72a35f6b8cda0ee76bf0a2` had an extra trailing `2`, making it 41 characters. Replaced with the correct 40-character SHA `91efab103c0de0a537f72a35f6b8cda0ee76bf0a` (verified via lookup_action_sha for the v2.1.1 tag), preserving the `# v2.1.1` comment.

### Iteration 3

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

1. Fixed unpinned-uses in examples/drift-detection.yml: The slackapi/slack-github-action reference had an invalid 41-character SHA (91efab103c0de0a537f72a35f6b8cda0ee76bf0a2). Replaced with the correct 40-character SHA (91efab103c0de0a537f72a35f6b8cda0ee76bf0a) for v2.1.1, confirmed via lookup_action_sha.
2. Fixed script-injection in .github/workflows/ossf-scorecard.yml: The 'Add metadata' step was interpolating $OWNER and $REPO directly into the jq filter string outside single quotes, allowing shell metacharacters to be interpreted. Fixed by using jq's --arg flag (--arg owner "$OWNER" --arg repo "$REPO") to safely pass values as named jq variables, and double-quoting the shell variable assignments.

