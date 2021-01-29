// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, M const& m)
{
	std::complex<double> v[1];

	v[0] = psi[I];

	std::complex<double> tmp[4] = {0., 0., 0., 0.};

	tmp[0] = fma(v[0], m[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], tmp[1]);
	tmp[2] = fma(v[0], m[2], tmp[2]);
	tmp[3] = fma(v[0], m[3], tmp[3]);

	v[0] = psi[I + d0];

	tmp[0] = fma(v[0], m[4], tmp[0]);
	tmp[1] = fma(v[0], m[5], tmp[1]);
	tmp[2] = fma(v[0], m[6], tmp[2]);
	tmp[3] = fma(v[0], m[7], tmp[3]);

	v[0] = psi[I + d1];

	tmp[0] = fma(v[0], m[8], tmp[0]);
	tmp[1] = fma(v[0], m[9], tmp[1]);
	tmp[2] = fma(v[0], m[10], tmp[2]);
	tmp[3] = fma(v[0], m[11], tmp[3]);

	v[0] = psi[I + d0 + d1];

	tmp[0] = fma(v[0], m[12], tmp[0]);
	tmp[1] = fma(v[0], m[13], tmp[1]);
	tmp[2] = fma(v[0], m[14], tmp[2]);
	tmp[3] = fma(v[0], m[15], tmp[3]);
	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];
	psi[I + d1] = tmp[2];
	psi[I + d0 + d1] = tmp[3];

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1};
	permute_qubits_and_matrix(dsorted, 2, m);

	std::complex<double> mm[16];
	for (unsigned b = 0; b < 4; ++b){
		for (unsigned r = 0; r < 4; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*4+r*1+c] = m[r][c+b*1];
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE2) schedule(static) proc_bind(spread)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; ++i2){
					kernel_core(psi, i0 + i1 + i2, dsorted[1], dsorted[0], mm);
				}
			}
		}
	}
	else{
		#pragma omp parallel for collapse(LOOP_COLLAPSE2) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; ++i2){
					if (((i0 + i1 + i2)&ctrlmask) == ctrlmask)
						kernel_core(psi, i0 + i1 + i2, dsorted[1], dsorted[0], mm);
				}
			}
		}
	}
#else
	std::intptr_t zero = 0;
	std::intptr_t dmask = dsorted[0] + dsorted[1];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[1], dsorted[0], mm);
	}
#endif
}

