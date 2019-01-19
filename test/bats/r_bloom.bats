#!/usr/bin/env bats


# load fixtures/setup
load test_helper

## tests setup
setup()
{
    command_base=$(base_cli)
}


## RediSearch
@test "rBloom_01 - Create simple set" {
    # Set test index name
    index_name=$(generate_key rBloom_01)

    ## create index
    run $command_base BF.MADD $index_name foo bar test-key_01 test-key_02 test-key_03
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "1" ]

    ## check existance of present key
    run $command BF.EXISTS $index_name test-key_01
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]

    ## check existance of non-existant
    run $command BF.EXISTS $index_name test-key_04
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]
}
