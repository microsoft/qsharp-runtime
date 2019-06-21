// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#ifndef KERNEL_DEFS_HPP_
#define KERNEL_DEFS_HPP_

#include <vector>
#include <complex>
#include <kernels.hpp>

using complex = std::complex<double>;
using rtype = std::vector<complex>;
using mtype = std::vector<rtype>;

extern template void kernel(complex*, std::size_t, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);
extern template void kernel(complex*, std::size_t, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, mtype const&, std::size_t);


#endif
