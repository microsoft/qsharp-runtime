#!/usr/bin/env python3
# (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger
# Code generator for n-qubit gate

import sys


def avx_type(complex_avx_len):
  if complex_avx_len == 2:
    return "__m256d"
  elif complex_avx_len == 4:
    return "__m512d"
  elif complex_avx_len == 1:
    return "std::complex<double>"
  else:
    raise Exception("Unknown avx type.")


def avx_prefix(complex_avx_len):
  if complex_avx_len == 2:
    return "_mm256"
  elif complex_avx_len == 4:
    return "_mm512"
  else:
    raise Exception("Unknown avx type.")


def generate_kernel_core(N, n, kernelarray, blocks, only_one_matrix, unroll_loops, avx_len):
  indent = 1
  
  kernelarray.append("// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger\n\ntemplate <class V, class M>\ninline void kernel_core(V& psi, std::size_t I")
  for i in range(n):
    kernelarray.append(", std::size_t d" + str(i))
  
  kernelarray.append(", M const& m")
  if not only_one_matrix:
    kernelarray.append(", M const& mt")
  kernelarray.append(")\n{\n")
  
  indices = [""]*N
  for num in range(N):
    tmp = "I"
    for b in range(n):
      if (num>>b) & 1:
        tmp = tmp + " + d"+str(b)
    indices[num] = tmp

  add = ["\t" + avx_type(avx_len) + " v[" + str(int(N/blocks)) + "];\n"]
  for b in range(blocks):
    if avx_len == 4:
      x4 = "x4"
    else:
      x4 = ""
    for num in range(int(N/blocks)*b, int(N/blocks)*(b+1)):
      add.append("\n\tv[" + str(int(num % (N/blocks))) + "] = ")
      if avx_len > 1:
        add.append("load1" + x4 + "(&")
      add.append("psi[" + indices[num] + "]")
      if avx_len > 1:
        add.append(")")
      add.append(";")
    add.append("\n")
    if b == 0:
      add.append("\n\t" + avx_type(avx_len) + " tmp[" + str(int(N/avx_len)) + "] = {")
      for i in range(int(N/avx_len)):
        if avx_len > 1:
          add.append(avx_prefix(avx_len) + "_setzero_pd(), ")
        else:
          add.append("0., ")
      add[-1] = add[-1][:-2] + "};\n"
    
    if unroll_loops:
      inline_FMAs = False
      miniblocks = N/avx_len/4
      miniblocks = max(miniblocks, 1)
      for mb in range(int(miniblocks)):
        for rb in range(int(N/avx_len/miniblocks)):
          r = int(mb*N/avx_len/miniblocks) + rb
          add.append("\n\ttmp[" + str(r) + "] = ")
        
          for i in range(int(N/blocks)):
            if not inline_FMAs or avx_len == 1:
              add.append("fma(v[" + str(i) + "], m[" + str(b*int(N/blocks)*int(N/avx_len)+r*int(N/blocks)+i) +"], ")
              if not only_one_matrix:
                add.append("mt[" + str(b*int(N/blocks)*int(N/avx_len)+i+r*int(N/blocks)) +"], ")
            else:
              add.append(avx_prefix(avx_len) + "_fmadd_pd(v[" + str(i) + "], m[" + str(b*int(N/blocks)*int(N/avx_len)+r*int(N/blocks)+i) +"], ")
          add.append("tmp[" + str(r) + "]")
          add.append(")"*int(N/blocks)+";")
        
        if inline_FMAs and not only_one_matrix and not avx_len == 1:
          for rb in range(int(N/avx_len/miniblocks)):
            r = int(mb*N/avx_len/miniblocks) + rb
            add.append("\n\ttmp[" + str(r) + "] = ")
            for i in range(int(N/blocks)):
              add.append(avx_prefix(avx_len) + "_fmadd_pd(" + avx_prefix(avx_len) + "_permute_pd(v[" + str(i) + "], 5), mt[" + str(b*int(N/blocks)*int(N/avx_len)+r*int(N/blocks)+i) +"], ")
            add.append("tmp[" + str(r) + "]")
            add.append(")"*int(N/blocks)+";")
        
        if inline_FMAs and only_one_matrix and avx_len > 1:
          raise Exception("Not implemented yet!")
        
        for rb in range(int(N/avx_len/miniblocks)):
          r = int(mb*N/avx_len/miniblocks) + rb
          if b == blocks-1:
            add.append("\n\t")
            if avx_len > 1:
              add.append("store(")
            for i in range(avx_len):
              if avx_len > 1:
                add.append("(double*)&")
              add.append("psi[" + indices[avx_len*r+avx_len-i-1] + "], ")
            if avx_len == 1:
              add[-1] = add[-1][:-2] + " = "
            add.append("tmp[" + str(r) + "]);")
            if avx_len == 1:
              add[-1] = add[-1][:-2] + ";"
    else:
      add.append("\tfor (unsigned i = 0; i < " + str(int(N/avx_len)) + "; ++i){\n\t\ttmp[i] = ")
      for i in range(int(N/blocks)):
        add.append("fma(v[" + str(i) + "], m[" + str(b*int(N/blocks)*int(N/avx_len)) + " + i * "+str(int(N/blocks)) + " + " + str(i) +"], ")
        if not only_one_matrix:
          add.append("mt[" + str(b*int(N/blocks)*int(N/avx_len)) + " + i * " + str(int(N/blocks)) + " + " + str(i) +"], ")
      add.append("tmp[i]")
      add.append(")"*int(N/blocks)+";")
      add.append("\n\t}\n")
      if b == blocks-1:
        for r in range(int(N/avx_len)):
          add.append("\n\t")
          if avx_len > 1:
            add.append("store(")
          for i in range(avx_len):
            if avx_len > 1:
              add.append("(double*)&")
            add.append("psi[" + indices[avx_len*r+avx_len-i-1] + "], ")
          if avx_len == 1:
            add[-1] = add[-1][:-2] + " = "
          add.append("tmp[" + str(r) + "]);")
          if avx_len == 1:
            add[-1] = add[-1][:-2] + ";"
    
    add.append("\n")
    kernelarray.append("".join(add))
    add=[""]
  kernelarray.append("".join(add))
  kernelarray.append("\n}\n\n")

