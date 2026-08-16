<!-- markdownlint-disable -->

# Hardening Report: cds-snc--terraform-plan/v5.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **cds-snc--terraform-plan/v5.0.1** was hardened automatically. 8 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): `${{ github.repository }}` is interpolated directly inside a `run:` shell command string. In the 'Add metadata' step, the expression is assigned to a shell variable via `full_repo="${{ github.repository }}"` — the YAML template substitution happens before the shell sees the value, allowing an attacker who can control the repository name to inject shell metacharacters. Offending line: `full_repo="${{ github.repository }}"`

Locations:

- `.github/workflows/ossf-scorecard.yml:34`

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings. In the 'Upload zip to S3 bucket' step: `ZIP_FILE=\`basename ${{ github.repository }}\`` and `s3://${{ secrets.AWS_S3_BACKUP_BUCKET }}/${{ github.repository }}/` embed github context and secrets directly into shell commands. In the 'Notify Slack channel if this job failed' step: `${{ github.repository }}` and `${{ secrets.SLACK_NOTIFY_WEBHOOK }}` are interpolated directly into shell commands. These allow injection of shell metacharacters before the shell parses the command.

Locations:

- `.github/workflows/s3-backup.yml:29`
- `.github/workflows/s3-backup.yml:34`

### script-injection (severity: high)

Sub-rule (a): `${{ env.TRUFFLEHOG_VERSION }}` is interpolated directly inside a `run:` shell command string in the 'Install TruffleHog' step: `| sh -s -- -b /usr/local/bin v${{ env.TRUFFLEHOG_VERSION }}`. Even though `env.*` is workflow-controlled rather than directly attacker-supplied, any `${{ ... }}` expression inside a `run:` block is a script-injection finding as it undergoes YAML template substitution before the shell parses the command.

Locations:

- `.github/workflows/pr-test.yaml:131`

### unsafe-shell (severity: high)

The 'Install TruffleHog' step pipes the output of `curl` directly to `sh -s` without first saving the script to a file and verifying it. Pattern: `curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh \ | sh -s -- -b /usr/local/bin v${{ env.TRUFFLEHOG_VERSION }}`. This allows remote code execution if the URL is compromised or the content is tampered with in transit.

Locations:

- `.github/workflows/pr-test.yaml:131`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad (write access to all scopes). A minimal permissions block should be added.

Locations:

- `.github/workflows/ci.yaml:1`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad. A minimal permissions block should be added.

Locations:

- `.github/workflows/labels.yml:1`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad. A minimal permissions block (e.g. `pull-requests: read` for the drift detector) should be added.

Locations:

- `.github/workflows/test-drift-detector.yml:1`

### unpinned-uses (severity: high)

The `uses:` reference `slackapi/slack-github-action@91efab103c0de0a537f72a35f6b8cda0ee76bf0a2` uses a ref that is 41 hexadecimal characters long — not a valid 40-character SHA-1 commit hash. This is not a pinned immutable reference and is vulnerable to supply-chain attacks if the tag or branch it resolves to is updated. It should be replaced with a full 40-character commit SHA.

Locations:

- `.github/workflows/test-drift-detector.yml:28`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unsafe-shell, missing-permissions, unpinned-uses

**Notes:**

Fixed 7 findings across 6 workflow files: (1) ossf-scorecard.yml: Moved ${{ github.repository }} into env var FULL_REPO to prevent script injection. (2) s3-backup.yml: Moved ${{ github.repository }}, ${{ secrets.AWS_S3_BACKUP_BUCKET }}, and ${{ secrets.SLACK_NOTIFY_WEBHOOK }} into env vars to prevent script injection. (3) pr-test.yaml: Fixed both script-injection (moved ${{ env.TRUFFLEHOG_VERSION }} to env var) and unsafe-shell (download install.sh to /tmp first, then execute separately instead of piping curl to sh). (4) ci.yaml: Added top-level permissions: contents: read. (5) labels.yml: Added top-level permissions: issues: write, pull-requests: write. (6) test-drift-detector.yml: Added top-level permissions: contents: read, pull-requests: read and fixed the invalid 41-char SHA for slackapi/slack-github-action to the correct 40-char SHA 91efab103c0de0a537f72a35f6b8cda0ee76bf0a (v2.1.1).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in .github/workflows/ossf-scorecard.yml at the 'Add metadata' step. The jq command previously interpolated $OWNER and $REPO by breaking out of single quotes, allowing shell metacharacters from the untrusted github.repository context to be executed. Replaced with jq's --arg flag: `jq -c --arg owner "$OWNER" --arg repo "$REPO" '. + {"metadata_owner": $owner, "metadata_repo": $repo, "metadata_query": "ossf"}'` so the values are treated as data by jq rather than being expanded in the shell command string.

