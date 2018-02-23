#! /usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$THIS_DIR"

docker build -t "makkus:freckles_website" .
docker run -it --mount type=bind,source="$THIS_DIR",target="/var/lib/freckles/freckles_website" -p 8280:8280  makkus:freckles_website /bin/bash

