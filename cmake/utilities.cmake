#########################################################
#
#       globals 
#
########################################################

set (XW_CURRENT_TARGETS_LIST ""   CACHE INTERNAL "" FORCE)
set (XW_MS_VISUAL_STRUCTURED_SOLUTION "OFF" CACHE INTERNAL "" FORCE)


#########################################################
#
#       load libs 
#
########################################################
MACRO(load_all_cmake_files lib_dir)
  file( GLOB _all_files "${lib_dir}/*.cmake" )
  FOREACH(child ${_all_files})
      include(${child})
  ENDFOREACH()
ENDMACRO()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/libs")

load_all_cmake_files("${CMAKE_CURRENT_SOURCE_DIR}/cmake/libs")

#########################################################
#
#       overload some system functions 
#
########################################################

function(add_library _target)
    #message(STATUS "add_lib:" ${_target})
    _add_library (${_target} ${ARGN})
     set(XW_CURRENT_TARGETS_LIST ${XW_CURRENT_TARGETS_LIST} ${_target} CACHE  INTERNAL "" FORCE)
endfunction()

function(add_executable _target)
    #message(STATUS "add_exe:" ${_target})
    _add_executable (${_target} ${ARGN})
    set(XW_CURRENT_TARGETS_LIST ${XW_CURRENT_TARGETS_LIST} ${_target}  CACHE INTERNAL "" FORCE)
endfunction()


#########################################################
#
#       base macro for custom solution folder
#       this should be overloaded 
#       in custom personal cmake file
#
########################################################
macro(apply_solution_folders)
    #default is empty
    message(STATUS "Solution folders nont aplied!")
endmacro()


#########################################################
#
#       string macros 
#
########################################################

# Replace slashes by backslashes in a string.
macro (slashes_to_backslashes output input)
    string (REGEX REPLACE "/" "\\\\" ${output} ${input})
endmacro ()

# Filter a list of items using a regular expression.
macro (filter_list output_list input_list regex)
    foreach (item ${input_list})
        if (${item} MATCHES ${regex})
            list (APPEND ${output_list} ${item})
        endif ()
    endforeach ()
endmacro ()

# Convert a semicolon-separated list to a whitespace-separated string.
macro (convert_list_to_string output_string input_list)
    foreach (item ${input_list})
        if (DEFINED ${output_string})
            set (${output_string} "${${output_string}} ${item}")
        else ()
            set (${output_string} "${item}")
        endif ()
    endforeach ()
endmacro ()

# Assign a whitespace-separated string to a variable, given a list.
macro (set_to_string output_variable first_arg)
    set (arg_list ${first_arg} ${ARGN})
    convert_list_to_string (${output_variable} "${arg_list}")
endmacro ()


#########################################################
#
#       sources and modules 
#
########################################################

# add XW module to build
macro (add_module moduleName)
    if (EXISTS ${XW_ROOT}/${moduleName} AND IS_DIRECTORY ${XW_ROOT}/${moduleName})
        if(EXISTS ${XW_ROOT}/${moduleName}/CMakeLists.txt)
           add_subdirectory (${moduleName})
        endif()
    endif()
endmacro ()

