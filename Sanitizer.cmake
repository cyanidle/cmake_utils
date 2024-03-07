if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU" AND NOT WIN32)
    set(SUPPORT_UBSAN ON)
else()
    set(SUPPORT_UBSAN OFF)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU" AND WIN32)
    set(SUPPORT_ASAN OFF)
else()
    set(SUPPORT_ASAN ON)
endif()

function(enable_sanitizers target_name)
    set(oneValueArgs ASAN LSAN UBSAN TSAN MSAN)
    set(options LINK_TYPE)
    set(multiValueArgs)
    cmake_parse_arguments(ARG
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})
    set(SANITIZERS "")
    if (NOT ARG_LINK_TYPE)
        set(ARG_LINK_TYPE INTERFACE)
    endif()
    if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang|GNU")
        if(ARG_ASAN)
            list(APPEND SANITIZERS "address")
        endif()

        if(ARG_LSAN)
            list(APPEND SANITIZERS "leak")
        endif()

        if(ARG_UBSAN)
            list(APPEND SANITIZERS "undefined")
        endif()

        if(ARG_TSAN)
            if(ARG_ASAN OR ARG_LSAN)
                message(WARNING "Thread sanitizer does not work with address and leak sanitizer enabled.")
            else()
                list(APPEND SANITIZERS "thread")
            endif()
        endif()

        if(ARG_MSAN AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
            message(WARNING
                  "Memory sanitizer require all the code (including libc++) to be MSAN-instrumented
                  otherwise it reports false positive.")
            if(ARG_ASAN OR ARG_LSAN OR ARG_TSAN)
                message(WARNING "Memory sanitizer does not work with address, thread or leak sanitizer enabled.")
            else()
                list(APPEND SANITIZERS "memory")
            endif()
        endif()
    elseif(MSVC)
        if(ARG_ASAN)
            list(APPEND SANITIZERS "address")
        endif()
        if(ARG_LSAN OR ARG_UBSAN OR ARG_TSAN OR ARG_MSAN)
            message(WARNING "MSVC support only address sanitizer.")
        endif()
    endif()

    list(JOIN SANITIZERS "," LIST_OF_SANITIZERS)
    message(STATUS "${target_name} applying sanitizers => ${SANITIZERS}")

    if(LIST_OF_SANITIZERS)
        if(NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
            if(NOT MSVC)
                target_compile_options(${target_name} ${ARG_LINK_TYPE} -fsanitize=${LIST_OF_SANITIZERS})
                target_link_options(${target_name} ${ARG_LINK_TYPE} -fsanitize=${LIST_OF_SANITIZERS})
            else()
                string(FIND "$ENV{PATH}" "$ENV{VSINSTALLDIR}" idx_of_vs_install_dir)
                if("${idx_of_vs_install_dir}" STREQUAL "-1")
                    message(SEND_ERROR
                        "Using MSVC sanitizers require setting the MSVC enviroment before building the project.
                        Please manualy open the MSVC command prompt and rebuild project.")
                endif()
                target_compile_options(${target_name} ${ARG_LINK_TYPE}
                    /fsanitize=${LIST_OF_SANITIZERS} /Zi /INCREMENTAL:ON)
                target_compile_definitions(${target_name} ${ARG_LINK_TYPE}
                    _DISABLE_VECTOR_ANNOTATION _DISABLE_STRING_ANNOTATION)
                target_link_options(${target_name} ${ARG_LINK_TYPE}
                    /INCREMENTAL:NO)
            endif()
        endif()
    endif()
endfunction()
