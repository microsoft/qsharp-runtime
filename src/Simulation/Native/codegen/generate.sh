#!/bin/bash
# (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

# onematrix[i] determines whether to use a single gate matrix for the i-qubit gate kernel
# instead of using two matrices (which allows to reduce the number of operations
# by pre-computation)
onematrix=(0 0 0 0 0 0 1 1) # g++ best
#onematrix=(0 0 1 0 0 0 1 1) # icc best

# unroll[i] determines whether to unroll loops
unroll=(1 1 1 1 1 1 0 0) # g++ best
#unroll=(1 1 1 0 0 1 0 0) # icc best
#unroll=(0 0 0 0 0 0 0 0)

# register length to use: can be none, avx2, or avx512
avx=avx2

# blocking: must be a power of two and at most 2^k for a k-qubit gate
b=(0 2 4 8 16 16 16 32) # gcc & icc best

for i in {1..7}
do
	echo "Generating $i kernel with ${b[$i]} blocks."
	./codegen_fma.py $i ${b[$i]} ${onematrix[$i]} ${unroll[$i]} none > ../nointrin/kernel${i}.hpp
	./codegen_fma.py $i ${b[$i]} ${onematrix[$i]} ${unroll[$i]} avx > ../avx/kernel${i}.hpp
	./codegen_fma.py $i ${b[$i]} ${onematrix[$i]} ${unroll[$i]} avx2 > ../avx2/kernel${i}.hpp
  ./codegen_fma.py $i ${b[$i]} ${onematrix[$i]} ${unroll[$i]} avx512 > ../avx512/kernel${i}.hpp
done
