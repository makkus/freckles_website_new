#! /usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$THIS_DIR"

if [[ "$1" == "--build" ]]; then
    docker build -t "freckles:freckles_website" -f Dockerfile --build-arg GRAV_UID=1000 --build-arg GRAV_GID=1000 .
fi

#docker run --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" -p 8280:8280 -d freckles:freckles_website
#docker run -it --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" -p 8280:8280  freckles:freckles_website /bin/bash
docker run -it --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/website" --mount type=bind,source=/home/markus/projects,target=/projects -p 8280:8280  freckles:freckles_website /bin/bash
