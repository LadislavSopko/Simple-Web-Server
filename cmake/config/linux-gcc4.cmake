
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
# gcc 4.x.x on Linux, generating 32-bit or 64-bit binaries.
#--------------------------------------------------------------------------------------------------

set (platform "linux-gcc4")


#--------------------------------------------------------------------------------------------------
# Preprocessor definitions.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (preprocessor_definitions_common
    HW_UNIX
    NO_DEFINES
    FULLCAST
	GCC_LIN
	GCC
	GCC_LIN2
	BOOST_ALL_NO_LIB
	BOOST_ALL_DYN_LINK
	BOOST_CHRONO_HEADER_ONLY
	#XW_DEBUG_PERFORMANCE_COUNTING
	XW_LITTLEENDIAN
	_CRT_SECURE_NO_WARNINGS
	_CRT_NONSTDC_NO_DEPRECATE
	_SCL_SECURE_NO_WARNINGS
	XML_USE_MD_MEMORY
)

# Debug configuration.
set (preprocessor_definitions_debug
)

# Release configuration.
set (preprocessor_definitions_release
)


#--------------------------------------------------------------------------------------------------
# Compilation/Linking Flags.
#--------------------------------------------------------------------------------------------------

# All configurations.
set (compiler_flags_common
	-std=c++11
	-fPIC
	#-Werror                                 # Treat Warnings As Errors
)

if(XW_BUILD_PERSERVE_FRAME_POINTER)
    set (compiler_flags_common
        ${compiler_flags_common}
        -fno-omit-frame-pointer                  # profiling per avere stack pointers
    )
endif(XW_BUILD_PERSERVE_FRAME_POINTER)

set (exe_linker_flags_common
    #-Werror                                 # Treat Warnings As Errors
)
set (shared_lib_linker_flags_common
    #-Werror                                 # Treat Warnings As Errors
)

# Debug configuration.

# Release configuration.
set (compiler_flags_release
#    -O3                                     # Maximum optimization
#Since -O2 and higher sets _FORTIFY_SOURCE=2 by default, and it clashes with some code tricks we used, we have to
#undefine the preprocessor definition and define it again with the level we can afford, that is 1.
    -U_FORTIFY_SOURCE
    -D_FORTIFY_SOURCE=1
    -g
)

# Ship configuration.

# Profile configuration.


#--------------------------------------------------------------------------------------------------
# Static libraries.
#--------------------------------------------------------------------------------------------------

macro (link_against_platform target)
    if("${target}" STREQUAL "xwee")
        target_link_libraries (${target} PRIVATE
         -lrt 
    #        -lpthread
    #        -licuuc
        )
    else()
        target_link_libraries (${target}
         -lrt
    #        -lpthread
    #        -licuuc
        )
    endif()
    
endmacro ()

macro (link_against_openexr target)
    if (USE_EXTERNAL_ALEMBIC)
		target_link_libraries (${target} ${IMATH_LIBRARIES} ${OPENEXR_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libHalf.a
            ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIex.a
            ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIlmImf.a
            ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libIlmThread.a
            ${CMAKE_SOURCE_DIR}/../build/${platform}/openexr/libImath.a
        )
    endif ()
endmacro ()

macro (link_against_zlib target)
    if (USE_EXTERNAL_ALEMBIC)
		target_link_libraries (${target} ${ZLIB_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/zlib/libz.a
        )
    endif ()
endmacro ()

macro (link_against_libpng target)
    if (USE_EXTERNAL_PNG)
		target_link_libraries (${target} ${PNG_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/libpng/libpng.a
)
    endif ()
endmacro ()

macro (link_against_xercesc target)
    if (USE_EXTERNAL_XERCES)
		target_link_libraries (${target} ${XERCES_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/xerces-c/libxerces-c.a
        )
    endif ()
endmacro ()

macro (link_against_hdf5 target)
    if (USE_EXTERNAL_ALEMBIC)
		target_link_libraries (${target} ${HDF5_LIBRARIES} ${HDF5_HL_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/libhdf5.a
            ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/libhdf5_hl.a
        )
    endif ()
endmacro ()

macro (link_against_alembic target)
    if (USE_EXTERNAL_ALEMBIC)
		target_link_libraries (${target} ${ALEMBIC_LIBRARIES})
    else ()
        target_link_libraries (${target}
            ${CMAKE_SOURCE_DIR}/../build/${platform}/alembic/libalembic.a
        )
    endif ()
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