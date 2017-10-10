cmake_minimum_required (VERSION 3.1)
set (CMAKE_BACKWARDS_COMPATIBILITY 3.1)

include (cmake/utilities.cmake)



project (Simple-Web-Server)


set ( USE_BOOST_REGEX ON CACHE BOOL "On if use boost regexp." )

#gnu 4.8 not support std::regexp
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        set(USE_BOOST_REGEX ON)
    endif()
endif()

#--------------------------------------------------------------------------------------------------
# Platform-specific settings.
#--------------------------------------------------------------------------------------------------

 
# This must come after project () otherwise CMAKE_SYSTEM_NAME is undefined.

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

	include (cmake/config/win-vs140.cmake)
	set (CMAKE_FIND_LIBRARY_SUFFIXES .lib;.dll)

elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")

	include (cmake/config/linux-gcc4.cmake)
#	set (CMAKE_FIND_LIBRARY_PREFIXES lib)
	set (CMAKE_FIND_LIBRARY_SUFFIXES .a;.so)

else ()
	message (FATAL_ERROR "Unsupported platform or compiler (CMAKE_SYSTEM_NAME is \"${CMAKE_SYSTEM_NAME}\"). "
						 "Edit ${CMAKE_CURRENT_LIST_FILE} to add support for it.")
endif ()

include_directories(.)

find_package(Threads REQUIRED)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wextra")
else()
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()


# ---------- Find Boost Headers/Libraries -----------------------
set (XW_BOOST_MAJOR_VERSION 1 )
set (XW_BOOST_MINOR_VERSION 59)
set (BOOST_ROOT ${CMAKE_INSTALL_PREFIX}/include/boost-1_59)
set (XW_BOOST_VERSION "${XW_BOOST_MAJOR_VERSION}.${XW_BOOST_MINOR_VERSION}" ) 
set (XW_BOOST_VERSION_FOR_FILE "${XW_BOOST_MAJOR_VERSION}_${XW_BOOST_MINOR_VERSION}" ) 
set(BOOST_COMPONENTS system thread filesystem date_time iostreams)
# Late 2017 TODO: remove the following checks and always use std::regex
if(USE_BOOST_REGEX)
		set(BOOST_COMPONENTS ${BOOST_COMPONENTS} regex)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_BOOST_REGEX")
endif()


# ---------- Find Boost Headers/Libraries -----------------------
SET (Boost_FIND_REQUIRED ON)
SET (Boost_FIND_QUIETLY ON)
SET (Boost_DEBUG ON)
set (Boost_USE_MULTITHREADED ON)
set (Boost_USE_STATIC_LIBS OFF)
set (Boost_USE_STATIC_RUNTIME OFF)
set (Boost_NO_SYSTEM_PATHS OFF)
set (Boost_LIBRARY_DIR ${CMAKE_INSTALL_PREFIX}/lib)

unset(Boost_INCLUDE_DIRS CACHE)
unset(Boost_LIBRARY_DIRS CACHE)

find_package(Boost ${XW_BOOST_VERSION} COMPONENTS ${BOOST_COMPONENTS}  REQUIRED)

if(Boost_FOUND)
	INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIRS})
	LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
endif()

message(status "** Boost Include: ${Boost_INCLUDE_DIR}")
message(status "** Boost Libraries: ${Boost_LIBRARY_DIRS}")
message(status "** Boost Libraries: ${Boost_LIBRARIES}")

##find_package(Boost 1.53.0 COMPONENTS ${BOOST_COMPONENTS} REQUIRED)

include_directories(SYSTEM ${Boost_INCLUDE_DIR})

#--------------------------------------------------------------------------------------------------
# Preprocessor definitions.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (preprocessor_definitions_common
    ${preprocessor_definitions_common}
)

## Conditional compiling
if(NOT XW_CONDITION_WITH_MAIL_WRITER)
set (preprocessor_definitions_common
    ${preprocessor_definitions_common}    
    __SKIP_MAIL_WRITER
)
endif()

if (CMAKE_SIZEOF_VOID_P MATCHES 4)
    set (preprocessor_definitions_common
        ${preprocessor_definitions_common}
        ARCH32
)
elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
    set (preprocessor_definitions_common
        ${preprocessor_definitions_common}
        ARCH64
)
else ()
    message (FATAL_ERROR "Cannot determine pointer size")
endif ()

# Debug configuration.
set (preprocessor_definitions_debug
    ${preprocessor_definitions_debug}
    ${preprocessor_definitions_common}
    DEBUG
    _DEBUG
)

# Release configuration.
set (preprocessor_definitions_release
    ${preprocessor_definitions_release}
    ${preprocessor_definitions_common}
    NDEBUG
)


#xw plugin package preprocessor defs
set (preprocessor_definitions_package
    XW_CLASSES_PACKAGE_DLL
)

