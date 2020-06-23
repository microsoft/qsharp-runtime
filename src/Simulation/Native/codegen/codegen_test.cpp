#include <cassert>
#include <iostream>
#include <vector>
#include <complex>
#include <cstdlib>
#include <omp.h>
#include "alignedalloc.hpp"
//#include "timing.hpp"
#include "cintrin.hpp"
#include <algorithm>
#include <functional>

#include "util/par_for.hpp"
using namespace std;
#define LOOP_COLLAPSE1 2
// (C) 2018 ETH Zurich, ITP, Thomas H�ner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, M const& m)
{
	std::complex<double> v[2];

	v[0] = psi[I];
	v[1] = psi[I + d0];

	std::complex<double> tmp[2] = {0., 0.};

	tmp[0] = fma(v[0], m[0], fma(v[1], m[1], tmp[0]));
	tmp[1] = fma(v[0], m[2], fma(v[1], m[3], tmp[1]));
	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	auto m = matrix;
	std::size_t dsorted[] = {d0};
	permute_qubits_and_matrix(dsorted, 1, m);

	std::complex<double> mm[4];
	for (unsigned b = 0; b < 1; ++b){
		for (unsigned r = 0; r < 2; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mm[b*4+r*2+c] = m[r][c+b*2];
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE1) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; ++i1){
				kernel_core(psi, i0 + i1, dsorted[0], mm);
			}
		}
	}
	else{
		#pragma omp parallel for collapse(LOOP_COLLAPSE1) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; ++i1){
				if (((i0 + i1)&ctrlmask) == ctrlmask)
					kernel_core(psi, i0 + i1, dsorted[0], mm);
			}
		}
	}
#else
    intptr_t zero = 0;
    intptr_t dmask = dsorted[0];

    if (ctrlmask == 0){
        auto thrdFnc= [&](size_t dsorted[],intptr_t& dmask, intptr_t& zero,V &psi,M const& m) {
            return [&](unsigned i) {
                if ((i & dmask) == zero)
                    kernel_core(psi, i, dsorted[0], m);
            };
        };
        pl::async_par_for(0,n,thrdFnc(dsorted,dmask,zero,psi,m));
     } else {
        auto thrdFnc= [&](size_t dsorted[],size_t& ctrlmask,intptr_t& dmask, intptr_t& zero,V &psi,M const& m) {
            return [&](unsigned i) {
                if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
                    kernel_core(psi, i, dsorted[0], m);
            };
        };
        pl::async_par_for(0,n,thrdFnc(dsorted,ctrlmask,dmask,zero,psi,m));
     }
#endif
}
using rowtype = vector<complex<double>,AlignedAlloc<complex<double>,64>>;
using matrixtype = vector<rowtype>;

int main(int argc, char *argv[]){
	assert(argc > 2);
	size_t N = 1ULL << atoi(argv[1]);
	unsigned i0 = atoi(argv[2]);
	matrixtype m(2, rowtype(2));
	for (unsigned i = 0; i < 2; ++i)
		for (unsigned j = 0; j < 2; ++j)
			m[i][j] = drand48();

	Timer t;
	for (unsigned threads = 1; threads <= 24; ++threads){
		omp_set_num_threads(threads);
		rowtype psi(N);
		#pragma omp parallel
		{
			#pragma omp for schedule(static)
			for (size_t i = 0; i < psi.size(); ++i)
				psi[i] = drand48();

			#pragma omp single
			t.start();
			kernel(psi, N, i0, m, 0);
			#pragma omp waitall
			#pragma omp single
			{ cout << "threads: " << threads << ", time:" << t.stop()*1.e-6 << "\n"; }
		}
	}

}