def generate_kernel(n, blocks, only_one_matrix, unroll_loops, avx_len):
  kernel = ""
  
  N = 1<<n
  idx = list(range(0,n))
  
  kernelarray = []
  generate_kernel_core(N,n,kernelarray,blocks,only_one_matrix,unroll_loops, avx_len)
  kernel = "".join([kernel, "".join(kernelarray)])
  
  
  
  kernelarray = []
  kernel = kernel + "// bit indices id[.] are given from high to low (e.g. control first for CNOT)\ntemplate <class V, class M>\n"
  kernel = kernel + "void kernel(V& psi"
  for i in range(n-1,-1,-1):
    kernel = kernel + ", unsigned id"+str(i)
  kernel = kernel + ", M const& matrix, std::size_t ctrlmask)\n{\n     std::size_t n = psi.size();\n"

  for i in idx:
    kernel = kernel + "\tstd::size_t d"+str(i)+" = 1ULL << id"+str(i)+";\n"
  
  kernel += ("\tauto m = matrix;\n"
            "\tstd::size_t dsorted[] = {")
  add =  ["d0"]
  for i in range(1,n):
    add.append(", d" + str(i))
  add.append("};\n")
  add.append("\tpermute_qubits_and_matrix(dsorted, " + str(n) + ", m);\n")
  kernel += "".join(add)
  
  if False:
    add = ["\n\t" + avx_type(avx_len) + " mm[] = {"]
    for b in range(blocks):
      for r in range(int(N/avx_len)):
        for c in range(int(N/blocks)):
          add.append("loada")
          if only_one_matrix:
            add[-1] = add[-1]+"b"
          add.append("(")
          for i in range(avx_len):
            add.append("&m["+str(avx_len*r+i)+"]["+str(c+b*int(N/blocks))+"], ")
          add[-1] = add[-1][:-2] + "), "
    add[-1] = add[-1][:-2] + "};\n"
  else:
    add = ["\n\t" + avx_type(avx_len) + " mm[" + str(N*int(N/avx_len)) + "];"]
    add.append("\n\tfor (unsigned b = 0; b < " + str(blocks) + "; ++b){"
               "\n\t\tfor (unsigned r = 0; r < " + str(int(N/avx_len)) + "; ++r){"
               "\n\t\t\tfor (unsigned c = 0; c < " + str(int(N/blocks)) + "; ++c){"
               "\n\t\t\t\tmm[b*"+str(int(N/avx_len)*int(N/blocks))+"+r*"+str(int(N/blocks))+"+c]"
               " = ")
    if avx_len > 1:
      add.append("loada")
      if only_one_matrix:
        add[-1] = add[-1]+"b"
      add.append("(")
      for i in range(avx_len):
        add.append("&m["+str(avx_len)+"*r+"+str(i)+"][c+b*"+str(int(N/blocks))+"], ")
      add[-1] = add[-1][:-2] + ");"
    else:
      add.append("m[r][c+b*"+str(int(N/blocks))+"];")
    add.append("\n\t\t\t}\n\t\t}\n\t}\n")
  kernelarray.append("".join(add))
  
  if False:
    add = ["\n\t" + avx_type(avx_len) + " mmt[] = {"]
    for b in range(blocks):
      for r in range(int(N/avx_len)):
        for c in range(int(N/blocks)):
          add.append("loadbm")
          add.append("(")
          for i in range(avx_len):
            add.append("&m["+str(avx_len*r+i)+"]["+str(c+b*int(N/blocks))+"], ")
          add[-1] = add[-1][:-2] + "), "
    add[-1] = add[-1][:-2] + "};\n"
  else:
    add = ["\n\t" + avx_type(avx_len) + " mmt[" + str(N*int(N/avx_len)) + "];"]
    add.append("\n\tfor (unsigned b = 0; b < " + str(blocks) + "; ++b){"
               "\n\t\tfor (unsigned r = 0; r < " + str(int(N/avx_len)) + "; ++r){"
               "\n\t\t\tfor (unsigned c = 0; c < " + str(int(N/blocks)) + "; ++c){"
               "\n\t\t\t\tmmt[b*"+str(int(N/avx_len)*int(N/blocks))+"+r*"+str(int(N/blocks))+"+c]"
               " = loadbm(")
    for i in range(avx_len):
      add.append("&m["+str(avx_len)+"*r+"+str(i)+"][c+b*"+str(int(N/blocks))+"], ")
    add[-1] = add[-1][:-2] + ");\n\t\t\t}\n\t\t}\n\t}\n"
  
  if only_one_matrix:
    add = []
  
  add.append("\n\n")
  kernelarray.append("".join(add))
  
  nc = len(idx)-1
  add = []
  indent = 1
  kernelarray.append("#ifndef _MSC_VER\n")
  kernelarray.append("\t"*indent + "if (ctrlmask == 0){\n")
  indent += 1
  kernelarray.append("\t"*indent + "#pragma omp for collapse(LOOP_COLLAPSE"+str(n)+") schedule(static)\n" + "\t"*indent + "for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){\n")
  indent = indent + 1
  for i in range(1,nc+1):
    kernelarray.append("\t"*indent + "for (std::size_t i"+str(i)+" = 0; i"+str(i)+" < dsorted["+str(i-1) + "]; i"+str(i)+" += 2 * dsorted["+str(i)+"]){\n")
    indent = indent + 1

  kernelarray.append("\t"*indent + "for (std::size_t i"+str(nc+1)+" = 0; i"+str(nc+1)+" < dsorted["+str(nc)+"]; ++i"+str(nc+1)+"){\n")
  indent = indent + 1

  # inner-most loop: call kernel core


  kernelarray.append("\t"*indent + "kernel_core(psi, i0")
  add = []
  for i in range(n):
    add.append(" + i"+str(i+1))
  kernelarray.append("".join(add))
  for i in range(n):
    kernelarray.append(", dsorted[" + str(n-1-i) + "]")

  if only_one_matrix:
    kernelarray.append(", mm);\n")
  else:
    kernelarray.append(", mm, mmt);\n")

  #end for(s) and if
  add = [""]*indent
  for i in range(indent-1,0,-1):
    add[indent-1-i] = "\t"*i+"}\n"
  kernelarray.append("".join(add))

  # if controlmask != 0
  indent = 1
  kernelarray.append("\t"*indent + "else{\n")
  indent += 1
  kernelarray.append("\t"*indent + "#pragma omp for collapse(LOOP_COLLAPSE"+str(n)+") schedule(static)\n" + "\t"*indent + "for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){\n")
  indent = indent + 1
  for i in range(1,nc+1):
    kernelarray.append("\t"*indent + "for (std::size_t i"+str(i)+" = 0; i"+str(i)+" < dsorted["+str(i-1) + "]; i"+str(i)+" += 2 * dsorted["+str(i)+"]){\n")
    indent = indent + 1

  kernelarray.append("\t"*indent + "for (std::size_t i"+str(nc+1)+" = 0; i"+str(nc+1)+" < dsorted["+str(nc)+"]; ++i"+str(nc+1)+"){\n")
  indent = indent + 1

  # inner-most loop: call kernel core

  kernelarray.append("\t"*indent + "if (((i0")
  add = []
  for i in range(n):
    add.append(" + i"+str(i+1))
  kernelarray.append("".join(add))
  kernelarray.append(")&ctrlmask) == ctrlmask)\n")
  kernelarray.append("\t"*(indent+1) + "kernel_core(psi, i0")
  add = []
  for i in range(n):
    add.append(" + i"+str(i+1))
  kernelarray.append("".join(add))
  for i in range(n):
    kernelarray.append(", dsorted[" + str(n-1-i) + "]")

  if only_one_matrix:
    kernelarray.append(", mm);\n")
  else:
    kernelarray.append(", mm, mmt);\n")

  #end for(s) and if
  add = [""]*indent
  for i in range(indent-1,0,-1):
    add[indent-1-i] = "\t"*i+"}\n"
  kernelarray.append("".join(add))


  kernelarray.append("#else\n")
  indent = 1
  kernelarray.append("\t" + "std::intptr_t zero = 0;\n")
  kernelarray.append("\t" + "std::intptr_t dmask = dsorted[0]");
  for i in range(n-1):
       kernelarray.append(" + dsorted["+str(i+1)+"]")
  kernelarray.append(";\n")
  kernelarray.append("\n\t"*indent + "if (ctrlmask == 0){\n")
  indent += 1
  kernelarray.append("\t"*indent + "#pragma omp parallel for schedule(static)\n" + "\t"*indent + "for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)\n")
  indent += 1
  kernelarray.append("\t"*indent+"if ((i & dmask) == zero)\n")
  indent += 1
  kernelarray.append("\t"*indent + "kernel_core(psi, i")
  for i in range(n):
    kernelarray.append(", dsorted[" + str(n-1-i) + "]")
  if only_one_matrix:
    kernelarray.append(", mm);\n")
  else:
    kernelarray.append(", mm, mmt);\n")
  # if controlmask != 0
  indent = 1
  indent=1
  kernelarray.append("\t"*indent + "} else {\n")
  indent += 1
  kernelarray.append("\t"*indent + "#pragma omp parallel for schedule(static)\n" + "\t"*indent + "for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)\n")
  indent += 1
  kernelarray.append("\t"*indent+"if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)\n")
  indent += 1
  kernelarray.append("\t"*indent + "kernel_core(psi, i")
  for i in range(n):
    kernelarray.append(", dsorted[" + str(n-1-i) + "]")
  if only_one_matrix:
    kernelarray.append(", mm);\n")
  else:
    kernelarray.append(", mm, mmt);\n")
  indent=1
  kernelarray.append("\t"*indent + "}\n")
  kernelarray.append("#endif\n")

  kernelarray.append("}\n")
  kernel = "".join([kernel,"".join(kernelarray)])
  return kernel

