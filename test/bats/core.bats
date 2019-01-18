#!/usr/bin/env bats

# load fixtures/setup
load test_helper


## ReJson
@test "rRson_01 - Create json set" {
    # Set test index name
    index_name=$(generate_key rJson_01)
    command_base=$(base_cli)

    ## create key
    run $command_base JSON.SET $index_name . '{"name":"Leonard Cohen","lastSeen":1478476800,"loggedOut":true}'
    [ "$status" -eq 0 ]
    [ "$output" == OK ]

    ## check
    run $command_base JSON.GET $index_name loggedOut
    [ "$status" -eq 0 ]
    [ "$output" = "true" ]
}

## Bloom
@test "bf1" {
  run redis-cli BF.MADD keytype-bloom foo bar test-key_01 test-key_02 test-key_03
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "1" ]
}

@test "bf2" {
  run redis-cli BF.EXISTS keytype-bloom test-key_01
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

@test "bf3" {
  run redis-cli BF.EXISTS keytype-bloom test-key_04
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

## Graph
@test "gr1" {
  run redis-cli GRAPH.QUERY keytype-graph "CREATE (:Rider {name:'Valentino Rossi'})-[:rides]->(:Team {name:'Yamaha'}), (:Rider {name:'Dani Pedrosa'})-[:rides]->(:Team {name:'Honda'}), (:Rider {name:'Andrea Dovizioso'})-[:rides]->(:Team {name:'Ducati'})"
  [ "$status" -eq 0 ]
  echo "$output"
  [[ "$output" =~  "Nodes created: 6" ]]
}

@test "gr2" {
  run redis-cli GRAPH.QUERY keytype-graph "MATCH (r:Rider)-[:rides]->(t:Team) WHERE t.name = 'Yamaha' RETURN r,t"
  [ "$status" -eq 0 ]
  echo "$output"
  [ "${lines[2]}" = "Valentino Rossi" ]
}

@test "gr3" {
  run redis-cli GRAPH.QUERY keytype-graph "MATCH (r:Rider)-[:rides]->(t:Team {name:'Ducati'}) RETURN count(r)"
  [ "$status" -eq 0 ]
  echo "$output"
  [ "${lines[1]}" = "1.000000" ]
}

@test "gr4" {
  run redis-cli GRAPH.DELETE keytype-graph
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Graph removed, internal execution time:" ]]
}

