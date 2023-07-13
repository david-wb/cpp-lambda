FROM public.ecr.aws/lambda/provided:al2

## install required development packages
RUN yum -y groupinstall "Development tools" 
RUN yum -y install python3 gcc-c++ libcurl-devel cmake3 git

RUN mkdir temp \
  && cd temp \
  && curl -O https://bootstrap.pypa.io/get-pip.py \
  && python3 get-pip.py \
  && pip3 install awscli \
  # Build the aws-lambda-cpp runtime
  && git clone https://github.com/awslabs/aws-lambda-cpp.git \
  && cd aws-lambda-cpp \
  && mkdir build \
  && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX=${LAMBDA_TASK_ROOT}/out \
    -DCMAKE_CXX_COMPILER=g++ \
  && make \
  && make install \
  && cd .. \
  && rm -rf temp  

# Copy source files
COPY ./ ./

RUN mkdir build \
  && cd build \
  # Compile the lambda function
  && cmake3 .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${LAMBDA_TASK_ROOT}/out \
  && make \
  # Create the zip archive
  && make aws-lambda-package-hello \
  # Extract the binaries from the zip archive to where the lambda/provided image expects them to be.
  && unzip hello.zip -d ${LAMBDA_TASK_ROOT} \
  && chmod +x ${LAMBDA_TASK_ROOT}/bootstrap \
  && mv ${LAMBDA_TASK_ROOT}/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

# Set CMD to the path to the lambda function binary. This argument is passed to the `boostrap` entrypiont script.
CMD ["bin/hello"]
