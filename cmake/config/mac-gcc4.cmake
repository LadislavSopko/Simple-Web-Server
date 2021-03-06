
#
# This source file is part of appleseed.
# Visit http://appleseedhq.net/ for additional information and resources.
#
# This software is released under the MIT license.
#
# Copyright (c) 2010-2012 Francois Beaune, Jupiter Jazz Limited
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#


#--------------------------------------------------------------------------------------------------
# gcc 4.x.x on Mac OS X, generating 32-bit or 64-bit binaries.
#--------------------------------------------------------------------------------------------------

set (platform "mac-gcc4")


#--------------------------------------------------------------------------------------------------
# Tools.
#--------------------------------------------------------------------------------------------------

set (git_command "git")


#--------------------------------------------------------------------------------------------------
# Preprocessor definitions.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (preprocessor_definitions_common
)

# Debug configuration.
set (preprocessor_definitions_debug
)

# Release configuration.
set (preprocessor_definitions_release
)


#--------------------------------------------------------------------------------------------------
# Compilation/linking flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
    -Werror                                 # Treat Warnings As Errors
)
set (exe_linker_flags_common
    -Werror                                 # Treat Warnings As Errors
    -bind_at_load
)
set (shared_lib_linker_flags_common
    -Werror                                 # Treat Warnings As Errors
)

# Debug configuration.

# Release configuration.
set (compiler_flags_release
    -O3                                     # Maximum optimization
)

# Ship configuration.

# Profile configuration.


#--------------------------------------------------------------------------------------------------
# Static libraries.
#--------------------------------------------------------------------------------------------------

macro (link_against_platform target)
    set_target_properties (${target} PROPERTIES
        LINK_FLAGS "-framework Cocoa -lcurl"
    )
endmacro ()

macro (link_against_openexr target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libHalf.a
        ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIex.a
        ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIlmImf.a
        ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIlmThread.a
        ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libImath.a
    )
endmacro ()

macro (link_against_zlib target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/zlib/libz.a
    )
endmacro ()

macro (link_against_libpng target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/libpng/libpng.a
    )
endmacro ()

macro (link_against_xercesc target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/xerces-c/libxerces-c.a
    )
endmacro ()

macro (link_against_hdf5 target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/libhdf5.a
        ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/libhdf5_hl.a
    )
endmacro ()

macro (link_against_alembic target)
    target_link_libraries (${target}
        ${CMAKE_SOURCE_DIR}/../build/${platform}/alembic/libalembic.a
    )
endmacro ()


#--------------------------------------------------------------------------------------------------
# Copy a target binary to the sandbox.
#--------------------------------------------------------------------------------------------------

macro (get_sandbox_bin_path path)
    set (${path} ${PROJECT_SOURCE_DIR}/../sandbox/bin/${CMAKE_BUILD_TYPE}/)
endmacro ()

macro (add_copy_target_to_sandbox_command target)
    get_target_property (target_path ${target} LOCATION)
    get_sandbox_bin_path (sandbox_path)

    add_custom_command (TARGET ${target} POST_BUILD
        COMMAND mkdir -p ${sandbox_path}
        COMMAND cp ${target_path} ${sandbox_path}
    )
endmacro ()