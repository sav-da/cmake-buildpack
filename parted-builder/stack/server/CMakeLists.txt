cmake_minimum_required(VERSION 3.10)
project(myfunc)

# Указываем стандарт C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(part)

# Добавляем исполняемый файл
add_executable(myfunc main.cpp)
target_link_libraries(myfunc PRIVATE part)
