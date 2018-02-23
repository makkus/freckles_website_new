#! /usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd -P "$THIS_DIR"

uid=`ls -ldn . | awk '{print $3}'`
gid=`ls -ldn . | awk '{print $4}'`

if [[ "$1" == "--build" ]]; then
    docker build -t "freckles:freckles_website" -f Dockerfile --build-arg GRAV_UID="$uid" --build-arg GRAV_GID="$gid" .
fi

docker run --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" -p 8280:8280 -d freckles:freckles_website
#docker run -it --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" -p 8280:8280  freckles:freckles_website /bin/bash
#docker run -it --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" --mount type=bind,source=/home/markus/projects,target=/projects -p 8280:8280  freckles:freckles_website /bin/bash
