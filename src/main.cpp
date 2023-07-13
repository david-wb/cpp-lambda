// main.cpp
#include <aws/lambda-runtime/runtime.h>

using namespace aws::lambda_runtime;

invocation_response my_handler(invocation_request const& request)
{
   return invocation_response::success("{ \"message\": \"Hello World!\" }", "application/json");
}

int main()
{
   run_handler(my_handler);
   return 0;
}