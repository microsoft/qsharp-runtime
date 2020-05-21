// (C) 2018 ETH Zurich, ITP, Thomas H�ner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, M const& m, M const& mt)
{
	__m512d v[1];

	v[0] = load1x4(&psi[I]);

	__m512d tmp[2] = {_mm512_setzero_pd(), _mm512_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], mt[1], tmp[1]);

	v[0] = load1x4(&psi[I + d0]);

	tmp[0] = fma(v[0], m[2], mt[2], tmp[0]);
	tmp[1] = fma(v[0], m[3], mt[3], tmp[1]);

	v[0] = load1x4(&psi[I + d1]);

	tmp[0] = fma(v[0], m[4], mt[4], tmp[0]);
	tmp[1] = fma(v[0], m[5], mt[5], tmp[1]);

	v[0] = load1x4(&psi[I + d0 + d1]);

	tmp[0] = fma(v[0], m[6], mt[6], tmp[0]);
	tmp[1] = fma(v[0], m[7], mt[7], tmp[1]);

	v[0] = load1x4(&psi[I + d2]);

	tmp[0] = fma(v[0], m[8], mt[8], tmp[0]);
	tmp[1] = fma(v[0], m[9], mt[9], tmp[1]);

	v[0] = load1x4(&psi[I + d0 + d2]);

	tmp[0] = fma(v[0], m[10], mt[10], tmp[0]);
	tmp[1] = fma(v[0], m[11], mt[11], tmp[1]);

	v[0] = load1x4(&psi[I + d1 + d2]);

	tmp[0] = fma(v[0], m[12], mt[12], tmp[0]);
	tmp[1] = fma(v[0], m[13], mt[13], tmp[1]);

	v[0] = load1x4(&psi[I + d0 + d1 + d2]);

	tmp[0] = fma(v[0], m[14], mt[14], tmp[0]);
	tmp[1] = fma(v[0], m[15], mt[15], tmp[1]);
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], (double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], (double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[1]);

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id2, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	std::size_t d2 = 1ULL << id2;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1, d2};
	permute_qubits_and_matrix(dsorted, 3, m);

	__m512d mm[16];
	for (unsigned b = 0; b < 8; ++b){
		for (unsigned r = 0; r < 2; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*2+r*1+c] = loada(&m[4*r+0][c+b*1], &m[4*r+1][c+b*1], &m[4*r+2][c+b*1], &m[4*r+3][c+b*1]);
			}
		}
	}

	__m512d mmt[16];
	for (unsigned b = 0; b < 8; ++b){
		for (unsigned r = 0; r < 2; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mmt[b*2+r*1+c] = loadbm(&m[4*r+0][c+b*1], &m[4*r+1][c+b*1], &m[4*r+2][c+b*1], &m[4*r+3][c+b*1]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE3) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; ++i3){
						kernel_core(psi, i0 + i1 + i2 + i3, dsorted[2], dsorted[1], dsorted[0], mm, mmt);
					}
				}
			}
		}
	}
	else{
		#pragma omp parallel for collapse(LOOP_COLLAPSE3) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; ++i3){
						if (((i0 + i1 + i2 + i3)&ctrlmask) == ctrlmask)
							kernel_core(psi, i0 + i1 + i2 + i3, dsorted[2], dsorted[1], dsorted[0], mm, mmt);
					}
				}
			}
		}
	}
#else
    std::intptr_t zero = 0;
    std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2];

    if (ctrlmask == 0){
        auto thrdFnc= [](intptr_t& dmask, std::intptr_t& zero,V &psi,M const& m,M const& mt) {
            return [&](unsigned i) {
                if ((i & dmask) == zero)
                    kernel_core(psi, i, dsorted[2], dsorted[1], dsorted[0], m, mt);
            }
        pl::async_par_for(0,outer,thrdFnc(dmask,zero,psi,m,mt),thrds);
     } else {
        auto thrdFnc= [](intptr_t& ctrlmask,intptr_t& dmask, std::intptr_t& zero,V &psi,M const& m,M const& mt) {
            return [&](unsigned i) {
                if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
                    kernel_core(psi, i, dsorted[2], dsorted[1], dsorted[0], m, mt);
            }
        pl::async_par_for(0,outer,thrdFnc(ctrlmask,dmask,zero,psi,m,mt),thrds);
     }
#endif
}

