// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, M const& m, M const& mt)
{
	__m256d v[1];

	v[0] = load1(&psi[I]);

	__m256d tmp[1] = {_mm256_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], tmp[0]);

	v[0] = load1(&psi[I + d0]);

	tmp[0] = fma(v[0], m[1], mt[1], tmp[0]);
	store((double*)&psi[I + d0], (double*)&psi[I], tmp[0]);

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

	__m256d mm[2];
	for (unsigned b = 0; b < 2; ++b){
		for (unsigned r = 0; r < 1; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*1+r*1+c] = loada(&m[2*r+0][c+b*1], &m[2*r+1][c+b*1]);
			}
		}
	}

	__m256d mmt[2];
	for (unsigned b = 0; b < 2; ++b){
		for (unsigned r = 0; r < 1; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mmt[b*1+r*1+c] = loadbm(&m[2*r+0][c+b*1], &m[2*r+1][c+b*1]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE1) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; ++i1){
				kernel_core(psi, i0 + i1, dsorted[0], mm, mmt);
			}
		}
	}
	else{
		#pragma omp parallel for collapse(LOOP_COLLAPSE1) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; ++i1){
				if (((i0 + i1)&ctrlmask) == ctrlmask)
					kernel_core(psi, i0 + i1, dsorted[0], mm, mmt);
			}
		}
	}
#else
	std::intptr_t zero = 0;
	std::intptr_t dmask = dsorted[0];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[0], mm, mmt);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[0], mm, mmt);
	}
#endif
}