#[[
#add in project tree in solution files and return them as sources for project
# @param [in/out]    all_files_list        - list of all files, it can be used for target sources list
# @param [in]        start_dir             - starting dir for scan   
# @param [in]        root_dir              - root dir against it will do relative paths  
# @param [in]        root_grp              - eventual virtual folder for visual studio
# @param [in]        dir_exclusion_regexp  - directory exclusion regexp  
# @param [in]        file_exclusion_regexp - file exclusion regexp
#]]   
function(add_sources_dir all_files_list start_dir root_dir root_grp dir_exclusion_regexp file_exclusion_regexp)
    #curent relative dir
    if ( "${root_dir}" STREQUAL "${start_dir}" )
      set(rel_dir "")
    else()
      string(REPLACE  "${root_dir}/" "" rel_dir  ${start_dir} )
      slashes_to_backslashes(rel_grp ${rel_dir})
    endif()
    #message(STATUS "grp:" ${rel_grp})
    
    set(dir_list "")
    set(file_list "")
    
    file( GLOB this_directory_all_files "${start_dir}/*" )
    FOREACH(file ${this_directory_all_files})
        if(NOT (${file} MATCHES ".*CVS.*"))
            
            if(IS_DIRECTORY ${file})
               if("${dir_exclusion_regexp}" STREQUAL "" OR NOT ("${file}" MATCHES "${dir_exclusion_regexp}"))
                   string(REPLACE  "${root_dir}/" "" rel_path  ${file} ) 
                   #message(STATUS "dir:" ${rel_path})
                   list (APPEND dir_list ${file})
               endif()
            else()
               if("${file_exclusion_regexp}" STREQUAL "" OR NOT ("${file}" MATCHES "${file_exclusion_regexp}"))
                   string(REPLACE  "${start_dir}/" "" rel_path  ${file} ) 
                   if(NOT (${rel_path} MATCHES "(.*\\.txt)"))
                       #message(STATUS "file:" ${rel_path})
                       list (APPEND file_list ${file})
                   endif()
               endif()
            endif() 
        endif()
    ENDFOREACH()
    
    #make group of files in visual project
    list(LENGTH file_list files_cnt)
    list(LENGTH dir_list dirs_cnt)
    
    if(${files_cnt} GREATER 0)
        #message(STATUS "adding in [" "${root_grp}" "]: " ${rel_grp} "->" "${file_list}")
        if("${root_grp}" STREQUAL "")
            source_group("${rel_grp}" FILES ${file_list})
        else()
            if ("${rel_grp}" STREQUAL "" )
               source_group("${root_grp}" FILES ${file_list})
            else()
               source_group("${root_grp}\\${rel_grp}" FILES ${file_list})
            endif()
        endif()        
    endif()
    
    if(${dirs_cnt} GREATER 0)
        foreach(dir ${dir_list})
            set(children_files "")
            #message(STATUS "go for:" ${dir})
            add_sources_dir(children_files ${dir} ${root_dir} "${root_grp}" "${dir_exclusion_regexp}" "${file_exclusion_regexp}")
            #message(STATUS "children:" "${children_files}")
            list(APPEND file_list ${children_files})
        endforeach()
        
    endif()
    
    set(${all_files_list} ${file_list} PARENT_SCOPE) 
    
endfunction()


MACRO(load_all_cmake_files lib_dir)
  file( GLOB _all_files "${lib_dir}/*.cmake" )
  FOREACH(child ${_all_files})
      include(${child})
  ENDFOREACH()
ENDMACRO()


#add automatically recursively projects form starting dir
MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

macro(add_all_subdirs)
   
    SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR})    
    FOREACH(subdir ${SUBDIRS})
    
         #message( STATUS "Adding dirs from : ${CMAKE_CURRENT_SOURCE_DIR}/${subdir}"  )
    
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${subdir}/CMakeLists.txt)
            add_subdirectory(${subdir})
        endif()
    ENDFOREACH()
endmacro()




#[[
# link libraries to some target doing check if thoose exists
# @param [in]        target             - target   
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_link_libraries target)
    xw_target_link_libraries_internal(${target} eXtraWay.EE.modules ${ARGN}) 
endmacro()

#[[
# link libraries to some target doing check if thoose exists
# @param [in]        target             - target   
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_link_libraries_fcgi target)
    xw_target_link_libraries_internal(${target} eXtraWay.EE.fcgi.modules ${ARGN}) 
endmacro()

