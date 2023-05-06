# all dedicated to sorting only
function(is_list_same length)
	cmake_parse_arguments(MOD "" "IF" "Else" ${ARGN})
	set(raw_list ${MOD_UNPARSED_ARGUMENTS})
	set(list1)
	foreach(i RANGE ${length})
		list(GET raw_list ${i} n)
		set(list1 ${list1} ${n})
	endforeach()
	math(EXPR length1 "${length} + 1")
	math(EXPR lengthm "(${length1}*2) -1")
	set(list2)
	foreach(i RANGE ${length1} ${lengthm})
		list(GET raw_list ${i} n)
		set(list2 ${list2} ${n})
	endforeach()
	foreach(n RANGE ${length})
		list(GET list1 ${n} x)
		list(GET list2 ${n} y)
		if(x EQUAL y)
			set(EQUAL_TERM TRUE PARENT_SCOPE)
		else()
			set(EQUAL_TERM FALSE PARENT_SCOPE)
			break()
		endif()
	endforeach()
endfunction()

# all dedicated to sorting only
function(sort_list outvar)
	cmake_parse_arguments(MOD "" "IF" "Else" ${ARGN})
	set(list1 ${MOD_UNPARSED_ARGUMENTS})
	list(LENGTH list1 _len)
	math(EXPR len1 "${_len} - 1")
	math(EXPR len "${_len} - 2")
	math(EXPR endl "${len}*2")
	set(tmp_list ${list1})
	while(TRUE)
		foreach(n RANGE ${len})
			list(GET list1 ${n} x)
			math(EXPR n1 "${n} + 1")
			list(GET list1 ${n1} y)
			if(x LESS y)
				list(INSERT list1 ${n} ${y})
				list(INSERT list1 ${n1} ${x})
				math(EXPR n2 "${n1} + 1")
				list(REMOVE_AT list1 ${n2})
				list(REMOVE_AT list1 ${n2})
			endif()
		endforeach()
		is_list_same(${len1} ${list1} ${tmp_list})
		if(EQUAL_TERM)
			break()
		endif()
		set(tmp_list ${list1})
	endwhile()
	set(${outvar} ${list1} PARENT_SCOPE)
endfunction()

function(get_most_latest_std_version downto outvar)
	set(latests)
	set(std_versions)
	foreach(feature ${CMAKE_CXX_COMPILE_FEATURES})
		if(feature MATCHES "cxx_std_([0-9]+)")
			string(REGEX REPLACE "_" ";" _tmp_list ${feature})
			list(GET _tmp_list 2 std_version)
			set(std_versions ${std_versions} ${std_version}) 
		endif()
	endforeach()
	sort_list(latest_std_versions ${std_versions})
	list(LENGTH latest_std_versions len)
	math(EXPR ${len} "${len}-1")	
	foreach(n RANGE ${len})
		list(GET latest_std_versions ${n} ver)
		if(${ver} LESS 90)
			set(latests ${latests} ${ver})
		endif()
		if(${n} GREATER_EQUAL ${downto})
			break()
		endif()
	endforeach()
	set(${outvar} ${latests} PARENT_SCOPE)
endfunction()

function(add_benchmark target)
	list(LENGTH LATEST_STD_VERSIONS len)
	set(test_files)
	set(test_files_command)
	set(test_vars)
	foreach(std ${LATEST_STD_VERSIONS})
		set(test_files_command "${test_files_command} t_${std}=dolla\( \{ time eval ./${target}_${std}\; }  2>&1 1>/dev/null ) && ")
		set(test_files ${test_files} ${target}_${std})
		set(test_vars "${test_vars} echo '${std} - dollat_${std}' && ")
	endforeach()
	set(BENCHMARK_COMMAND "#!/bin/bash fuck TIMEFORMAT=\"%R\"fuck${test_files_command}echo done fuck ${test_vars} echo done")

	add_custom_target(benchmarks ALL)
	add_custom_command(
		TARGET benchmarks
		COMMAND echo '${BENCHMARK_COMMAND}' > benchmark
		DEPENDS ${test_files}
	)	
	add_custom_target(build_exec
		ALL 
		COMMAND eval ./sanitize_benchmark benchmark
		DEPENDS benchmark
	)
	message(STATUS "added \"benchmark\" for \"${target}\"")
endfunction()

function(detect_gcc_13 output_has output_is)
	if(MSVC)	
		message(FATAL_ERROR "sorry, we don't ever use windows and we don't support windows")
	endif()
	set(${output_has} FALSE PARENT_SCOPE)
	set(${output_is} FALSE PARENT_SCOPE)
	set(lib_dir "/usr/lib/gcc/x86_64-pc-linux-gnu/")
	execute_process(
		COMMAND ls "${lib_dir}" 
		OUTPUT_VARIABLE gcc_versions_found
	)
	string(REGEX REPLACE "\\." ";" _current_versions ${CMAKE_CXX_COMPILER_VERSION})
	list(GET _current_versions 0 current_major)
	if("${gcc_versions_found}" STREQUAL "")
		message(WARNING "Could not find GCC version")
		return()
	endif()
	string(REGEX REPLACE "\n" ";" versions ${gcc_versions_found})
	foreach(version ${versions})
		string(REGEX REPLACE "\\." ";" _versions ${version})
		list(GET _versions 0 major)
		if(major EQUAL 13)
			set(${output_has} TRUE PARENT_SCOPE)
		endif()
		if(major EQUAL current_major AND major EQUAL 13)
			set(${output_is} TRUE PARENT_SCOPE)
		endif()
	endforeach()
endfunction()
	
function(add_executable_with_all_std_versions downto target) 
	cmake_parse_arguments(MOD "" "IF" "Else" ${ARGN})
	set(list1 ${MOD_UNPARSED_ARGUMENTS})
	get_most_latest_std_version(${downto} latest_std_versions)
	set(LATEST_STD_VERSIONS ${latest_std_versions} PARENT_SCOPE)
	list(LENGTH latest_std_versions len)
	math(EXPR len "${len}-1" )
	foreach(i RANGE ${len})
		list(GET latest_std_versions ${i} std)
		set(target_std "${target}_${std}" )
		add_executable(${target_std} ${list1})
		target_compile_features(${target_std} PUBLIC cxx_std_${std})
		target_compile_options(${target_std} PUBLIC -std=c++${std} -O3)
		message(STATUS "adding latest C++ standard versions for ${CMAKE_CXX_COMPILER_ID}(${CMAKE_CXX_COMPILER_VERSION}) - C++${std} - target \"${target}\"")
	endforeach()
endfunction()
