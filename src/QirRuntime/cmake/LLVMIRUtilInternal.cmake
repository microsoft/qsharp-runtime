
# internal utility macros/functions

include(CMakeParseArguments)

function(debug message_txt)
  if($ENV{LLVMIR_CMAKE_DEBUG})
    message(STATUS "[DEBUG] ${message_txt}")
  endif()
endfunction()


macro(catuniq lst)
  list(APPEND ${lst} ${ARGN})
  if(${lst})
    list(REMOVE_DUPLICATES ${lst})
  endif()
endmacro()


# internal implementation detail macros/functions

macro(llvmir_setup)
  set(LLVMIR_DIR "llvm-ir")

  set(LLVMIR_COMPILER "")
  set(LLVMIR_OPT "opt")
  set(LLVMIR_LINK "llvm-link")
  set(LLVMIR_ASSEMBLER "llvm-as")
  set(LLVMIR_DISASSEMBLER "llvm-dis")

  set(LLVMIR_BINARY_FMT_SUFFIX "bc")
  set(LLVMIR_TEXT_FMT_SUFFIX "ll")

  set(LLVMIR_BINARY_TYPE "LLVMIR_BINARY")
  set(LLVMIR_TEXT_TYPE "LLVMIR_TEXT")
  set(LLVMIR_OBJECT_TYPE "LLVMIR_OBJECT")

  set(LLVMIR_TYPES ${LLVMIR_BINARY_TYPE} ${LLVMIR_TEXT_TYPE})
  set(LLVMIR_FMT_SUFFICES ${LLVMIR_BINARY_FMT_SUFFIX} ${LLVMIR_TEXT_FMT_SUFFIX})

  set(LLVMIR_COMPILER_IDS "Clang")

  message(STATUS "LLVM IR Utils")

  define_property(TARGET PROPERTY LLVMIR_TYPE
    BRIEF_DOCS "type of LLVM IR file"
    FULL_DOCS "type of LLVM IR file")
  define_property(TARGET PROPERTY LLVMIR_DIR
    BRIEF_DOCS "Input /output directory for LLVM IR files"
    FULL_DOCS "Input /output directory for LLVM IR files")
  define_property(TARGET PROPERTY LLVMIR_FILES
    BRIEF_DOCS "list of LLVM IR files"
    FULL_DOCS "list of LLVM IR files")
endmacro()


macro(llvmir_set_compiler linker_language)
  if("${LLVMIR_COMPILER}" STREQUAL "")
    set(LLVMIR_COMPILER ${CMAKE_${linker_language}_COMPILER})
    set(LLVMIR_COMPILER_ID ${CMAKE_${linker_language}_COMPILER_ID})

    list(FIND LLVMIR_COMPILER_IDS ${LLVMIR_COMPILER_ID} found)

    if(found EQUAL -1)
      message(FATAL_ERROR "LLVM IR compiler ID ${LLVMIR_COMPILER_ID} is not in \
      ${LLVMIR_COMPILER_IDS}")
    endif()
  endif()
endmacro()


