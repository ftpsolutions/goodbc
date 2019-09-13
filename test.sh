#!/bin/bash

set -e -o xtrace

# Allows us to run from a relative path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${DIR}

# permit overriding the container name (for avoiding name clashes)
if [[ -z "$CONTAINER_NAME" ]]; then
    CONTAINER_NAME=`basename $PWD-test`
fi

# Make sure we clean up
function finish {
    # Remove the container when we're done
    echo "Cleaning up...."
    # Go back to original dir
    popd
}
trap finish EXIT

IMAGE_TAG=goodbc_python_test_build-${CONTAINER_NAME}

if [ -z "${SKIP_BUILD}" ]; then
    docker build --tag ${IMAGE_TAG} -f Dockerfile_test_build .
fi

DOCKER_CMD="py.test -s"
if [ "$#" -gt 0 ]; then
    echo "Using command from args"
    DOCKER_CMD=$@
fi

# Define MOUNT_WORKSPACE to mount this workspace inside the docker container
WORKSPACE_VOLUME=""
if [ ! -z "${MOUNT_WORKSPACE}" ]; then
    WORKSPACE_VOLUME="-v `pwd`:/workspace"
fi

docker run --name ${CONTAINER_NAME} --rm -it ${WORKSPACE_VOLUME} ${IMAGE_TAG} ${DOCKER_CMD}