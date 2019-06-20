// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#include "kernels.hpp"
#include <vector>
#include <complex>
#include <iostream>

using complex = std::complex<double>;
using rtype = std::vector<complex>;
using mtype = std::vector<rtype>;

template void kernel<complex,mtype>(complex*, std::size_t, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
template void kernel<complex,mtype>(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
