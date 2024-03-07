function(update_submodules)
    set(oneValueArgs REPO)
    set(options FULL_CLONE)
    set(multiValueArgs)
    cmake_parse_arguments(ARG
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})
    find_package(Git)
    if (NOT ARG_REPO)
        set(ARG_REPO ${CMAKE_CURRENT_LIST_DIR}/.)
    endif()
    if (NOT GIT_FOUND)
        message(FATAL_ERROR "Cannot update submodules in ${ARG_REPO}: Git executable not found")
    endif()
    if (NOT EXISTS "${ARG_REPO}/.git")
        message(FATAL_ERROR "Cannot update submodules in ${ARG_REPO}: Is not a repository")
    endif()
    if (NOT ARG_FULL_CLONE)
        set(DEPTH --depth=1)
    endif()
    message(STATUS "Submodules updating in ${ARG_REPO}...")
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive ${DEPTH}
                    WORKING_DIRECTORY ${ARG_REPO}
                    RESULT_VARIABLE GIT_SUBMODULE_RESULT
                    ERROR_VARIABLE GIT_SUBMODULE_ERR)
    if(NOT GIT_SUBMODULE_RESULT EQUAL "0")
        message(FATAL_ERROR
            "git submodule update --init --recursive failed with \
            ${GIT_SUBMODULE_RESULT} =>  ${GIT_SUBMODULE_ERR}")
    endif()
    message(STATUS "Submodule update successed.")
endfunction()
