# SPDX-FileCopyrightText: 2026 MeoArch Contributors
# SPDX-License-Identifier: BSD-2-Clause

if(NOT DEFINED PROJECT_SOURCE_DIR OR NOT DEFINED UPSTREAM_BASE)
    message(FATAL_ERROR "PROJECT_SOURCE_DIR and UPSTREAM_BASE are required")
endif()

set(policy "${PROJECT_SOURCE_DIR}/docs/MEO_FORK_POLICY.md")
set(contract "${PROJECT_SOURCE_DIR}/docs/MEO_SESSION_ENTRY_CONTRACT.md")
foreach(document IN ITEMS "${policy}" "${contract}")
    if(NOT EXISTS "${document}")
        message(FATAL_ERROR "required Meo session-entry contract is missing: ${document}")
    endif()
endforeach()

file(READ "${policy}" policy_contents)
file(READ "${contract}" contract_contents)
foreach(required_text IN ITEMS
        "v6.7.5"
        "src/auth/"
        "src/daemon/"
        "data/pam/"
        "services/"
        "data/interfaces/")
    string(FIND "${policy_contents}" "${required_text}" found_at)
    if(found_at EQUAL -1)
        message(FATAL_ERROR "fork policy no longer protects ${required_text}")
    endif()
endforeach()

set(greeter_main "${PROJECT_SOURCE_DIR}/src/frontend/greeter/qml/Main.qml")
set(greeter_login "${PROJECT_SOURCE_DIR}/src/frontend/greeter/qml/Login.qml")
set(greeter_session "${PROJECT_SOURCE_DIR}/src/frontend/greeter/qml/SessionButton.qml")
set(greeter_keyboard "${PROJECT_SOURCE_DIR}/src/frontend/greeter/qml/KeyboardButton.qml")
foreach(source IN ITEMS "${greeter_main}" "${greeter_login}" "${greeter_session}" "${greeter_keyboard}")
    if(NOT EXISTS "${source}")
        message(FATAL_ERROR "required Meo greeter visual source is missing: ${source}")
    endif()
endforeach()
file(READ "${greeter_main}" greeter_main_contents)
file(READ "${greeter_login}" greeter_login_contents)
file(READ "${greeter_session}" greeter_session_contents)
file(READ "${greeter_keyboard}" greeter_keyboard_contents)
set(greeter_visual_contents
    "${greeter_main_contents}${greeter_login_contents}${greeter_session_contents}${greeter_keyboard_contents}")
foreach(required_text IN ITEMS
        "MeoAmbientClock"
        "MeoAuthenticationSurface"
        "MeoButton"
        "GreeterState"
        "SessionManagement"
        "KeyboardButton"
        "SessionButton"
        "import MeoUI")
    string(FIND "${greeter_visual_contents}" "${required_text}" found_at)
    if(found_at EQUAL -1)
        message(FATAL_ERROR "greeter visual layer no longer preserves: ${required_text}")
    endif()
endforeach()
foreach(forbidden_text IN ITEMS
        "import Meo.System"
        "MediaController"
        "NotificationManager"
        "KWallet"
        "WeatherCache")
    string(FIND "${greeter_visual_contents}" "${forbidden_text}" found_at)
    if(NOT found_at EQUAL -1)
        message(FATAL_ERROR "greeter visual layer may not read private session data: ${forbidden_text}")
    endif()
endforeach()
foreach(required_text IN ITEMS
        "GreeterState"
        "does not expose a PasswordSync"
        "must not create a second password model"
        "KScreenLocker"
        "fallback")
    string(FIND "${contract_contents}" "${required_text}" found_at)
    if(found_at EQUAL -1)
        message(FATAL_ERROR "session-entry contract no longer records: ${required_text}")
    endif()
endforeach()

# An exported source archive has no Git metadata.  Documentation still gets
# checked above; changed-path enforcement runs whenever this is a Git checkout.
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/.git")
    return()
endif()

find_program(GIT_EXECUTABLE git)
if(NOT GIT_EXECUTABLE)
    message(FATAL_ERROR "Git is required to check the Meo fork boundary")
endif()

execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}" rev-parse --verify "${UPSTREAM_BASE}^{commit}"
    RESULT_VARIABLE base_result
    OUTPUT_QUIET
    ERROR_QUIET
)
if(NOT base_result EQUAL 0)
    message(FATAL_ERROR "upstream base ${UPSTREAM_BASE} is unavailable")
endif()

execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}" diff --name-only "${UPSTREAM_BASE}...HEAD"
    RESULT_VARIABLE diff_result
    OUTPUT_VARIABLE changed_paths
    ERROR_VARIABLE diff_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT diff_result EQUAL 0)
    message(FATAL_ERROR "could not inspect fork changes: ${diff_error}")
endif()
execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}" diff --name-only
    RESULT_VARIABLE worktree_result
    OUTPUT_VARIABLE worktree_paths
    ERROR_VARIABLE worktree_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT worktree_result EQUAL 0)
    message(FATAL_ERROR "could not inspect unstaged fork changes: ${worktree_error}")
endif()
execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}" diff --cached --name-only
    RESULT_VARIABLE index_result
    OUTPUT_VARIABLE index_paths
    ERROR_VARIABLE index_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT index_result EQUAL 0)
    message(FATAL_ERROR "could not inspect staged fork changes: ${index_error}")
endif()
execute_process(
    COMMAND "${GIT_EXECUTABLE}" -C "${PROJECT_SOURCE_DIR}" ls-files --others --exclude-standard
    RESULT_VARIABLE untracked_result
    OUTPUT_VARIABLE untracked_paths
    ERROR_VARIABLE untracked_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT untracked_result EQUAL 0)
    message(FATAL_ERROR "could not inspect untracked fork changes: ${untracked_error}")
endif()
set(changed_paths "${changed_paths}\n${worktree_paths}\n${index_paths}\n${untracked_paths}")
string(REPLACE "\n" ";" changed_paths "${changed_paths}")

set(protected_paths
    "data/pam/"
    "data/interfaces/"
    "services/"
    "src/auth/"
    "src/common/"
    "src/daemon/"
    "src/helper/"
    "src/frontend/startkde/"
)
set(allowed_paths
    ".github/workflows/fork-boundary.yml"
    "CMakeLists.txt"
    "cmake/MeoForkBoundary.cmake"
    "docs/"
    "packaging/"
    "po/zh_CN/plasma_login.po"
    "po/zh_TW/plasma_login.po"
    "src/frontend/greeter/"
    "src/frontend/kcm/"
    "tests/"
)

foreach(path IN LISTS changed_paths)
    if(path STREQUAL "")
        continue()
    endif()
    foreach(protected IN LISTS protected_paths)
        string(FIND "${path}" "${protected}" protected_at)
        if(protected_at EQUAL 0)
            message(FATAL_ERROR "Meo fork changes protected upstream security/runtime path: ${path}")
        endif()
    endforeach()

    set(is_allowed FALSE)
    foreach(allowed IN LISTS allowed_paths)
        if(path STREQUAL "${allowed}")
            set(is_allowed TRUE)
        else()
            string(FIND "${path}" "${allowed}" allowed_at)
            if(allowed_at EQUAL 0)
                set(is_allowed TRUE)
            endif()
        endif()
    endforeach()
    if(NOT is_allowed)
        message(FATAL_ERROR "Meo fork change is outside the reviewed thin-fork surface: ${path}")
    endif()
endforeach()
