#!/usr/bin/env bats

# load fixtures/setup
load test_helper

## RediSearch
@test "rSerBase_01 - Create simple index" {
    # Set test index name
    index_name=$(generate_key rSerBase_01)

    ## create index
    run redis-cli FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run redis-cli FT.INFO $index_name
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "$index_name" ]

    ## remove index
    run redis-cli FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}

@test "rSerBase_02 - Create simple index and add entry" {
    # Set test index name
    index_name=$(generate_key rSerBase_02)

    ## create index
    run redis-cli FT.CREATE $index_name SCHEMA title TEXT WEIGHT 5.0 body TEXT url TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## add entry
    run redis-cli FT.ADD $index_name doc1 1.0 FIELDS title "hello world" body "lorem ipsum" url "http://matijaboban.com"
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    ## search index returning only a single field
    run redis-cli FT.SEARCH $index_name "hello world" LIMIT 0 10 RETURN 1 url
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[3]}" = "http://matijaboban.com" ]

    ## remove index
    run redis-cli FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}

@test "rSerBase_06 - Create simple geo index and add entry" {
    # Set test index name
    index_name=$(generate_key rSerBase_06)

    ## create index
    run redis-cli FT.CREATE $index_name SCHEMA name TEXT WEIGHT 5.0 location GEO
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## add entry(s)
    run redis-cli FT.ADD $index_name 1 1 FIELDS name "Monterrey" location -100.4431802,25.6490376
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    run redis-cli FT.ADD $index_name 2 1 FIELDS name "Vancouver" location -123.1207,49.2827
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    run redis-cli FT.ADD $index_name 3 1 FIELDS name "London" location -0.1278,51.5074
    [ "$status" -eq 0 ]
    [ "$output" = "OK" ]

    ## get index content without filters
    run redis-cli FT.SEARCH $index_name "*"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" -eq 3 ] ## check number of expected returns

    ## search index by single field
    run redis-cli FT.SEARCH $index_name "@name:Lo*"
    [ "$status" -eq 0 ]
    [ "${lines[3]}" == "London" ]

    ## search index by geospatial field returning only a single field
    run redis-cli FT.SEARCH $index_name "@location:[0 51.5 50 km]" RETURN 1 name
    [ "$status" -eq 0 ]
    echo $output
    [ "${lines[3]}" == "London" ]

    ## search index by geospatial and text field returning only a single field
    run redis-cli FT.SEARCH $index_name "@name:Van* @location:[-120 50 500 km]" RETURN 1 name
    [ "$status" -eq 0 ]
    [ "${lines[3]}" == "Vancouver" ]

    ## remove index
    run redis-cli FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}


## Autosuggest
@test "rSerAutoSug_03 - Calling autosuggest on an non-existing index" {
    # Set test index name
    index_name=$(generate_key rSerAutoSug_03)

    run redis-cli FT.SUGGET $index_name item
    [ "$status" -eq 0 ]
    [ "$output" == '' ]
}

@test "rSerAutoSug_04 - Calling autosuggest with payload on an non-existing index" {
    # Set test index name
    index_name=$(generate_key rSerAutoSug_04)

    run redis-cli FT.SUGGET $index_name item WITHPAYLOADS
    [ "$status" -eq 0 ]
    [ "$output" == '' ]
}

@test "rSerAutoSug_05 - Calling autosuggest with payload on an empty index" {
    # Set test index name
    index_name=$(generate_key rSerAutoSug_05)

    ## create index
    run redis-cli FT.CREATE $index_name SCHEMA name TEXT
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    run redis-cli FT.SUGGET $index_name item WITHPAYLOADS
    [ "$status" -eq 0 ]
    [ "$output" == '' ]

    ## remove index
    run redis-cli FT.DROP $index_name
    [ "$status" -eq 0 ]
    [ "$output" == OK ]
}
