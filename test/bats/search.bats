#!/usr/bin/env bats

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
  [ "${lines[3]}" = "http://redis.io" ]
  echo "$output"
}

@test "js4" {
  run redis-cli FT.DROP keytype-search
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "js5" {
  run redis-cli FT.ADD keytype-search doc1 1.0 FIELDS title "hello world" body "lorem ipsum" url "http://redis.io"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Unknown index name" ]]
  echo "$output"
}
