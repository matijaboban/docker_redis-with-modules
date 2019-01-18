

# echo 'load helper'
# fixtures() {
#   TEST_FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
#   TEST_RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "${TEST_FIXTURE_ROOT}")"
# }



## Generate key
## TODO: notes
generate_key () {
    key_prefix=${1:-index}
    timestamp=$(date +%s)
    randnum=$[RANDOM]
    key=$key_prefix-$(date +%s)-$(($randnum))

    echo $key
}
