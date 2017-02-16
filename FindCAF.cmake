# Try to find CAF headers and library.
#
# Use this module as follows:
#
#     find_package(CAF)
#
# Variables used by this module (they can change the default behaviour and need
# to be set before calling find_package):
#
#  CAF_ROOT_DIR  Set this variable either to an installation prefix or to wa
#                CAF build directory where to look for the CAF libraries.
#
#  CAF_STATIC_ONLY  Find the static libraries of caf only.
#
# Variables defined by this module:
#
#  CAF_FOUND              System has CAF headers and library
#  CAF_LIBRARIES          List of library files  for all components
#  CAF_INCLUDE_DIRS       List of include paths for all components
#  CAF_LIBRARY_$C         Library file for component $C
#  CAF_INCLUDE_DIR_$C     Include path for component $C

# iterate over user-defined components
foreach (comp ${CAF_FIND_COMPONENTS})
  # we use uppercase letters only for variable names
  string(TOUPPER "${comp}" UPPERCOMP)
  if ("${comp}" STREQUAL "core")
    set(HDRNAME "caf/all.hpp")
  elseif ("${comp}" STREQUAL "test")
    set(HDRNAME "caf/test/unit_test.hpp")
  else ()
    set(HDRNAME "caf/${comp}/all.hpp")
  endif ()
  if (CAF_ROOT_DIR)
    set(header_hints
        "${CAF_ROOT_DIR}/include"
        "${CAF_ROOT_DIR}/../libcaf_${comp}")
  endif ()
  # give CAF_ROOT_DIR priority...
  find_path(CAF_INCLUDE_DIR_${UPPERCOMP}
            NAMES
              ${HDRNAME}
            HINTS
	      ${header_hints}
	    NO_DEFAULT_PATH)
  # ...then look in default locations if not found yet
  find_path(CAF_INCLUDE_DIR_${UPPERCOMP}
            NAMES
              ${HDRNAME}
            HINTS
              /usr/include
              /usr/local/include
              /opt/local/include
              /sw/include
              ${CMAKE_INSTALL_PREFIX}/include)
  mark_as_advanced(CAF_INCLUDE_DIR_${UPPERCOMP})
  if (NOT "${CAF_INCLUDE_DIR_${UPPERCOMP}}"
      STREQUAL "CAF_INCLUDE_DIR_${UPPERCOMP}-NOTFOUND")
    # mark as found (set back to false in case library cannot be found)
    set(CAF_${comp}_FOUND true)
    # add to CAF_INCLUDE_DIRS only if path isn't already set
    set(duplicate false)
    foreach (p ${CAF_INCLUDE_DIRS})
      if (${p} STREQUAL ${CAF_INCLUDE_DIR_${UPPERCOMP}})
        set(duplicate true)
      endif ()
    endforeach ()
    if (NOT duplicate)
      set(CAF_INCLUDE_DIRS ${CAF_INCLUDE_DIRS} ${CAF_INCLUDE_DIR_${UPPERCOMP}})
    endif()
    # look for (.dll|.so|.dylib) file, again giving hints for non-installed CAFs
    # skip probe_event as it is header only
    if (NOT ${comp} STREQUAL "probe_event" AND NOT ${comp} STREQUAL "test")
      if (CAF_ROOT_DIR)
        set(library_hints "${CAF_ROOT_DIR}/lib")
      endif ()
      # Find dynamic or static library
      if (CAF_STATIC_ONLY)
        set(library_name "caf_${comp}_static")
      else ()
        set(library_name "caf_${comp}")
      endif ()
      # give CAF_ROOT_DIR priority...
      find_library(CAF_LIBRARY_${UPPERCOMP}
                   NAMES
                     ${library_name}
                   HINTS
                     ${library_hints}
		     NO_DEFAULT_PATH)
      # ...then look in default locations if not found yet
      find_library(CAF_LIBRARY_${UPPERCOMP}
                   NAMES
                     ${library_name}
                   HINTS
                     /usr/lib
                     /usr/local/lib
                     /opt/local/lib
                     /sw/lib
                     ${CMAKE_INSTALL_PREFIX}/lib)
      mark_as_advanced(CAF_LIBRARY_${UPPERCOMP})
      if ("${CAF_LIBRARY_${UPPERCOMP}}" STREQUAL "CAF_LIBRARY-NOTFOUND")
        set(CAF_${comp}_FOUND false)
      else ()
        set(CAF_LIBRARIES ${CAF_LIBRARIES} ${CAF_LIBRARY_${UPPERCOMP}})
      endif ()
    endif ()
  endif ()
endforeach ()

# let CMake check whether all requested components have been found
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CAF
                                  FOUND_VAR CAF_FOUND
                                  REQUIRED_VARS CAF_LIBRARIES CAF_INCLUDE_DIRS
                                  HANDLE_COMPONENTS)

# final step to tell CMake we're done
mark_as_advanced(CAF_ROOT_DIR
                 CAF_LIBRARIES
                 CAF_INCLUDE_DIRS)
