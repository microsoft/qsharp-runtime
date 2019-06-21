// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#ifndef KERNELS_HPP_
#define KERNELS_HPP_

#include <cmath>
#include <cstdlib>
#include <vector>
#include <complex>
#include <functional>
#include <algorithm>
#include "../cintrin.hpp"
#include "util/alignedalloc.hpp"

#define LOOP_COLLAPSE1 2
#define LOOP_COLLAPSE2 3
#define LOOP_COLLAPSE3 4
#define LOOP_COLLAPSE4 5
#define LOOP_COLLAPSE5 6
#define LOOP_COLLAPSE6 7
#define LOOP_COLLAPSE7 8

#include "kernel1.hpp"
#include "kernel2.hpp"
#include "kernel3.hpp"
#include "kernel4.hpp"
#include "kernel5.hpp"
#include "kernel6.hpp"
#include "kernel7.hpp"

#endif