function(llvmir_check_target_properties_impl)
  set(options)
  set(oneValueArgs TARGET RESULT_VARIABLE)
  set(multiValueArgs PROPERTIES)
  cmake_parse_arguments(CTP
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # argument checks

  if(NOT CTP_TARGET)
    message(FATAL_ERROR "Missing TARGET option.")
  endif()

  if(NOT CTP_RESULT_VARIABLE)
    message(FATAL_ERROR "Missing RESULT_VARIABLE option.")
  endif()

  if(NOT CTP_PROPERTIES)
    message(FATAL_ERROR "Missing PROPERTIES option.")
  endif()

  if(CTP_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Extraneous arguments ${CTP_UNPARSED_ARGUMENTS}.")
  endif()

  if(NOT TARGET ${CTP_TARGET})
    message(FATAL_ERROR "Cannot attach to non-existing target: ${CTP_TARGET}.")
  endif()

  set(_RESULT_VARIABLE 0)

  foreach(prop ${CTP_PROPERTIES})
    # equivalent to
    # if(DEFINED prop AND prop STREQUAL "")
    set(is_def TRUE)
    set(is_set TRUE)

    # this seems to not be working for targets defined with builtins
    #get_property(is_def TARGET ${CTP_TARGET} PROPERTY ${prop} DEFINED)

    get_property(is_set TARGET ${CTP_TARGET} PROPERTY ${prop} SET)

    if(NOT is_def)
      message(WARNING "property ${prop} for target ${CTP_TARGET} \
      must be defined.")
      set(_RESULT_VARIABLE 1)
    endif()

    if(NOT is_set)
      message(WARNING "property ${prop} for target ${CTP_TARGET} must be set.")
      set(_RESULT_VARIABLE 2)
    endif()
  endforeach()

  set(${CTP_RESULT_VARIABLE} ${_RESULT_VARIABLE} PARENT_SCOPE)
endfunction()


function(llvmir_check_non_llvmir_target_properties trgt)
  set(props SOURCES LINKER_LANGUAGE)

  llvmir_check_target_properties_impl(
    TARGET ${trgt}
    PROPERTIES ${props}
    RESULT_VARIABLE RC)

  if(RC)
    message(FATAL_ERROR "Target ${trgt} is missing required properties.")
  endif()
endfunction()


function(llvmir_check_target_properties trgt)
  set(props LINKER_LANGUAGE LLVMIR_DIR LLVMIR_FILES LLVMIR_TYPE)

  llvmir_check_target_properties_impl(
    TARGET ${trgt}
    PROPERTIES ${props}
    RESULT_VARIABLE RC)

  if(RC)
    message(FATAL_ERROR "Target ${trgt} is missing required properties.\
    It might not be a LLVMIR target.")
  endif()
endfunction()


function(llvmir_extract_compile_defs_properties out_compile_defs from)
  set(defs "")
  set(compile_defs "")
  set(prop_name "COMPILE_DEFINITIONS")

  # per directory
  get_property(defs DIRECTORY PROPERTY ${prop_name})
  foreach(def ${defs})
    list(APPEND compile_defs -D${def})
  endforeach()

  get_property(defs DIRECTORY PROPERTY ${prop_name}_${CMAKE_BUILD_TYPE})
  foreach(def ${defs})
    list(APPEND compile_defs -D${def})
  endforeach()

  # per target
  if(TARGET ${from})
    get_property(defs TARGET ${from} PROPERTY ${prop_name})
    foreach(def ${defs})
      list(APPEND compile_defs -D${def})
    endforeach()

    get_property(defs TARGET ${from} PROPERTY ${prop_name}_${CMAKE_BUILD_TYPE})
    foreach(def ${defs})
      list(APPEND compile_defs -D${def})
    endforeach()

    get_property(defs TARGET ${from} PROPERTY INTERFACE_${prop_name})
    foreach(def ${defs})
      list(APPEND compile_defs -D${def})
    endforeach()
  else()
    # per file
    get_property(defs SOURCE ${from} PROPERTY ${prop_name})
    foreach(def ${defs})
      list(APPEND compile_defs -D${def})
    endforeach()

    get_property(defs SOURCE ${from} PROPERTY ${prop_name}_${CMAKE_BUILD_TYPE})
    foreach(def ${defs})
      list(APPEND compile_defs -D${def})
    endforeach()
  endif()

  list(REMOVE_DUPLICATES compile_defs)

  debug("@llvmir_extract_compile_defs_properties ${from}: ${compile_defs}")

  set(${out_compile_defs} ${compile_defs} PARENT_SCOPE)
endfunction()


function(llvmir_extract_compile_option_properties out_compile_options trgt)
  set(options "")
  set(compile_options "")
  set(prop_name "COMPILE_OPTIONS")

  # per directory
  get_property(options DIRECTORY PROPERTY ${prop_name})
  foreach(opt ${options})
    list(APPEND compile_options ${opt})
  endforeach()

  # per target
  get_property(options TARGET ${trgt} PROPERTY ${prop_name})
  foreach(opt ${options})
    list(APPEND compile_options ${opt})
  endforeach()

  get_property(options TARGET ${trgt} PROPERTY INTERFACE_${prop_name})
  foreach(opt ${options})
    list(APPEND compile_options ${opt})
  endforeach()

  list(REMOVE_DUPLICATES compile_options)

  debug("@llvmir_extract_compile_option_properties ${trgt}: ${compile_options}")

  set(${out_compile_options} ${compile_options} PARENT_SCOPE)
endfunction()


function(llvmir_extract_include_dirs_properties out_include_dirs trgt)
  set(dirs "")
  set(prop_name "INCLUDE_DIRECTORIES")

  # per directory
  get_property(dirs DIRECTORY PROPERTY ${prop_name})
  foreach(dir ${dirs})
    list(APPEND include_dirs -I${dir})
  endforeach()

  # per target
  get_property(dirs TARGET ${trgt} PROPERTY ${prop_name})
  foreach(dir ${dirs})
    list(APPEND include_dirs -I${dir})
  endforeach()

  get_property(dirs TARGET ${trgt} PROPERTY INTERFACE_${prop_name})
  foreach(dir ${dirs})
    list(APPEND include_dirs -I${dir})
  endforeach()

  get_property(dirs TARGET ${trgt} PROPERTY INTERFACE_SYSTEM_${prop_name})
  foreach(dir ${dirs})
    list(APPEND include_dirs -I${dir})
  endforeach()

  if(include_dirs)
    list(REMOVE_DUPLICATES include_dirs)
  endif()

  debug("@llvmir_extract_include_dirs_properties ${trgt}: ${include_dirs}")

  set(${out_include_dirs} ${include_dirs} PARENT_SCOPE)
endfunction()


function(llvmir_extract_lang_flags out_lang_flags lang)
  set(lang_flags "")

  set(lang_flags ${CMAKE_${lang}_FLAGS_${CMAKE_BUILD_TYPE}})
  set(lang_flags "${lang_flags} ${CMAKE_${lang}_FLAGS}")

  string(REPLACE "\ " ";" lang_flags ${lang_flags})

  debug("@llvmir_extract_lang_flags ${lang}: ${lang_flags}")

  set(${out_lang_flags} ${lang_flags} PARENT_SCOPE)
endfunction()


function(llvmir_extract_standard_flags out_standard_flags trgt lang)
  set(standard_flags "")
  set(std_prop "${lang}_STANDARD")
  set(ext_prop "${lang}_EXTENSIONS")

  get_property(std TARGET ${trgt} PROPERTY ${std_prop})
  get_property(ext TARGET ${trgt} PROPERTY ${ext_prop})

  set(lang_prefix "")

  if(std)
    if(ext)
      set(lang_prefix "gnu")
    else()
      string(TOLOWER ${lang} lang_prefix)
    endif()
  endif()

  if(lang_prefix STREQUAL "cxx")
    set(lang_prefix "c++")
  endif()

  set(flag "${lang_prefix}${std}")

  if(flag)
    set(standard_flags "-std=${flag}")
  endif()

  debug("@llvmir_extract_standard_flags ${lang}: ${standard_flags}")

  set(${out_standard_flags} ${standard_flags} PARENT_SCOPE)
endfunction()


function(llvmir_extract_compile_flags out_compile_flags from)
  set(compile_flags "")
  set(prop_name "COMPILE_FLAGS")

  if(TARGET ${from})
    get_property(compile_flags TARGET ${from} PROPERTY ${prop_name})
  else()
    get_property(compile_flags SOURCE ${from} PROPERTY ${prop_name})
  endif()

  # deprecated according to cmake docs
  if(NOT "${compile_flags}" STREQUAL "")
    message(WARNING "COMPILE_FLAGS property is deprecated.")
  endif()

  debug("@llvmir_extract_compile_flags ${from}: ${compile_flags}")

  set(${out_compile_flags} ${compile_flags} PARENT_SCOPE)
endfunction()


