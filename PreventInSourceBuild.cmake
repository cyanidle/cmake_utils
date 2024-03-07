function(prevent_in_source_build)
  get_filename_component(srcdir CMAKE_SOURCE_DIR REALPATH)
  get_filename_component(bindir CMAKE_BINARY_DIR REALPATH)
  if("${srcdir}" STREQUAL "${bindir}")
    message(FATAL_ERROR "Prevent build in source directory. Quitting configuration...")
  endif()
endfunction()

prevent_in_source_build()