#[[
# link libraries to some target doing check if thoose exists
# @param [in]        cvs_project        - { eXtraWay.EE.modules | eXtraWay.EE.fcgi.modules }
# @param [in]        target             - target   
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_link_libraries_internal target cvs_project)

    set(lib_list "${ARGN}")
    
    set(private 0)
    list(GET lib_list 0 first_el)
    if("${first_el}" STREQUAL "PRIVATE")
        list(REMOVE_AT lib_list 0)
        set(private 1)
    endif()
       
    #message( STATUS "List : ${lib_list} " )
    foreach(curr_lib ${lib_list})
        #message( STATUS "Module : ${curr_lib} " )
        if(EXISTS ${XW_ROOT}/${curr_lib} AND IS_DIRECTORY ${XW_ROOT}/${curr_lib})
            #all is ok lib sources are present
            #message( STATUS "Module : ${curr_lib} OK!" )
        else()
            message( WARNING "Missing : ${curr_lib} from ${cvs_project} .... downloading it!" )
            get_cvs_module(${curr_lib} ${cvs_project})
        endif()
        
        if("${private}" STREQUAL "1")
            target_link_libraries (${target} PRIVATE
                ${curr_lib}            
            )
        else()
            target_link_libraries (${target} 
                ${curr_lib}            
            )
        endif()
       
    endforeach()
endmacro()


#[[
# check presence of source dirs
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_source_modules)
    xw_target_source_modules_internal(eXtraWay.EE.modules ${ARGN})
endmacro()

#[[
# check presence of fcgi source dirs
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_source_modules_fcgi)
    xw_target_source_modules_internal(eXtraWay.EE.fcgi.modules ${ARGN})
endmacro()

#[[
# check presence of source dirs
# @param [in]        cvs_project        - { eXtraWay.EE.modules | eXtraWay.EE.fcgi.modules }
# @param [in]        lib1               - libs[1]
# @param [in]        lib2               - libs[2]
#    ....
# @param [in]        libN               - libs[N]  
# 
#]]   
macro(xw_target_source_modules_internal cvs_project)
    set(module_list "${ARGN}")   
    #message( STATUS "List : ${lib_list} " )
    foreach(curr_module ${module_list})
        #message( STATUS "Module : ${curr_lib} " )
        if(EXISTS ${XW_ROOT}/${curr_module} AND IS_DIRECTORY ${XW_ROOT}/${curr_module})
            #all is ok lib sources are present
            #message( STATUS "Module : ${curr_lib} OK!" )
        else()
            message( WARNING "Missing : ${curr_module} from ${cvs_project} .... downloading it!" )
            get_cvs_module(${curr_module} ${cvs_project})
        endif()

    endforeach()
    
endmacro()

#########################################################
#
#      XW CVS specific  
#
########################################################

#[[
#    download eXtraWay.EE.modules module into current source tree
#    @param [in]    module_name - module name
#    @param [in]    cvs_project - { eXtraWay.EE.modules | eXtraWay.EE.fcgi.modules }
#]]
macro(get_cvs_module module_name cvs_project)
    
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    
        slashes_to_backslashes(cvs_exe_platform ${xw_cvs_exe})
        slashes_to_backslashes(priv_key_platform ${xw_priv_key})
        slashes_to_backslashes(plink_exe_platform ${xw_plink_exe})
        slashes_to_backslashes(module_name_platform ${module_name})
        set( cvs_project_platform ${cvs_project})
        
        configure_file("${XW_ROOT}/cmake/tmpl/plink-cvs.cmd.in" "${XW_ROOT}/../plink-cvs.cmd") 
        set(cmd "${XW_ROOT}/../get_cvs_${module_name}.cmd")
        configure_file("${XW_ROOT}/cmake/tmpl/get_cvs.cmd.in" "${cmd}")  
        
        #message(status " " ${cmd})
        execute_process(COMMAND  ${cmd}  WORKING_DIRECTORY "${XW_ROOT}/.." OUTPUT_VARIABLE ret RESULT_VARIABLE res ERROR_VARIABLE err)
    
    else()
        set(module_name_platform ${module_name})
        set(cvs_project_platform ${cvs_project})
        
        set(cmd "${XW_ROOT}/../get_cvs_${module_name}.sh")
        message(STATUS ${cmd})
        configure_file("${XW_ROOT}/cmake/tmpl/get_cvs.sh.in" "${cmd}") 

        execute_process(COMMAND chmod +x "${cmd}" COMMAND "${cmd}" WORKING_DIRECTORY "${XW_ROOT}/.." OUTPUT_VARIABLE ret RESULT_VARIABLE res ERROR_VARIABLE err)
    
    endif()
   
    message(STATUS "CVS Checkout: ")
    message(STATUS ${ret})
    #message(STATUS "result: " ${res})
    message(STATUS "CVS error: ")
    message(STATUS ${err})
    
    file(REMOVE "${XW_ROOT}/../plink-cvs.cmd")
    file(REMOVE "${cmd}")
