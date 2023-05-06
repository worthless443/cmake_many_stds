# Compile your project with many C++ standards at once
![linux](https://github.com/worthless443/cmake_many_stds/actions/workflows/linux.yml/badge.svg)

The CMake module provides a wrapper function to `add_executable()` and adds targets with different C++xx standards, the targets are executed with decending order, hense a sorting algorithm is present within the module. Additionally, it generates a `benchmark` bash executable that compares execution speed of all the different targets built with different C++ standards.

It detects all the standards currently supported by your compiler , and builds targets based on it

## Example

```bash
$ cat CMakeLists.txt
```
```cmake
cmake_minimum_required(VERSION 3.14)
project(BENCHMARK_STANDARDS CXX)

include(build_standards.cmake)

add_executable_with_all_std_versions(6 test tests/test.cc)
add_benchmark(test)
```
(Note: the first argument to `add_executable_with_all_std_versions()` is the number of latest C++ standards to build for)

### Configuring and Building 
Build it with GCC 13
```bash
$ CXX=g++-13 cmake .
$ make 
```
Build it with Clang 

```bash
$ CXX=clang++ cmake .
$ make 
```
### Benchmarking
```bash
./benchmark
```
## Expected configure output
Configuring with GCC <13 and yet having GCC 13
```bash
$ cmake . # default compiler, most likely GCC 
-- The CXX compiler identification is GNU 12.2.1
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- The all new GCC-13 has been found on your system, but you are not using it
-- adding latest C++ standard versions for GNU(12.2.1) - C++23 - target "test"
-- adding latest C++ standard versions for GNU(12.2.1) - C++20 - target "test"
-- adding latest C++ standard versions for GNU(12.2.1) - C++17 - target "test"
-- adding latest C++ standard versions for GNU(12.2.1) - C++14 - target "test"
-- adding latest C++ standard versions for GNU(12.2.1) - C++11 - target "test"
-- added "benchmark" for "test"
-- Configuring done
-- Generating done
-- Build files have been written to: /home/aissy/c_cpp/compare_std_c++
```
