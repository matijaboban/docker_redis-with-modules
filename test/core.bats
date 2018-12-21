#!/usr/bin/env bats

# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi

@test "invoking foo with a nonexistent file prints an error" {
  run redis-cli ping
  [ "$status" -eq 0 ]
  [ "$output" = "PONG" ]
}