endmacro()


#########################################################
#
#      XW specific  
#
########################################################

#[[
#    xw palugin packages 
#    @param [out]    plg_src_files - return list of files to add in target
#]]
function(add_plugin_base plg_src_files)
    set (_files
        ${XW_ROOT}/libclsupp/for-dll/dll.h
        ${XW_ROOT}/libclsupp/for-dll/dll.cpp
    	${XW_ROOT}/libclsupp/for-dll/dllmain.h
        ${XW_ROOT}/libclsupp/for-dll/dllmain.cpp
    )
    SOURCE_GROUP("common" FILES ${_files})    
    set(${plg_src_files} ${_files} PARENT_SCOPE) 
endfunction()


#[[
#    xw dll project 
#    @param [out]    dll_src_files - return list of files to add in target
#]]
function(add_dll_base dll_src_files)
    set (_files
        ${XW_ROOT}/libclsupp/for-dll/dllmain.h
        ${XW_ROOT}/libclsupp/for-dll/dllmain.cpp
    )
    SOURCE_GROUP("common" FILES ${_files})    
    set(${dll_src_files} ${_files} PARENT_SCOPE) 
endfunction()


#[[
#    xw singleton sources 
#    @param [out]    singleton_src_files - return list of files to add in target
#    @param [in]     singleton name   
#]]
function(add_singleton singleton_src_files singleton)
    string(TOLOWER "${singleton}" singleton_path)
    set(src_files "")
    add_sources_dir(src_files "${XW_ROOT}/singletons/${singleton_path}" "${XW_ROOT}/singletons/${singleton_path}" "${singleton}" "" "")
    include_directories("${XW_ROOT}/singletons/${singleton_path}")    
    set(${singleton_src_files} ${src_files} PARENT_SCOPE)
endfunction()


# set bin dirs for target
macro (set_bindir_properties target)
if (CMAKE_SIZEOF_VOID_P MATCHES 4)
   
   if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION} )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION} )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION} )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION} )
	else()
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin )
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d )
	endif()
elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
	if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}-x64 )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}-x64 )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}-x64 )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}-x64 )
	else()
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin-x64 )
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d-x64 )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin-x64 )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d-x64 )
	endif()
endif ()
endmacro ()

# set bin dirs for plugin
macro (set_binpckg_properties target)
if (CMAKE_SIZEOF_VOID_P MATCHES 4)
    if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}/plug-in )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}/plug-in )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}/plug-in )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}/plug-in )
   else ()  
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin/plug-in )
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d/plug-in )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin/plug-in )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d/plug-in ) 
   endif()
elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
   if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}-x64/plug-in )
	   set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}-x64/plug-in )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin${VC_VERSION}-x64/plug-in )
	   set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d${VC_VERSION}-x64/plug-in )
   else ()  
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin-x64/plug-in )
       set_target_properties( ${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d-x64/plug-in )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${XW_BINARIES_ROOT}bin-x64/plug-in )
       set_target_properties( ${target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${XW_BINARIES_ROOT}bin_d-x64/plug-in ) 
   endif()
endif ()
endmacro ()

# add install dirs for target
macro(add_bin_install_dir target)
    install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin CONFIGURATIONS Release ${ARGN})
    