def generate_includes(N):
  return "#include <cassert>\n#include <iostream>\n#include <vector>\n#include <complex>\n#include <cstdlib>\n#include <omp.h>\n#include \"alignedallocator.hpp\"\n#include \"timing.hpp\"\n#include \"cintrin.hpp\"\n#include <algorithm>\n#include <functional>\n\nusing namespace std;\n#define LOOP_COLLAPSE" + str(N) + " " + str(N+1) + "\n"

def generate_main(n):
  N = str(1 << n)
  text = "using rowtype = vector<complex<double>,aligned_allocator<complex<double>,64>>;\nusing matrixtype = vector<rowtype>;\n\nint main(int argc, char *argv[]){"
  text = text + "\n\tassert(argc > "+str(1+n)+");"
  text = text + "\n\tsize_t N = 1ULL << atoi(argv[1]);"
  for i in range(n):
    text = text + "\n\tunsigned i" + str(i) + " = atoi(argv[" + str(i+2) + "]);"
  
  text = text + "\n\tmatrixtype m("+N+", rowtype("+N+"));";
  text = text + "\n\tfor (unsigned i = 0; i < "+N+"; ++i)\n\t\tfor (unsigned j = 0; j < "+N+"; ++j)\n\t\t\tm[i][j] = drand48();\n"
  
  text = text + "\n\tTimer t;\n\tfor (unsigned threads = 1; threads <= 24; ++threads){"
  text = text + "\n\t\tomp_set_num_threads(threads);"
  text = text + "\n\t\trowtype psi(N);\n\t\t#pragma omp parallel\n\t\t{\n\t\t\t#pragma omp for schedule(static)\n\t\t\tfor (size_t i = 0; i < psi.size(); ++i)\n\t\t\t\tpsi[i] = drand48();\n"
  text = text + "\n\t\t\t#pragma omp single\n\t\t\tt.start();"
  text = text + "\n\t\t\tkernel(psi, N"
  for i in range(n):
    text = text + ", i" + str(i)
  text = text + ", m, 0);"
  text = text + "\n\t\t\t#pragma omp waitall\n\t\t\t#pragma omp single\n\t\t\t{ cout << \"threads: \" << threads << \", time:\" << t.stop()*1.e-6 << \"\\n\"; }"
  text = text + "\n\t\t}" # end for
  text = text + "\n\t}" # end for
  text = text + "\n\n}" # end main
  return text


