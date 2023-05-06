# Example 
# Compile test/test.cc with most recent version of std for C++
cmake_minimum_required(VERSION 3.14)
project(BENCHMARK_STANDARDS CXX)
include(build_standards.cmake)

add_executable_with_all_std_versions(6 test tests/test.cc)
add_benchmark(test)
