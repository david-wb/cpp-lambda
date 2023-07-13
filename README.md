
# How to create a C++ AWS Lambda Function

This guide describes how to create a docker-based C++ AWS Lambda function. It also explains how to create the same function using a zip archive.

## The Dockerfile

Please see the contents of `Dockerfile`. Here is a summary of how it works.

* Inherits from `public.ecr.aws/lambda/provided:al2` image which is based on Amazon Linux 2.
* Clones and compiles the [aws-lambda-cpp](https://github.com/awslabs/aws-lambda-cpp) which provides the AWS Lambda runtime library for C++.
* Compiles the lambda function C++ code, linking it to the `aws-lambda-cpp` runtime.
* Packages a zip archive which may be used to deploy the lambda.

## Build the Lambda Docker Image

Run the following script to build the docker image for the lambda.

```bash
./scripts/build-lambda-image.sh
```

## Test Locally
Start the container:
```
docker run -p 9000:8080 cpp-lambda:latest
```

Invoke the lambda:
```
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

# Deploy to AWS

## Create an ECR Repo

```bash
aws ecr create-repository \
  --repository-name cpp-lambda \
  --image-scanning-configuration scanOnPush=true \
  --image-tag-mutability MUTABLE
```

## Tag the Image
```
docker tag cpp-lambda:latest 356166239834.dkr.ecr.us-east-1.amazonaws.com/cpp-lambda:latest
```


## AWS Docker Login
```
aws ecr get-login-password --region us-east-1 --profile personal | docker login --username AWS --password-stdin 356166239834.dkr.ecr.us-east-1.amazonaws.com
```

## Push the Image

```
docker push 356166239834.dkr.ecr.us-east-1.amazonaws.com/cpp-lambda:latest
```

# Create Lambda IAM Role
```
aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' --profile personal
```

# Attach Role Policy
```
aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --profile personal
```

# Create Function
```bash
aws lambda create-function \
  --function-name cpp-lambda \
  --package-type Image \
  --code ImageUri=356166239834.dkr.ecr.us-east-1.amazonaws.com/cpp-lambda:latest \
  --role arn:aws:iam::356166239834:role/lambda-ex \
  --profile personal
```

# And Invoke
```
aws lambda invoke --function-name cpp-lambda --profile personal response.json
```