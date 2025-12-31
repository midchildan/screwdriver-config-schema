#!/usr/bin/env bash

set -euo pipefail

readonly SRC='https://github.com/screwdriver-cd/config-parser/archive/refs/heads/master.tar.gz'
readonly NEGATIVES=(
  'bad-*.yaml'
  'not-enough-commands.yaml'
)
readonly EXCLUDES=(
  # Not schema errors and/or depends on the Screwdriver runtime to catch
  bad-build-cluster.yaml
  bad-notification-email-settings.yaml
  bad-notification-shared-settings.yaml
  bad-notification-slack-email-settings.yaml
  bad-notification-slack-settings.yaml
  bad-replace-image.yaml

  # Not expressable with JSON schema
  bad-stages-duplicate-job.yaml
  bad-stages-nonexistent-job.yaml
  bad-step-teardown.yaml
  pipeline-with-stages-and-invalid-sourcePaths.yaml
  pipeline-with-stages-and-invalid-triggers.yaml

  # These deal with Screwdriver templates
  parse-pipeline-template-invalid.yaml
  parse-pipeline-template-with-mergeSharedSteps-annotation.yaml
  parse-pipeline-template-with-shared-setting.yaml
  validate-pipeline-template-invalid.yaml
  validate-pipeline-template-with-job-template.yaml
)

readonly TEST_DATA_DIR='third-party/screwdriver-config-parser'

DLDIR=

cleanup() {
  if [[ -n "$DLDIR" ]]; then
    rm -rf "$DLDIR"
  fi
}
trap cleanup EXIT

main() {
  if (( BASH_VERSINFO[0] < 4 )); then
    echo '[ERROR] Requires Bash 4.0 or later' >&2
    exit 1
  fi

  case "${1:-test}" in
    fetch) run::fetch ;;
    test) run::test ;;
    *) run::help ;;
  esac
}

testcase() {
  nickel eval --apply-contract src/screwdriver.schema.ncl "$1" >/dev/null
}

run::fetch() {
  DLDIR="$(mktemp -d)"
  curl -sSfL "$SRC" | tar xzf - -C "$DLDIR" --strip-components 1

  local file
  for file in "${EXCLUDES[@]}"; do
    rm "$DLDIR/test/data/$file"
  done

  cp "$DLDIR/"{LICENSE,test/data/*.yaml} "$TEST_DATA_DIR"
}

run::test() {
  local IFS=
  local file relpath
  local -A negatives

  pushd "$TEST_DATA_DIR"
  # shellcheck disable=SC2068
  for file in ${NEGATIVES[@]}; do
    negatives[$file]=1
  done
  popd

  for relpath in "$TEST_DATA_DIR/"*.yaml; do
    file="${relpath##*/}"
    echo "$file"
    if [[ -n ${negatives[$file]:-} ]]; then
      if testcase "$relpath"; then
        echo '[ERROR] Expected error, but got success' >&2
        exit 1
      fi
    else
      if ! testcase "$relpath"; then
        echo '[ERROR] Expected success, but got error' >&2
        exit 1
      fi
    fi
  done
}

run::help() {
  cat <<EOF
$0 [<command>]

Commands:
  test  - run tests (default)
  fetch - fetch test files from upstream
EOF
exit 1
}

pushd() {
  command pushd "$@" > /dev/null
}

# shellcheck disable=SC2120
popd() {
  command popd "$@" > /dev/null
}

main "$@"
