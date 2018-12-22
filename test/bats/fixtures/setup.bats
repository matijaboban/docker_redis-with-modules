#!/usr/bin/env bats

## Generate key
## TODO: notes
key_base="keytype-search"
timestamp=$(date +%s)
random=$[RANDOM]
export redis_key=$key_base-$(date +%s)-$(($RANDOM))

# echo "load setup"
# echo $redis_key


echo "${!keytype-search-*}"

unset "${!keytype-search-*}"

echo "${!keytype-search-*}"
