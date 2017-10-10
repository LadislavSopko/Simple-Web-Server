#--------------------------------------------------------------------------------------------------
# Microsoft Visual Studio 2015 (14.0) on Windows, generating 32-bit and 64-bit binaries.
#--------------------------------------------------------------------------------------------------

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (platform "win-vs140-x64")
	
else ()
    set (platform "win-vs140-x86")
	
endif ()


#--------------------------------------------------------------------------------------------------
# Preprocessor definitions.
#--------------------------------------------------------------------------------------------------

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	
	# All configurations.
	set (preprocessor_definitions_common
		BOOST_ALL_NO_LIB
		BOOST_ALL_DYN_LINK
        BOOST_CHRONO_HEADER_ONLY
		WIN32_LEAN_AND_MEAN
		_WIN64
		_CRT_SECURE_NO_WARNINGS
		_CRT_NONSTDC_NO_DEPRECATE
		_SCL_SECURE_NO_WARNINGS
		_ENABLE_ATOMIC_ALIGNMENT_FIX
		_WIN32_WINNT=0x0501
	)
	
else()
	# All configurations.
	set (preprocessor_definitions_common
		BOOST_ALL_NO_LIB
		BOOST_ALL_DYN_LINK
		BOOST_CHRONO_HEADER_ONLY
		WIN32_LEAN_AND_MEAN
		_CRT_SECURE_NO_WARNINGS
		_CRT_NONSTDC_NO_DEPRECATE
		_SCL_SECURE_NO_WARNINGS
		_ENABLE_ATOMIC_ALIGNMENT_FIX
		_WIN32_WINNT=0x0501
	)

endif()

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
    /MP                                     # Multi-processor Compilation
    /GF                                     # Enable String Pooling
	/EHsc
)
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_common
        ${compiler_flags_common}
		/W4
		/WX-
		/Zp8
		
    )
else ()
    set (compiler_flags_common
        ${compiler_flags_common}
        /W4                                 
		/WX-
		##/Zp4                                Importat ! Must remain default which is normally 8
    )
endif ()

set (exe_linker_flags_common
    /WX										# Treat Warnings as errors
    /MAP                                    # Generate Map File
)
set (shared_lib_linker_flags_common
    ${exe_linker_flags_common}
    /OPT:NOREF
)

# Debug configuration.
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_debug
        /Zi		# set Debug Information Format to Program Database
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 -wd4503 -wd4522 -wd4459 -wd4458
    )
else ()
    set (compiler_flags_debug
        /Zi                                 # set Debug Information Format to Program Database for Edit & Continue
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4189 -wd4706 -wd4503 -wd4522 -wd4459 -wd4458
    )
endif ()

set (compiler_flags_debug
    ${compiler_flags_debug}
    /MDd                                    # set Runtime Library to Multi-threaded Debug DLL
)

# Release configuration.
set (compiler_flags_release
    /Zi                                     # set Debug Information Format to Program Database
    /Ox                                     # Full Optimization
    /Ob2                                    # set Inline Function Expansion to Any Suitable
    /Oi                                     # Enable Intrinsic Functions
    /Ot                                     # Favor Fast Code
    /Oy                                     # Omit Frame Pointers
    /MD                                     # set Runtime Library to Multi-threaded DLL
    /GS-                                    # disable runtime Buffer overruns checks see: https://msdn.microsoft.com/en-us/library/aa290051(v=vs.71).aspx
)
if (CMAKE_SIZEOF_VOID_P EQUAL 4)
    set (compiler_flags_release
        ${compiler_flags_release}
        /fp:fast                            # set Floating Point Model to Fast, in 32-bit builds only because of a bug in VS 2010:
    )                                       # http://connect.microsoft.com/VisualStudio/feedback/details/518015/nan-comparison-under-the-64-bit-compiler-is-incorrect
endif ()


# Release configuration for warnings.
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (compiler_flags_release
        ${compiler_flags_release}
        -wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4706 -wd4503 -wd4522 -wd4459 -wd4458
    )
else ()
    set (compiler_flags_release
        ${compiler_flags_release}                               # set Debug Information Format to Program Database for Edit & Continue
		-wd4820 -wd4668 -wd4121 -wd4100 -wd4640 -wd4127 -wd4710 -wd4548 -wd4480 -wd4505 -wd4201 -wd4512 -wd4706 -wd4503 -wd4522 -wd4459 -wd4458
    )
endif ()


set (exe_linker_flags_release
    /DEBUG                                  # Generate Debug Info
)
set (shared_lib_linker_flags_release
    ${exe_linker_flags_release}
)

# Ship configuration.
set (compiler_flags_ship
    /GL                                     # Enable link-time code generation
)
set (exe_linker_flags_ship
    /LTCG                                   # Use Link Time Code Generation
    /INCREMENTAL:NO                         # Disable Incremental Linking
)
set (shared_lib_linker_flags_ship
    ${exe_linker_flags_ship}
)

# Profile configuration.
set (exe_linker_flags_profile
    /DEBUG                                  # Generate Debug Info
)
set (shared_lib_linker_flags_profile
    ${exe_linker_flags_profile}
)


#--------------------------------------------------------------------------------------------------
# Static libraries.
#--------------------------------------------------------------------------------------------------

macro (link_against_platform target)
endmacro ()


macro (add_copy_target_to_sandbox_command target)
    get_sandbox_bin_path (sandbox_path)
    add_custom_command (TARGET ${target} POST_BUILD
        COMMAND if not exist ${sandbox_path} mkdir ${sandbox_path}
        COMMAND copy $(TargetPath) ${sandbox_path}
    )
endmacro ()


#macro (link_against_zlib target)
#    target_link_libraries (${target}
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/zlib/Debug/zlib.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/zlib/Release/zlib.lib
#    )
#endmacro ()
#
#macro (link_against_libpng target)
#    target_link_libraries (${target}
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/libpng/Debug/libpng.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/libpng/Release/libpng.lib
#    )
#endmacro ()

#macro (link_against_xercesc target)
#    target_link_libraries (${target}
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/xerces-c/Static\ Debug/xerces-c_static_3D.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/xerces-c/Static\ Release/xerces-c_static_3.lib
#    )
#endmacro ()
#
#macro (link_against_hdf5 target)
#    target_link_libraries (${target}
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/Debug/hdf5d.lib
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/Debug/hdf5_hld.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/Release/hdf5.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/hdf5/Release/hdf5_hl.lib
#    )
#endmacro ()
#
#macro (link_against_alembic target)
#    target_link_libraries (${target}
#        debug       ${CMAKE_SOURCE_DIR}/../build/${platform}/alembic/Debug/alembic.lib
#        optimized   ${CMAKE_SOURCE_DIR}/../build/${platform}/alembic/Release/alembic.lib
#    )
#endmacro ()


#--------------------------------------------------------------------------------------------------
# Copy a target binary to the sandbox.
#--------------------------------------------------------------------------------------------------

#macro (get_sandbox_bin_path path)
#    slashes_to_backslashes (${path} ${PROJECT_SOURCE_DIR})
#    set (${path} ${${path}}\\..\\sandbox\\bin\\$(ConfigurationName)\\)
#endmacro ()

