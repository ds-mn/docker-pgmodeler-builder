#!/bin/bash -ex

docker build . -t pgm-builder
docker volume create pgm-vol
docker run --name pgm-build --rm -v pgm-vol:/opt/pgmodeler pgm-builder $1 $2
mkdir -p output
docker run --name pgm-copy --rm -v pgm-vol:/input -v "$(pwd)/output":/output ubuntu bash -c 'cd /input && tar acvf  /output/pgm-'$1'.tar.bz2 -C /input *'
docker volume rm pgm-vol