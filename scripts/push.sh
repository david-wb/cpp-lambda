#!/bin/bash

set -eo pipefail

DIR="$(cd $(dirname ${0}); pwd)"
cd $DIR/..

aws ecr get-login-password --region us-east-1 --profile personal | docker login --username AWS --password-stdin 356166239834.dkr.ecr.us-east-1.amazonaws.com
./build-image.sh
docker tag cpp-lambda:latest 356166239834.dkr.ecr.us-east-1.amazonaws.com/cpp-lambda:latest
docker push 356166239834.dkr.ecr.us-east-1.amazonaws.com/cpp-lambda:latest
