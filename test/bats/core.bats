#!/usr/bin/env bats

# load fixtures/setup
load test_helper

## tests setup
setup()
{
    command_base=$(base_cli)
}


## Core
@test "rCore_01 - base" {
    # Set test index name
    index_name=$(generate_key rCore_01)

    ## Check redis major version
    run bash -c "$command_base info server | grep redis_version"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "redis_version:5." ]]

    ## check
    run $command_base ping
    [ "$status" -eq 0 ]
    [ "$output" = "PONG" ]
}

@test "rCore_02 - benchmark" {
    # Set test index name
    index_name=$(generate_key rCore_02)

    ## Run base benchmark and confirm expected output
    run $(base_cli redis-benchmark)
    [ "$status" -eq 0 ]
    [[ "$output" =~ "MSET (10 keys)" ]]
}

