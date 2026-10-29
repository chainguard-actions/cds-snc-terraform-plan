#!/usr/bin/env bash
# Installs fake `terraform` and `tf-summarize` binaries on PATH so the action
# can be exercised deterministically without network access or a real backend.
# Usage: setup-fake-terraform.sh <plan-fixture-json>
# Behaviour of the fake terraform is controlled by env vars at action runtime:
#   FAKE_VALIDATE_FAIL=true  -> `terraform validate` exits 1
#   FAKE_FMT_FAIL=true       -> `terraform fmt -check` exits 3
set -euo pipefail

PLAN_FIXTURE="${1:-}"
FAKEBIN=/tmp/fakebin
mkdir -p "$FAKEBIN"
rm -f /tmp/fake-tf-calls.log
touch /tmp/fake-tf-calls.log

if [ -n "$PLAN_FIXTURE" ]; then
  cp "$PLAN_FIXTURE" /tmp/fake-plan.json
else
  echo '{"format_version":"1.2"}' > /tmp/fake-plan.json
fi

cat > "$FAKEBIN/terraform" <<'EOF'
#!/bin/sh
echo "$*" >> /tmp/fake-tf-calls.log
case "$1" in
  init)
    echo "Terraform has been successfully initialized!"
    exit 0
    ;;
  validate)
    if [ "$FAKE_VALIDATE_FAIL" = "true" ]; then
      echo "Error: Invalid configuration (fake)" >&2
      exit 1
    fi
    echo "Success! The configuration is valid."
    exit 0
    ;;
  fmt)
    if [ "$FAKE_FMT_FAIL" = "true" ]; then
      echo "main.tf"
      exit 3
    fi
    exit 0
    ;;
  plan)
    touch plan.tfplan
    echo "Plan: fake plan output"
    exit 0
    ;;
  show)
    cat /tmp/fake-plan.json
    exit 0
    ;;
esac
exit 0
EOF
chmod +x "$FAKEBIN/terraform"

cat > "$FAKEBIN/tf-summarize" <<'EOF'
#!/bin/sh
echo "tf-summarize $*" >> /tmp/fake-tf-calls.log
cat > /dev/null
echo "| CHANGE | RESOURCE |"
echo "|--------|----------|"
exit 0
EOF
chmod +x "$FAKEBIN/tf-summarize"

echo "$FAKEBIN" >> "$GITHUB_PATH"
mkdir -p "$GITHUB_WORKSPACE/tf-test"
echo "Fake terraform installed in $FAKEBIN"
