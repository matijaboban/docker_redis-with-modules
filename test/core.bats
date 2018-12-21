#!/usr/bin/env bats

# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi


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
  run redis-cli GRAPH.QUERY MotoGP "CREATE (:Rider {name:'Valentino Rossi'})-[:rides]->(:Team {name:'Yamaha'}), (:Rider {name:'Dani Pedrosa'})-[:rides]->(:Team {name:'Honda'}), (:Rider {name:'Andrea Dovizioso'})-[:rides]->(:Team {name:'Ducati'})"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Nodes created: 6" ]
  echo "$output"
}


@test "gr2" {
  run redis-cli GRAPH.QUERY MotoGP "MATCH (r:Rider)-[:rides]->(t:Team) WHERE t.name = 'Yamaha' RETURN r,t"
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "Valentino Rossi" ]
}

@test "gr3" {
  run redis-cli GRAPH.QUERY MotoGP "MATCH (r:Rider)-[:rides]->(t:Team {name:'Ducati'}) RETURN count(r)"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "1.000000" ]
  echo "$output"
}

@test "gr4" {
  run redis-cli GRAPH.DELETE MotoGP
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Graph removed, internal execution time:" ]]
}

