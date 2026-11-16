include_guard(GLOBAL)
find_package(Git REQUIRED)

# Bootstrap Ariadne before its own Build helpers can be included. Persist
# the observed outer Gitlink in the same worktree-local format as Build.
function(ariadne_bootstrap_checkout)
    set(_root "${CMAKE_CURRENT_SOURCE_DIR}")
    set(_path "ss/ari")
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_root}" rev-parse --git-path index
        OUTPUT_VARIABLE _index OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _error RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0 OR _index STREQUAL "")
        message(FATAL_ERROR "Cannot locate Git index for ${_root}: ${_error}")
    endif()
    if(NOT IS_ABSOLUTE "${_index}")
        get_filename_component(_index "${_index}" ABSOLUTE BASE_DIR "${_root}")
    endif()
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_index}")

    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_root}" ls-files --stage -- "${_path}"
        OUTPUT_VARIABLE _entry OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _error RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0 OR NOT _entry MATCHES "^160000 ([0-9a-fA-F]+) 0[\\t ]")
        message(FATAL_ERROR "Cannot read recorded Ariadne Gitlink: ${_error} ${_entry}")
    endif()
    set(_recorded "${CMAKE_MATCH_1}")

    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_root}" rev-parse --absolute-git-dir
        OUTPUT_VARIABLE _git_dir OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _error RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0)
        message(FATAL_ERROR "Cannot locate Git directory: ${_error}")
    endif()
    string(SHA256 _key "${_path}")
    set(_state "${_git_dir}/ariadne/observed-gitlinks/${_key}.txt")
    set(_previous "")
    if(EXISTS "${_state}")
        file(READ "${_state}" _previous)
        string(STRIP "${_previous}" _previous)
    endif()

    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_root}" submodule status -- "${_path}"
        OUTPUT_VARIABLE _status OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _error RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0 OR _status STREQUAL "")
        message(FATAL_ERROR "Cannot inspect Ariadne submodule: ${_error}")
    endif()
    if(_status MATCHES "^U")
        message(FATAL_ERROR "Ariadne Gitlink is conflicted. Resolve the index first.")
    endif()
    set(_checkout "${_root}/${_path}")
    set(_align FALSE)
    if(_status MATCHES "^-")
        set(_align TRUE)
    elseif(NOT _previous STREQUAL "" AND NOT _previous STREQUAL _recorded
           AND _status MATCHES "^\\+")
        set(_align TRUE)
    endif()

    if(_align)
        if(NOT _status MATCHES "^-")
            execute_process(
                COMMAND "${GIT_EXECUTABLE}" -C "${_checkout}"
                        status --porcelain --untracked-files=all --ignore-submodules=all
                OUTPUT_VARIABLE _dirty OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_VARIABLE _error RESULT_VARIABLE _result)
            if(NOT _result EQUAL 0)
                message(FATAL_ERROR "Cannot inspect Ariadne checkout: ${_error}")
            endif()
            if(NOT _dirty STREQUAL "")
                message(FATAL_ERROR
                    "Ariadne Gitlink changed but ${_checkout} has local changes. "
                    "Commit or stash them before configuring.")
            endif()
        endif()
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" -C "${_root}"
                    submodule update --init -- "${_path}"
            ERROR_VARIABLE _error RESULT_VARIABLE _result)
        if(NOT _result EQUAL 0)
            message(FATAL_ERROR "Cannot synchronize Ariadne submodule: ${_error}")
        endif()
        message(STATUS "Synchronized Ariadne submodule to ${_recorded}")
    endif()
    if(NOT _previous STREQUAL _recorded)
        get_filename_component(_state_dir "${_state}" DIRECTORY)
        file(MAKE_DIRECTORY "${_state_dir}")
        file(WRITE "${_state}" "${_recorded}\n")
    endif()

    # A manually selected Ariadne commit can carry new nested Gitlinks.
    # Reconfigure automatically after switching its HEAD.
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_checkout}" rev-parse --git-path HEAD
        OUTPUT_VARIABLE _head OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _error RESULT_VARIABLE _result)
    if(NOT _result EQUAL 0)
        message(FATAL_ERROR "Cannot locate Ariadne HEAD: ${_error}")
    endif()
    if(NOT IS_ABSOLUTE "${_head}")
        get_filename_component(_head "${_head}" ABSOLUTE BASE_DIR "${_checkout}")
    endif()
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_head}")
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" -C "${_checkout}" symbolic-ref -q HEAD
        OUTPUT_VARIABLE _ref OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _ref_result ERROR_QUIET)
    if(_ref_result EQUAL 0 AND NOT _ref STREQUAL "")
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" -C "${_checkout}" rev-parse --git-path "${_ref}"
            OUTPUT_VARIABLE _ref_path OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NOT IS_ABSOLUTE "${_ref_path}")
            get_filename_component(_ref_path "${_ref_path}" ABSOLUTE BASE_DIR "${_checkout}")
        endif()
        set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_ref_path}")
    endif()
endfunction()
