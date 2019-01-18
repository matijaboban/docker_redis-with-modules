#!/usr/bin/env bats

# load fixtures/setup
load test_helper

base_cli ()
{
    docker_id=$(docker ps -q)
    echo "docker exec -it $docker_id redis-cli"
}



## RediSearch
@test "rSerBase_01 - Create simple index" {
    # Set test index name
    index_name=$(generate_key rSerBase_01)
    cli_base=$(base_cli)

    ## create index
    run cli_base FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run cli_base FT.INFO $index_name
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "$index_name" ]

    ## remove index
    run cli_base FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}
