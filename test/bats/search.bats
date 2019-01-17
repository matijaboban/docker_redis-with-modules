#!/usr/bin/env bats

# load fixtures/setup
load test_helper

# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi

## RediSearch
@test "s1" {
    run redis-cli FT.CREATE keytype-search SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]
}

@test "js2" {
    run redis-cli FT.ADD keytype-search doc1 1.0 FIELDS title "hello world" body "lorem ipsum" url "http://redis.io"
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]
}

@test "js3" {
    run redis-cli FT.SEARCH keytype-search "hello world" LIMIT 0 10 RETURN 1 url
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[3]}" = "http://redis.io" ]

}

@test "js4" {
    run redis-cli FT.DROP keytype-search
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]
}


@test "js4" {
    run redis-cli FT.DROP keytype-search
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]
}

@test "last" {
    run echo "last"
    echo "last test"
    [ "$status" -eq 0 ]
    echo "$output"
    [ "$output" = "last" ]
}


## Autosuggest
@test "rSerAutoSug_03 - Calling autosuggest on an non-existing index" {
    run redis-cli FT.SUGGET rSerAutoSug_03 item
    [ "$status" -eq 0 ]
    [ "$output" == '' ]
}

@test "rSerAutoSug_04 - Calling autosuggest with payload on an non-existing index" {
    run redis-cli FT.SUGGET rSerAutoSug_04 item WITHPAYLOADS
    [ "$status" -eq 0 ]
    [ "$output" == '' ]
}

@test "rSerAutoSug_05 - Calling autosuggest with payload on an empty index" {
    ## create index
    run redis-cli FT.CREATE rSerAutoSug_05 SCHEMA name TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    run redis-cli FT.SUGGET rSerAutoSug_05 item WITHPAYLOADS
    [ "$status" -eq 0 ]
    [ "$output" == '' ]

    ## remove index
    run redis-cli FT.DROP rSerAutoSug_05
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}
