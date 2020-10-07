include(LLVMIRUtil)

# to customize locations of the tools uncomment and modify
# (or add the tools to PATH)
#set(LLVMIR_COMPILER "C:/Program Files/LLVM/bin/clang++.exe")
#set(LLVM_DIST "D:/repos/llvm-project/llvm/out/build/x64-Debug/bin")
#set(LLVMIR_OPT "${LLVM_DIST}/opt.exe")
#set(LLVMIR_LINK "${LLVM_DIST}/llvm-link.exe")
#set(LLVMIR_ASSEMBLER "${LLVM_DIST}/llvm-as.exe")
#set(LLVMIR_DISASSEMBLER "${LLVM_DIST}/llvm-dis.exe")

# 'target_name' should be the name of component the IR generation is piggy-backing on
function(produce_ir target_name)
  if (${GENERATE_IR})
    generate_ir(${target_name})
  endif()
endfunction()

function(generate_ir target_name)
  # this property is required by llvm cmake additional targets
  set_target_properties(${target_name} PROPERTIES LINKER_LANGUAGE CXX)

  set(target_name_bc "${target_name}_bc")
  llvmir_attach_bc_target(${target_name_bc} ${target_name})
  add_dependencies(${target_name_bc} ${target_name})

  set(target_name_dis "${target_name}_dis")
  llvmir_attach_disassemble_target(${target_name_dis} ${target_name_bc})
  add_dependencies(${target_name_dis} ${target_name_bc})

  set(target_name_opt "${target_name}_opt")
  llvmir_attach_opt_pass_target(
    TARGET ${target_name_opt}
    DEPENDS ${target_name_bc} -O3)

  set(target_name_opt_dis "${target_name_opt}_dis")
  llvmir_attach_disassemble_target(
    TARGET ${target_name_opt_dis}
    DEPENDS ${target_name_opt})

  set(target_name_pipeline "${target_name}_pipeline")
  add_custom_target(${target_name_pipeline} DEPENDS
    ${target_name_dis}
    ${target_name_opt_dis}
  )

  # without this property CMake doesn't run our custom commands
  set_property(TARGET ${target_name_pipeline} PROPERTY EXCLUDE_FROM_ALL OFF)
endfunction()