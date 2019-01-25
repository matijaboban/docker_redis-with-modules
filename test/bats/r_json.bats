#!/usr/bin/env bats

# load fixtures/setup
load test_helper

## tests setup
setup()
{
    command_base=$(base_cli)
}

## ReJson
@test "rJson_01 - Create json set" {
    # Set test index name
    index_name=$(generate_key rJson_01)

    ## create key
    run $command_base JSON.SET $index_name . '{"name":"Leonard Cohen","lastSeen":1478476800,"loggedOut":true}'
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run $command_base JSON.GET $index_name loggedOut
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]

    ## remove key
    run $command_base JSON.DEL $index_name name
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]

    ## check removed key
    run $command_base JSON.GET $index_name name
    [ "$status" -eq 0 ]
    [ "$output" = "ERR key 'name' does not exist at level 0 in path" ]
}
