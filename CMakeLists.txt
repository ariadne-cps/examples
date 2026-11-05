cmake_minimum_required(VERSION 3.15)
project(AriadneExamples LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_PYTHON_BINDINGS "Build optional Ariadne Python bindings" OFF)

# CI and the root build link the examples directly to the in-tree Ariadne.
add_subdirectory(ss/ard)
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/ExamplesSupport.cmake")
add_subdirectory(evolution)
