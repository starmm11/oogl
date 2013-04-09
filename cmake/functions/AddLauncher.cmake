function(add_launcher)
	message(STATUS "adding launcher for ${CURRENT_NAME}")
	#dam simple parsing of extra args
	set(LAUNCHER_POSTFIX "")
	list(FIND ARGN "POSTFIX" has_postfix)
	if(has_postfix GREATER -1)
		math(EXPR i_postfix "${has_postfix}+1")
		list(GET ARGN ${i_postfix} LAUNCHER_POSTFIX)
		list(REMOVE_AT ARGN ${has_postfix} ${i_postfix})
	endif()

	foreach(arg ${ARGN})
		set(LAUNCHER_ARGS "${LAUNCHER_ARGS} ${arg}")
	endforeach()

	foreach(dirs BIN LIBRARY INCLUDE)
		if(CURRENT_${dirs}_DIRS)
			list(REMOVE_DUPLICATES CURRENT_${dirs}_DIRS)
		else()
			set(CURRENT_${dirs}_DIRS)
		endif()
	endforeach()

	if(WIN32)
		set(LAUNCHER_EXTENSION bat)
		set(LAUNCHER_INFIX ${IDE_TYPE})
	elseif(UNIX)
		set(LAUNCHER_EXTENSION sh)
		set(LAUNCHER_INFIX make)
	endif()

	set(LAUNCHER_FILE "${CMAKE_SOURCE_DIR}/cmake/start.${LAUNCHER_INFIX}.${COMPUTERNAME}.${LAUNCHER_EXTENSION}")
	if(NOT EXISTS ${LAUNCHER_FILE})
		set(LAUNCHER_FILE "${CMAKE_SOURCE_DIR}/cmake/start.${LAUNCHER_INFIX}.${LAUNCHER_EXTENSION}")
	endif()

	if(NOT EXISTS ${LAUNCHER_FILE})
		message(AUTHOR_WARNING "can't find launcher template: ${LAUNCHER_FILE}")
		return()
	endif()

	set(LAUNCHER_RESULT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/start${CURRENT_NAME}${LAUNCHER_POSTFIX}.${LAUNCHER_EXTENSION}")

	if(WIN32)
		string(REPLACE "/" "\\" CURRENT_FIXED_BIN_DIRS "${CURRENT_BIN_DIRS}")
		string(REPLACE "/" "\\" CURRENT_FIXED_LIBRARY_DIRS "${CURRENT_LIBRARY_DIRS}")
		string(REPLACE "/" "\\" CMAKE_FIXED_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
		configure_file("${LAUNCHER_FILE}" ${LAUNCHER_RESULT_FILE} IMMEDIATE)
		#generate a .user file to set the working directory
		if (MSVC AND (MSVC10 OR (MSVC_VERSION EQUAL 1600)))
			configure_file(${CMAKE_SOURCE_DIR}/cmake/vs2010.vcxproj.user.in
				${CMAKE_CURRENT_BINARY_DIR}/${CURRENT_NAME}.vcxproj.user @ONLY)
		elseif (MSVC AND (MSVC11 OR (MSVC_VERSION EQUAL 1700)))
			configure_file(${CMAKE_SOURCE_DIR}/cmake/vs2012.vcxproj.user.in
				${CMAKE_CURRENT_BINARY_DIR}/${CURRENT_NAME}.vcxproj.user @ONLY)
		elseif (MSVC AND (MSVC90 OR (MSVC_VERSION EQUAL 1500)))
			configure_file(${CMAKE_SOURCE_DIR}/cmake/vs2008.vcproj.user.in
				${CMAKE_CURRENT_BINARY_DIR}/${CURRENT_NAME}.vcproj.user @ONLY)
		endif()
	elseif(UNIX)
		string(REPLACE ";" ":" CURRENT_FIXED_BIN_DIRS "${CURRENT_BIN_DIRS}")
		string(REPLACE ";" ":" CURRENT_FIXED_LIBRARY_DIRS "${CURRENT_LIBRARY_DIRS}")
		configure_file("${LAUNCHER_FILE}" ${LAUNCHER_RESULT_FILE} IMMEDIATE)
		exec_program(chmod ARGS 755 "${LAUNCHER_RESULT_FILE}")
	endif()
endfunction(add_launcher)