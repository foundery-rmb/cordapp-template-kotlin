#!/bin/sh
set -e

RUN_CORDA="#!/bin/bash

# If variable not present use default values
CORDA_HOME=\${CORDA_HOME:-'/opt/corda'}
JAVA_OPTIONS=\${JAVA_OPTIONS:-'-Xmx512m'}

cd \${CORDA_HOME}
java \${JAVA_OPTIONS} -jar \${CORDA_HOME}/corda.jar 2>&1"

DOCKER_COMPOSE="version: '3'
services:"

echo "Building Docker nodes..."
./gradlew clean prepareDockerNodes

echo "Building Docker images..."
for f in $(find build/nodes/ -name Dockerfile)
do
    echo "Building for $f..."
    # Make sure we're using the latest version of the JRE we can get hold of
    cat $f | \
        sed 's/FROM openjdk:8u151-jre-alpine/FROM openjdk:8u171-jre-alpine/g' > "$f.new"
    # Extract the node name
    node_name=`echo $f | cut -d "/" -f 3`
    image_name=`echo $node_name | tr '[:upper:]' '[:lower:]'`
    echo "${RUN_CORDA}" > "build/nodes/${node_name}/run-corda.sh"
    docker build --build-arg BUILDTIME_CORDA_VERSION="3.3" \
        -f $f.new \
        -t "foundery.azurecr.io/foundery/corda-test-${image_name}:latest" \
        "build/nodes/${node_name}/"
    DOCKER_COMPOSE="${DOCKER_COMPOSE}\n  ${image_name}:\n    build: ${node_name}/Dockerfile.new\n    ports: [10003]\n    command: ['/bin/bash', '/run-corda.sh']"
done

echo "${DOCKER_COMPOSE}" > build/nodes/docker-compose.yml