# A convenience macro to apply the preprocessor definitions to all configurations of a given target.
macro (apply_preprocessor_definitions target)
    set_property (TARGET ${target} APPEND PROPERTY
        #  COMPILE_DEFINITIONS_DEBUG ${preprocessor_definitions_debug}
        COMPILE_DEFINITIONS $<$<CONFIG:Debug>:${preprocessor_definitions_debug}>
    )
    set_property (TARGET ${target} APPEND PROPERTY
        # COMPILE_DEFINITIONS_RELEASE ${preprocessor_definitions_release}
        COMPILE_DEFINITIONS $<$<CONFIG:Release>:${preprocessor_definitions_release}>
    )    
endmacro ()

# A convenience macro to append custom preprocessor definitions to all configurations of a given target.
macro (append_custom_preprocessor_definitions target first_definition)
    set (definitions ${first_definition} ${ARGN})
    set_property (TARGET ${target} APPEND PROPERTY
        # COMPILE_DEFINITIONS_DEBUG ${definitions}
        COMPILE_DEFINITIONS $<$<CONFIG:Debug>:${definitions}>
    )
    set_property (TARGET ${target} APPEND PROPERTY
        # COMPILE_DEFINITIONS_RELEASE ${definitions}
        COMPILE_DEFINITIONS $<$<CONFIG:Release>:${definitions}>
    )    
endmacro ()

# A convenience macro to apply the xw plugin package specific preprocessor definitions to all configurations of a given target.
macro (apply_clp_preprocessor_definitions target)
    set_property (TARGET ${target} APPEND PROPERTY
        #  COMPILE_DEFINITIONS_DEBUG ${preprocessor_definitions_debug}
        COMPILE_DEFINITIONS $<$<CONFIG:Debug>:${preprocessor_definitions_package}>
    )
    set_property (TARGET ${target} APPEND PROPERTY
        # COMPILE_DEFINITIONS_RELEASE ${preprocessor_definitions_release}
        COMPILE_DEFINITIONS $<$<CONFIG:Release>:${preprocessor_definitions_package}>
    )    
endmacro ()


#--------------------------------------------------------------------------------------------------
# Compilation/linking flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
    ${compiler_flags_common}
)
set (exe_linker_flags_common
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_common
    ${shared_lib_linker_flags_common}
)

# Debug configuration.
set (compiler_flags_debug
    ${compiler_flags_debug}
    ${compiler_flags_common}
)
set (exe_linker_flags_debug
    ${exe_linker_flags_debug}
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_debug
    ${shared_lib_linker_flags_debug}
    ${shared_lib_linker_flags_common}
)

# Release configuration.
set (compiler_flags_release
    ${compiler_flags_release}
    ${compiler_flags_common}
)
set (exe_linker_flags_release
    ${exe_linker_flags_release}
    ${exe_linker_flags_common}
)
set (shared_lib_linker_flags_release
    ${shared_lib_linker_flags_release}
    ${shared_lib_linker_flags_common}
)



# Apply Debug configuration compilation/linking flags.
convert_list_to_string (CMAKE_CXX_FLAGS_DEBUG "${compiler_flags_debug}")
convert_list_to_string (CMAKE_EXE_LINKER_FLAGS_DEBUG "${exe_linker_flags_debug}")
convert_list_to_string (CMAKE_SHARED_LINKER_FLAGS_DEBUG "${shared_lib_linker_flags_debug}")

# Apply Release configuration compilation/linking flags.
convert_list_to_string (CMAKE_CXX_FLAGS_RELEASE "${compiler_flags_release}")
convert_list_to_string (CMAKE_EXE_LINKER_FLAGS_RELEASE "${exe_linker_flags_release}")
convert_list_to_string (CMAKE_SHARED_LINKER_FLAGS_RELEASE "${shared_lib_linker_flags_release}")


if(APPLE)
    set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl")
endif()

add_executable(http_examples http_examples.cpp)
target_link_libraries(http_examples ${Boost_LIBRARIES})
target_link_libraries(http_examples ${CMAKE_THREAD_LIBS_INIT})
apply_preprocessor_definitions (http_examples)

#TODO: add requirement for version 1.0.1g (can it be done in one line?)
find_package(OpenSSL)

if(OPENSSL_FOUND)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHAVE_OPENSSL")
    target_link_libraries(http_examples ${OPENSSL_LIBRARIES})
    include_directories(SYSTEM ${OPENSSL_INCLUDE_DIR})

    add_executable(https_examples https_examples.cpp)
    target_link_libraries(https_examples ${Boost_LIBRARIES})
    target_link_libraries(https_examples ${OPENSSL_LIBRARIES})
    target_link_libraries(https_examples ${CMAKE_THREAD_LIBS_INIT})
	apply_preprocessor_definitions (https_examples)
endif()

if( "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
    target_link_libraries(http_examples ws2_32 wsock32)
    if(OPENSSL_FOUND)
        target_link_libraries(https_examples ws2_32 wsock32)
    endif()
endif()

# Removed to avoid some troubles
#enable_testing()
#add_subdirectory(tests)

install(FILES server_http.hpp client_http.hpp server_https.hpp client_https.hpp crypto.hpp utility.hpp status_code.hpp DESTINATION include/simple-web-server)
