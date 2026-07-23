<!-- markdownlint-disable -->

# Hardening Report: cds-snc--terraform-plan/v5.0.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cds-snc--terraform-plan/v5.0.4** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Direct ${{ ... }} expression interpolation inside run: shell commands. In ossf-scorecard.yml, `${{ github.repository }}` is interpolated directly into a shell variable assignment (`full_repo="${{ github.repository }}"`). In s3-backup.yml, `${{ github.repository }}` is used inside a backtick command substitution and in an S3 path, and `${{ secrets.SLACK_NOTIFY_WEBHOOK }}` is interpolated directly as a curl argument. In pr-test.yaml, `${{ env.TRUFFLEHOG_VERSION }}` is interpolated directly into the shell command piped to sh. All of these violate sub-rule (a): any ${{ ... }} expression directly inside a run: block is a script-injection risk regardless of context.

Locations:

- `.github/workflows/ossf-scorecard.yml:38`
- `.github/workflows/s3-backup.yml:29`
- `.github/workflows/s3-backup.yml:35`
- `.github/workflows/pr-test.yaml:130`

### unsafe-shell (severity: high)

Remote script piped directly to a shell interpreter. In pr-test.yaml, the Install TruffleHog step downloads a script from `https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh` and pipes it directly to `sh` via: `curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin v${{ env.TRUFFLEHOG_VERSION }}`. The script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `.github/workflows/pr-test.yaml:130`

### unpinned-uses (severity: high)

The `uses:` reference `slackapi/slack-github-action@91efab103c0de0a537f72a35f6b8cda0ee76bf0a2` in test-drift-detector.yml uses a 41-character string that is NOT a valid 40-character hex commit SHA. This is not a pinned immutable reference and is vulnerable to supply-chain attacks. It must be replaced with a full 40-character commit SHA.

Locations:

- `.github/workflows/test-drift-detector.yml:30`

### missing-permissions (severity: medium)

Three workflow files have no top-level `permissions:` key and no job-level `permissions:` keys, meaning they run with the default (potentially broad) token permissions: `labels.yml`, `ci.yaml`, and `test-drift-detector.yml`. Each should declare explicit minimal permissions.

Locations:

- `.github/workflows/labels.yml:1`
- `.github/workflows/ci.yaml:1`
- `.github/workflows/test-drift-detector.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell, unpinned-uses, missing-permissions

**Notes:**

Fixed all four finding types: (1) script-injection in ossf-scorecard.yml, s3-backup.yml, and pr-test.yaml by moving all ${{ }} expressions out of run: blocks into step env: blocks; (2) unsafe-shell in pr-test.yaml by downloading the TruffleHog install script to /tmp/trufflehog-install.sh first, then executing it separately with sh, then removing it; (3) unpinned-uses in test-drift-detector.yml by replacing the invalid 41-char SHA with the correct 40-char SHA 91efab103c0de0a537f72a35f6b8cda0ee76bf0a for slackapi/slack-github-action v2.1.1; (4) missing-permissions in labels.yml (issues: write, pull-requests: write), ci.yaml (contents: read), and test-drift-detector.yml (contents: read, pull-requests: write).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in .github/workflows/ossf-scorecard.yml at line 44. Changed the jq command in the 'Add metadata' step from using shell string interpolation (`'$OWNER'` and `'$REPO'` embedded in the filter string) to using jq's `--arg` parameters (`--arg owner "$OWNER" --arg repo "$REPO"`), with the values referenced as `$owner` and `$repo` inside the jq filter. This ensures that even if github.repository contains shell metacharacters, they are safely handled as data by jq rather than being interpreted by the shell.

