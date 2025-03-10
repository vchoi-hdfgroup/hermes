function(gcc_hermes exec tag_name tags conf async)
  set(TEST_NAME Test${exec}_${tag_name}_${async})
  add_test(NAME ${TEST_NAME}
    COMMAND "${CMAKE_BINARY_DIR}/bin/${exec}" ${tags} --reporter compact -d yes)
  set_property(TEST ${TEST_NAME}
    PROPERTY ENVIRONMENT HERMES_CONF=${CMAKE_SOURCE_DIR}/adapter/test/data/${conf}.conf)
  set_property(TEST ${TEST_NAME} APPEND
    PROPERTY ENVIRONMENT LSAN_OPTIONS=suppressions=${CMAKE_SOURCE_DIR}/test/data/asan.supp)

  if ("${async}" STREQUAL "async")
    set_property(TEST ${TEST_NAME} APPEND PROPERTY ENVIRONMENT HERMES_ASYNC_FLUSH=1)
  endif()
endfunction()

function(gcc_hermes_mode exec tag_name tags mode path)
    set(test_name Test${exec}_${tag_name}_${mode}_${path})
    add_test(NAME ${test_name} COMMAND "${CMAKE_BINARY_DIR}/bin/${exec}" ${tags} --reporter compact -d yes)
    set_property(TEST ${test_name}
            PROPERTY ENVIRONMENT HERMES_CONF=${CMAKE_SOURCE_DIR}/adapter/test/data/hermes.conf)
    set_property(TEST ${test_name} APPEND
            PROPERTY ENVIRONMENT LSAN_OPTIONS=suppressions=${CMAKE_SOURCE_DIR}/test/data/asan.supp)
    set_property(TEST ${test_name} APPEND
            PROPERTY ENVIRONMENT ADAPTER_MODE=${mode})
    set_property(TEST ${test_name} APPEND
            PROPERTY ENVIRONMENT SET_PATH=${path})
endfunction()

#------------------------------------------------------------------------------
# STDIO Adapter Internal tests
#------------------------------------------------------------------------------
add_executable(stdio_adapter_mapper_test stdio_adapter_mapper_test.cpp ${ADAPTER_COMMON})
target_link_libraries(stdio_adapter_mapper_test hermes_stdio)
add_dependencies(stdio_adapter_mapper_test hermes_stdio)
gcc(stdio_adapter_mapper_test "")

#------------------------------------------------------------------------------
# STDIO Adapter End to End tests
#------------------------------------------------------------------------------
add_executable(stdio_adapter_test stdio_adapter_test.cpp ${ADAPTER_COMMON})
gcc(stdio_adapter_test "")

add_executable(stdio_adapter_mpi_test stdio_adapter_mpi_test.cpp ${ADAPTER_COMMON})
mpi(stdio_adapter_mpi_test 2 "")

add_executable(hermes_stdio_adapter_test stdio_adapter_test.cpp ${ADAPTER_COMMON})
target_link_libraries(hermes_stdio_adapter_test hermes_stdio)
add_dependencies(hermes_stdio_adapter_test hermes_stdio hermes_daemon)
set_target_properties(hermes_stdio_adapter_test PROPERTIES COMPILE_FLAGS "-DHERMES_INTERCEPT=1")
gcc_hermes(hermes_stdio_adapter_test "" "~[request_size=range-large]" hermes "")
gcc_hermes(hermes_stdio_adapter_test "large" "[request_size=range-large]" hermes "")
gcc_hermes(hermes_stdio_adapter_test "" "~[request_size=range-large]" hermes async)
gcc_hermes(hermes_stdio_adapter_test "large" "[request_size=range-large]" hermes async)

add_executable(hermes_stdio_low_buf_adapter_test stdio_adapter_low_buffer_space_test.cpp ${ADAPTER_COMMON})
target_link_libraries(hermes_stdio_low_buf_adapter_test hermes_stdio)
add_dependencies(hermes_stdio_low_buf_adapter_test hermes_stdio hermes_daemon)
set_target_properties(hermes_stdio_low_buf_adapter_test PROPERTIES COMPILE_FLAGS "-DHERMES_INTERCEPT=1")
gcc_hermes(hermes_stdio_low_buf_adapter_test "" "" hermes_small "")
gcc_hermes(hermes_stdio_low_buf_adapter_test "" "" hermes_small async)

add_executable(hermes_stdio_adapter_mode_test stdio_adapter_mode_test.cpp ${ADAPTER_COMMON})
target_link_libraries(hermes_stdio_adapter_mode_test hermes_stdio)
add_dependencies(hermes_stdio_adapter_mode_test hermes_stdio hermes_daemon)
set_target_properties(hermes_stdio_adapter_mode_test PROPERTIES COMPILE_FLAGS "-DHERMES_INTERCEPT=1")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "persistent" "[hermes_mode=persistent]" "DEFAULT" "0")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "scratch" "[hermes_mode=scratch]" "SCRATCH" "0")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "bypass" "[hermes_mode=bypass]" "BYPASS" "0")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "persistent" "[hermes_mode=persistent]" "DEFAULT" "1")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "scratch" "[hermes_mode=scratch]" "SCRATCH" "1")
gcc_hermes_mode(hermes_stdio_adapter_mode_test "bypass" "[hermes_mode=bypass]" "BYPASS" "1")

add_executable(hermes_stdio_adapter_mpi_test stdio_adapter_mpi_test.cpp ${ADAPTER_COMMON})
target_link_libraries(hermes_stdio_adapter_mpi_test hermes_stdio)
add_dependencies(hermes_stdio_adapter_mpi_test hermes_stdio hermes_daemon)
set_target_properties(hermes_stdio_adapter_mpi_test PROPERTIES COMPILE_FLAGS "-DHERMES_INTERCEPT=1")
mpi_daemon(hermes_stdio_adapter_mpi_test 2 "~[request_size=range-large]" "" 1)
mpi_daemon(hermes_stdio_adapter_mpi_test 2 "[request_size=range-large]" "large" 1)

add_executable(adapter_utils_test adapter_utils_test.cc ${ADAPTER_COMMON})
target_link_libraries(adapter_utils_test hermes_stdio)
add_dependencies(adapter_utils_test hermes_stdio)
gcc(adapter_utils_test "")

set(STDIO_TESTS
  stdio_adapter_mapper_test
  stdio_adapter_test
  hermes_stdio_adapter_test
  hermes_stdio_low_buf_adapter_test
  hermes_stdio_adapter_mode_test
  stdio_adapter_mpi_test
  hermes_stdio_adapter_mpi_test
  adapter_utils_test
)

foreach(program ${STDIO_TESTS})
  target_include_directories(${program} PRIVATE ${HERMES_ADAPTER_DIR})
  target_include_directories(${program} PRIVATE ${HERMES_ADAPTER_TEST_DIR})
  target_link_libraries(${program} Catch2::Catch2 -lstdc++fs -lc MPI::MPI_CXX)
endforeach()

if(HERMES_INSTALL_TESTS)
    foreach(program ${STDIO_TESTS})
        install(
                TARGETS
                ${program}
                LIBRARY DESTINATION ${HERMES_INSTALL_LIB_DIR}
                ARCHIVE DESTINATION ${HERMES_INSTALL_LIB_DIR}
                RUNTIME DESTINATION ${HERMES_INSTALL_BIN_DIR}
        )
    endforeach()
endif()
