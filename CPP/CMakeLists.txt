cmake_minimum_required(VERSION 3.21)
if (win32)
    set(CMAKE_PREFIX_PATH "C:/Qt/6.5.0/static_build_debug/lib/cmake")
endif (win32)
if (UNIX)
    set(CMAKE_PREFIX_PATH "~/dev/qt-everywhere-src-6.1.1/BUILD-STATIC/lib/cmake/")
endif (UNIX)
project(wid_lib)
nclude_directories(.)
set(GUI_SOURCES

        gui.cpp)
add_library(GUI SHARED ${GUI_SOURCES})
find_package(Qt6 REQUIRED COMPONENTS Widgets Core Gui)
target_link_libraries(GUI  PRIVATE Qt6::Widgets Qt6::Core Qt6::Gui)
set(PROJECT_SOURCES
        main.c
       )
add_executable(cqt_test ${PROJECT_SOURCES})
target_link_libraries(cqt_test PRIVATE GUI)
