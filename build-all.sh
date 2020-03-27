#!/bin/bash -ex
BASE_TAG='mumblepins/pgmodeler-builder'
NUM_CPUS=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
BUILD_ARGS="--build-arg BASE_TAG=${BASE_TAG} --build-arg NUM_CPUS=${NUM_CPUS}"
docker build ${BUILD_ARGS} --pull -f dep-mxe.Dockerfile -t ${BASE_TAG}-dep-mxe .
docker build ${BUILD_ARGS} -f dep-libs.Dockerfile -t ${BASE_TAG}-dep-libs .
docker build ${BUILD_ARGS} -f dep-pgsql.Dockerfile -t ${BASE_TAG}-dep-pgsql .
docker build ${BUILD_ARGS} -f Dockerfile -t ${BASE_TAG} .
docker push ${BASE_TAG}
