set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE
               PROPERTY STRINGS "Debug"
                                "Release"
                                "MinSizeRel"
                                "RelWithDebInfo")
endif()

if(NOT CMAKE_VERSION VERSION_LESS "3.24")
  set(CMAKE_COLOR_DIAGNOSTICS ON)
elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  if(WIN32)
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fcolor-diagnostics>
                        $<$<COMPILE_LANGUAGE:CXX>:-fcolor-diagnostics>)
  else()
    add_compile_options(-fcolor-diagnostics)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(WIN32)
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fdiagnostics-color=always>
                        $<$<COMPILE_LANGUAGE:CXX>:-fdiagnostics-color=always>)
  else()
    add_compile_options(-fdiagnostics-color=always)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION GREATER 1900)
  add_compile_options(/diagnostics:column)
else()
  message(STATUS "Can't enchant diagnostics for '${CMAKE_CXX_COMPILER_ID}' compiler.")
endif()
