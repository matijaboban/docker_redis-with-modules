

echo 'load helper'
fixtures() {
  TEST_FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
  TEST_RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "${TEST_FIXTURE_ROOT}")"
}
