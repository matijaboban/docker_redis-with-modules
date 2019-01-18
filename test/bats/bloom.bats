#!/usr/bin/env bats

docker_id=NULL

# load fixtures/setup
load test_helper


## get target docker ID
get_docker_id ()
{
    if [ -z $docker_id ]; then
        echo $(docker ps -q)
    else
        echo $docker_id
    fi
}

## set target docker id
docker_id=$(get_docker_id)


base_cli ()
{
    if [ -z "$docker_id" ]; then
         docker_id=$(docker ps -q)
         echo "docker_id not found"
    else
        echo found: $docker_id
    fi

    echo "docker exec $docker_id redis-cli"
}


## RediSearch
@test "rSerBase_01 - Create simple index" {
    # Set test index name
    index_name=$(generate_key rSerBase_01)
    command_base=$(base_cli)

    ## create index
    run $command_base FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run $command_base FT.INFO $index_name
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "$index_name" ]

    ## remove index
    run $command_base FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}

@test "rSerBase_02 - Create simple index and add entry" {
    # Set test index name
    index_name=$(generate_key rSerBase_02)
    command_base=$(base_cli)

    ## create index
    run $command_base FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## add entry
    run $command_base FT.ADD $index_name doc1 1.0 FIELDS title "hello world" body "lorem ipsum" url "http://matijaboban.com"
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    ## search index returning only a single field
    run $command_base FT.SEARCH $index_name "hello world" LIMIT 0 10 RETURN 1 url
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[3]}" = "http://matijaboban.com" ]

    ## remove index
    run $command_base FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}
