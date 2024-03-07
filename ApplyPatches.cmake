function(apply_patches ARG_REPO)
    set(oneValueArgs)
    set(options VERBOSE)
    set(multiValueArgs PATCHES)
    cmake_parse_arguments(ARG
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})
    if (NOT ARG_REPO)
        message(FATAL_ERROR "REPO argument is required")
    endif()
    if (NOT ARG_PATCHES)
        message(FATAL_ERROR "PATCHES argument is required")
    endif()
    find_package(Git)
    if(NOT GIT_FOUND)
        message(FATAL_ERROR "Git executable is required to apply patches")
    endif()
    if(ARG_VERBOSE)
        set(VERBOSE --verbose)
    endif()
    message(STATUS "Applying patches to ${ARG_REPO}:")
    foreach(PATCH ${ARG_PATCHES})
        message(" => ${PATCH}")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} apply 
                ${VERBOSE} 
                --reverse --check 
                ${PATCH}
            WORKING_DIRECTORY ${ARG_REPO}
            RESULT_VARIABLE CHECK_RESULT
        )
        if (NOT CHECK_RESULT EQUAL "0")
            execute_process(
                COMMAND ${GIT_EXECUTABLE} apply ${VERBOSE} ${PATCH}
                WORKING_DIRECTORY ${ARG_REPO}
                RESULT_VARIABLE PATCH_RESULT
                ERROR_VARIABLE PATCH_ERR
            )
            if (NOT PATCH_RESULT EQUAL "0")
                message(FATAL_ERROR "git apply ${PATCH} (inside ${ARG_REPO}) \
                    failed with ${PATCH_RESULT} => ${PATCH_ERR}")
            endif()
        endif()
    endforeach()
endfunction()