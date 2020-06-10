// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, M const& m)
{
	std::complex<double> v[1];

	v[0] = psi[I];

	std::complex<double> tmp[8] = {0., 0., 0., 0., 0., 0., 0., 0.};

	tmp[0] = fma(v[0], m[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], tmp[1]);
	tmp[2] = fma(v[0], m[2], tmp[2]);
	tmp[3] = fma(v[0], m[3], tmp[3]);
	tmp[4] = fma(v[0], m[4], tmp[4]);
	tmp[5] = fma(v[0], m[5], tmp[5]);
	tmp[6] = fma(v[0], m[6], tmp[6]);
	tmp[7] = fma(v[0], m[7], tmp[7]);

	v[0] = psi[I + d0];

	tmp[0] = fma(v[0], m[8], tmp[0]);
	tmp[1] = fma(v[0], m[9], tmp[1]);
	tmp[2] = fma(v[0], m[10], tmp[2]);
	tmp[3] = fma(v[0], m[11], tmp[3]);
	tmp[4] = fma(v[0], m[12], tmp[4]);
	tmp[5] = fma(v[0], m[13], tmp[5]);
	tmp[6] = fma(v[0], m[14], tmp[6]);
	tmp[7] = fma(v[0], m[15], tmp[7]);

	v[0] = psi[I + d1];

	tmp[0] = fma(v[0], m[16], tmp[0]);
	tmp[1] = fma(v[0], m[17], tmp[1]);
	tmp[2] = fma(v[0], m[18], tmp[2]);
	tmp[3] = fma(v[0], m[19], tmp[3]);
	tmp[4] = fma(v[0], m[20], tmp[4]);
	tmp[5] = fma(v[0], m[21], tmp[5]);
	tmp[6] = fma(v[0], m[22], tmp[6]);
	tmp[7] = fma(v[0], m[23], tmp[7]);

	v[0] = psi[I + d0 + d1];

	tmp[0] = fma(v[0], m[24], tmp[0]);
	tmp[1] = fma(v[0], m[25], tmp[1]);
	tmp[2] = fma(v[0], m[26], tmp[2]);
	tmp[3] = fma(v[0], m[27], tmp[3]);
	tmp[4] = fma(v[0], m[28], tmp[4]);
	tmp[5] = fma(v[0], m[29], tmp[5]);
	tmp[6] = fma(v[0], m[30], tmp[6]);
	tmp[7] = fma(v[0], m[31], tmp[7]);

	v[0] = psi[I + d2];

	tmp[0] = fma(v[0], m[32], tmp[0]);
	tmp[1] = fma(v[0], m[33], tmp[1]);
	tmp[2] = fma(v[0], m[34], tmp[2]);
	tmp[3] = fma(v[0], m[35], tmp[3]);
	tmp[4] = fma(v[0], m[36], tmp[4]);
	tmp[5] = fma(v[0], m[37], tmp[5]);
	tmp[6] = fma(v[0], m[38], tmp[6]);
	tmp[7] = fma(v[0], m[39], tmp[7]);

	v[0] = psi[I + d0 + d2];

	tmp[0] = fma(v[0], m[40], tmp[0]);
	tmp[1] = fma(v[0], m[41], tmp[1]);
	tmp[2] = fma(v[0], m[42], tmp[2]);
	tmp[3] = fma(v[0], m[43], tmp[3]);
	tmp[4] = fma(v[0], m[44], tmp[4]);
	tmp[5] = fma(v[0], m[45], tmp[5]);
	tmp[6] = fma(v[0], m[46], tmp[6]);
	tmp[7] = fma(v[0], m[47], tmp[7]);

	v[0] = psi[I + d1 + d2];

	tmp[0] = fma(v[0], m[48], tmp[0]);
	tmp[1] = fma(v[0], m[49], tmp[1]);
	tmp[2] = fma(v[0], m[50], tmp[2]);
	tmp[3] = fma(v[0], m[51], tmp[3]);
	tmp[4] = fma(v[0], m[52], tmp[4]);
	tmp[5] = fma(v[0], m[53], tmp[5]);
	tmp[6] = fma(v[0], m[54], tmp[6]);
	tmp[7] = fma(v[0], m[55], tmp[7]);

	v[0] = psi[I + d0 + d1 + d2];

	tmp[0] = fma(v[0], m[56], tmp[0]);
	tmp[1] = fma(v[0], m[57], tmp[1]);
	tmp[2] = fma(v[0], m[58], tmp[2]);
	tmp[3] = fma(v[0], m[59], tmp[3]);
	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];
	psi[I + d1] = tmp[2];
	psi[I + d0 + d1] = tmp[3];
	tmp[4] = fma(v[0], m[60], tmp[4]);
	tmp[5] = fma(v[0], m[61], tmp[5]);
	tmp[6] = fma(v[0], m[62], tmp[6]);
	tmp[7] = fma(v[0], m[63], tmp[7]);
	psi[I + d2] = tmp[4];
	psi[I + d0 + d2] = tmp[5];
	psi[I + d1 + d2] = tmp[6];
	psi[I + d0 + d1 + d2] = tmp[7];

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

	std::complex<double> mm[64];
	for (unsigned b = 0; b < 8; ++b){
		for (unsigned r = 0; r < 8; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*8+r*1+c] = m[r][c+b*1];
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
						kernel_core(psi, i0 + i1 + i2 + i3, dsorted[2], dsorted[1], dsorted[0], mm);
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
							kernel_core(psi, i0 + i1 + i2 + i3, dsorted[2], dsorted[1], dsorted[0], mm);
					}
				}
			}
		}
	}
#else
	std::intptr_t zero = 0;
	std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[2], dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[2], dsorted[1], dsorted[0], mm);
	}
#endif
}

