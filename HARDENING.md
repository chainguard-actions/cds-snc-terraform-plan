<!-- markdownlint-disable -->

# Hardening Report: cds-snc--terraform-plan/v5.0.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **cds-snc--terraform-plan/v5.0.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The file examples/drift-detection.yml contains three unpinned `uses:` references that use mutable tags instead of full 40-character commit SHAs. This exposes the workflow to supply-chain attacks if the referenced tags are moved or overwritten:
- `actions/checkout@v4` (tag, not SHA)
- `cds-snc/terraform-tools-setup@v1` (tag, not SHA)
- `cds-snc/terraform-plan@v1` (tag, not SHA)

The `slackapi/slack-github-action@91efab103c0de0a537f72a35f6b8cda0ee76bf0a2` reference is correctly pinned to a SHA and passes.

Locations:

- `examples/drift-detection.yml:17`
- `examples/drift-detection.yml:21`
- `examples/drift-detection.yml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned all three unpinned `uses:` references in examples/drift-detection.yml:
- `actions/checkout@v4` → `actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4`
- `cds-snc/terraform-tools-setup@v1` → `cds-snc/terraform-tools-setup@cc15ce9039f6c37c592fb9930b70466b229d2e9b # v1`
- `cds-snc/terraform-plan@v1` → `cds-snc/terraform-plan@1519c0074bc5bee9e949c7d1d4d7636a75c2479e # v1`

The already-pinned `slackapi/slack-github-action@91efab103c0de0a537f72a35f6b8cda0ee76bf0a2` reference was left unchanged.