#####################################################
# MAIN                                              #
#####################################################

if len(sys.argv) < 2:
  print("Generates the code for an n-qubit gate.\nUsage:\n./codegen_fma.py [n_qubits] {n_blocks} {only one matrix?} {unroll loops?} {none|avx2|avx512}\n\n")
  exit()

n = int(sys.argv[1]) # number of qubits

try: # number of blocks
  blocks = int(sys.argv[2])
except Exception:
  blocks = 1

try:
  only_one_matrix = int(sys.argv[3])
except Exception:
  only_one_matrix = False

try:
  unroll_loops = int(sys.argv[4])
except Exception:
  unroll_loops = False

try:
  avx = str(sys.argv[5])
  if avx == "avx512":
    avx = 4
  elif avx == "avx2" or avx == "avx":
    avx = 2
  elif avx == "none":
    avx = 1
    only_one_matrix = True
  else:
    raise RuntimeError("Unknown avx type: {}".format(avx))
except IndexError:
  avx = 2

while (1 << n)/blocks < 1:
  blocks = int(blocks/2)

if (1 << n) < avx:
  avx = int(avx/2)

kernel = generate_kernel(n, blocks, only_one_matrix, unroll_loops, avx) # generate code for n-qubit gate

# if user wants a main (for testing) generate as well:
for a in sys.argv:
  if str(a) == "gen_main":
    kernel = generate_includes(n) + kernel + generate_main(n)

print(kernel)
