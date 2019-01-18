

# echo 'load helper'
# fixtures() {
#   TEST_FIXTURE_ROOT="${BATS_TEST_DIRNAME}/fixtures/$1"
#   TEST_RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "${TEST_FIXTURE_ROOT}")"
# }



## Generate key
## TODO: notes
generate_key () {
    # set default key prefix value if one is not
    # not passed as a parameter
    key_prefix=${1:-index}

    # generate UNIX epoch
    timestamp=$(date +%s)

    # generate random integer
    randnum=$[RANDOM]

    # build the key
    key=$key_prefix-$(date +%s)-$(($randnum))

    echo $key
}


# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi
