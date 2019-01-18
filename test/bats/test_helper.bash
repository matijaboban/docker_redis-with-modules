#!/usr/bin/env bats

# Check we're not running bash 3.x
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "Bash 4.1 or later is required to run these tests"
    exit 1
fi


## Generate key
## TODO: notes
generate_key () {
    # set default key prefix value if one is not
    # not passed as a parameter
    key_prefix=${1:-index}

    # generate UNIX epoch
    timestamp=$(date +%s)

    # generate random integer
    randnum=$[RANDOM]

    # build the key
    key=$key_prefix-$(date +%s)-$(($randnum))

    echo $key
}


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

## set base of redis interactions commands
base_cli ()
{
    echo "docker exec $docker_id redis-cli"
}
