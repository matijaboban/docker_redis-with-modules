#!/usr/bin/env bats

# load fixtures/setup
load test_helper

## tests setup
setup()
{
    command_base=$(base_cli)
}

## ReJson
@test "rGraph_01 - Create base graph set" {
    # Set test index name
    index_name=$(generate_key rGraph_01)

    ## create entry
    run $command_base GRAPH.QUERY keytype-graph "CREATE (:Rider {name:'Valentino Rossi'})-[:rides]->(:Team {name:'Yamaha'}), (:Rider {name:'Dani Pedrosa'})-[:rides]->(:Team {name:'Honda'}), (:Rider {name:'Andrea Dovizioso'})-[:rides]->(:Team {name:'Ducati'})"
    [ "$status" -eq 0 ]
    echo "$output"
    [[ "$output" =~  "Nodes created: 6" ]]

    ## query returning result set
    run $command_base GRAPH.QUERY keytype-graph "MATCH (r:Rider)-[:rides]->(t:Team) WHERE t.name = 'Yamaha' RETURN r,t"
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[2]}" = "Valentino Rossi" ]

    ## query returning result count
    run $command_base GRAPH.QUERY keytype-graph "MATCH (r:Rider)-[:rides]->(t:Team {name:'Ducati'}) RETURN count(r)"
    [ "$status" -eq 0 ]
    echo "$output"
    [ "${lines[1]}" = "1.000000" ]

    ## remove graph
    run $command_base GRAPH.DELETE keytype-graph
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Graph removed, internal execution time:" ]]
}