#    if (CMAKE_SIZEOF_VOID_P MATCHES 4)
#        install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin10 CONFIGURATIONS Release)
#    	install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d10 CONFIGURATIONS Debug)
#    elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
#    	if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
#	        install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin${VC_VERSION}-x64 CONFIGURATIONS Release)
#	    	install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d${VC_VERSION}-x64 CONFIGURATIONS Debug)
#	    else()
#	        install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin-x64 CONFIGURATIONS Release)
#            install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d-x64 CONFIGURATIONS Debug)
#	    endif()
#    endif ()
endmacro()

macro(add_clp_install_dir target)
    install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin/plug-in CONFIGURATIONS Release ${ARGN})
    
#    if (CMAKE_SIZEOF_VOID_P MATCHES 4)
#        install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin10/plug-in CONFIGURATIONS Release)
#    	install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d10/plug-in CONFIGURATIONS Debug)
#    elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
#    	if (  "${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" )
#	        install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin${VC_VERSION}-x64/plug-in CONFIGURATIONS Release)
#	    	install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d${VC_VERSION}-x64/plug-in CONFIGURATIONS Debug)
#    	else()    
#            install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin-x64/plug-in CONFIGURATIONS Release)
#            install (TARGETS ${target} DESTINATION ${XW_BINARIES_INSTALL_ROOT}bin_d-x64/plug-in CONFIGURATIONS Debug)	
#    	endif()
#    endif ()
endmacro()

#add lib install dirs
macro(add_lib_install_dir target)

    #disabled CAUSE build do dependancy for itself
    
    #if (CMAKE_SIZEOF_VOID_P MATCHES 4)
    #    install (TARGETS ${target} DESTINATION ${XW_ROOT}/libs10)
    #elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
    #    install (TARGETS ${target} DESTINATION ${XW_ROOT}/libs10-x64)
    #endif ()    
endmacro()

#set standardised lib names, it outr platform rule
macro(set_lib_names target)
    SET_TARGET_PROPERTIES( ${target} PROPERTIES
    	OUTPUT_NAME "${target}"
    	DEBUG_OUTPUT_NAME "${target}d"
    )
    
    if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
        #we need avoid linux "lib" prefix
        SET_TARGET_PROPERTIES( ${target} PROPERTIES PREFIX "")
    endif()
    
endmacro()

# A convenience macro to apply any custom preprocessor definitions to all configurations of a given target.
macro (apply_custom_preprocessor_definitions_debug target)
    foreach(prop "${ARGN}")
        #message(STATUS ${prop})
        set_property (TARGET ${target} APPEND PROPERTY
            COMPILE_DEFINITIONS $<$<CONFIG:Debug>:${prop}>
        )
    endforeach()
endmacro ()

macro (apply_custom_preprocessor_definitions_release target)
     foreach(prop "${ARGN}")
        set_property (TARGET ${target} APPEND PROPERTY
            COMPILE_DEFINITIONS $<$<CONFIG:Release>:${prop}>
        )
     endforeach()    
endmacro ()

# See previous...
macro (apply_custom_preprocessor_definitions target)
    apply_custom_preprocessor_definitions_debug(${target} "${ARGN}")
    apply_custom_preprocessor_definitions_release(${target} "${ARGN}") 
endmacro ()



# some custom dependencies 
macro (add_libson target)
    include_directories(${XW_INCLUDE_3RDP_ROOT}/libbson-1.0)
    target_link_libraries(${target}
        bson-1.0
    ) 
endmacro ()
macro (add_libson_private target)
    include_directories(${XW_INCLUDE_3RDP_ROOT}/libbson-1.0)
    target_link_libraries(${target} PRIVATE
        bson-1.0
    ) 
endmacro ()

