#!/bin/bash

set -eo pipefail

DIR="$(cd $(dirname ${0}); pwd)"
cd $DIR/..

docker build -t cpp-lambda:latest -f Dockerfile .
id=$(docker create cpp-lambda:latest)
docker cp $id:/var/task/build/hello.zip .
docker rm -v $id
