#!/usr/bin/env bats

# load fixtures/setup
load test_helper

base_cli ()
{
    echo "docker exec -it $(docker ps -q)"
}



## RediSearch
@test "rSerBase_01 - Create simple index" {
    # Set test index name
    index_name=$(generate_key rSerBase_01)

    ## create index
    run $base_cli FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run $base_cli FT.INFO $index_name
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "$index_name" ]

    ## remove index
    run $base_cli FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}
