cmake_minimum_required(VERSION 3.10)
project(myfunc)

# Указываем стандарт C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)



find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
find_package(absl REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)
find_library(UV_LIB libuWS.a)

include_directories(/usr/local/include)
link_directories(/usr/local/lib)

message(STATUS "Abseil version: ${absl_VERSION}")
message(STATUS "Protobuf version: ${Protobuf_VERSION}")
message(STATUS "gRPC version: ${gRPC_VERSION}")

include(FetchContent)

FetchContent_Declare(json
    GIT_REPOSITORY https://github.com/nlohmann/json
    GIT_TAG v3.12.0
)
FetchContent_MakeAvailable(json)

add_executable(myfunc main.cpp)
target_include_directories(myfunc PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}
)



add_subdirectory(part)

# Добавляем исполняемый файл

target_link_libraries(myfunc PRIVATE
        gRPC::grpc++
        protobuf::libprotobuf
        absl::log_internal_check_op
        absl::base
        absl::strings
        absl::status
        nlohmann_json::nlohmann_json
        ${UV_LIB}
		part
)
