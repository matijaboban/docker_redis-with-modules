#!/usr/bin/env bats

# load fixtures/setup
load test_helper

# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi

## RediSearch
@test "rSerBase_01 - Create simple index" {
    ## create index
    run redis-cli FT.CREATE rSerBase_01 SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run redis-cli FT.INFO rSerBase_01
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "rSerBase_01" ]

    ## remove index
    run redis-cli FT.DROP rSerBase_01
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}

@test "rSerBase_02 - Create simple index and add entry" {
    ## create index
    run redis-cli FT.CREATE rSerBase_02 SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## add entry
    run redis-cli FT.ADD rSerBase_02 doc1 1.0 FIELDS title "hello world" body "lorem ipsum" url "http://matijaboban.com"
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    ## search index returning only a single field
    run redis-cli FT.SEARCH rSerBase_02 "hello world" LIMIT 0 10 RETURN 1 url
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[3]}" = "http://matijaboban.com" ]

    ## remove index
    run redis-cli FT.DROP rSerBase_02
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}

@test "rSerBase_06 - Create simple geo index and add entry" {
    ## create index
    run redis-cli FT.CREATE rSerBase_06 SCHEMA name TEXT WEIGHT 5.0 location GEO
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## add entry(s)
    run redis-cli FT.ADD rSerBase_06 1 1 FIELDS name "Monterrey" location -100.4431802,25.6490376
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    run redis-cli FT.ADD rSerBase_06 2 1 FIELDS name "Vancouver" location -123.1207,49.2827
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    run redis-cli FT.ADD rSerBase_06 3 1 FIELDS name "London" location -0.1278,51.5074
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    ## get index content without filters
    run redis-cli FT.SEARCH rSerBase_06 *
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = -eq 3 ] ## check number of expected returns

    ## search index by single field
    run redis-cli FT.SEARCH rSerBase_06 "@name:Lo*"
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[3]}" = "London" ]

    ## search index by geospatial field returning only a single field
    run redis-cli FT.SEARCH rSerBase_06 "@location:[0 51.5 50 km]" RETURN 1 name
    [ "$status" -eq 0 ]
    [ "${lines[4]}" = "London" ]

    ## search index by geospatial and text field returning only a single field
    run redis-cli FT.SEARCH rSerBase_06 "@name:Van* @location:[-120 50 500 km]" RETURN 1 name
    [ "$status" -eq 0 ]
    [ "${lines[4]}" = "Vancouver" ]

    ## remove index
    run redis-cli FT.DROP rSerBase_02
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
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
