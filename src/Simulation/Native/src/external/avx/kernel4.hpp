// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, M const& m, M const& mt)
{
	__m256d v[1];

	v[0] = load1(&psi[I]);

	__m256d tmp[8] = {_mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], mt[1], tmp[1]);
	tmp[2] = fma(v[0], m[2], mt[2], tmp[2]);
	tmp[3] = fma(v[0], m[3], mt[3], tmp[3]);
	tmp[4] = fma(v[0], m[4], mt[4], tmp[4]);
	tmp[5] = fma(v[0], m[5], mt[5], tmp[5]);
	tmp[6] = fma(v[0], m[6], mt[6], tmp[6]);
	tmp[7] = fma(v[0], m[7], mt[7], tmp[7]);

	v[0] = load1(&psi[I + d0]);

	tmp[0] = fma(v[0], m[8], mt[8], tmp[0]);
	tmp[1] = fma(v[0], m[9], mt[9], tmp[1]);
	tmp[2] = fma(v[0], m[10], mt[10], tmp[2]);
	tmp[3] = fma(v[0], m[11], mt[11], tmp[3]);
	tmp[4] = fma(v[0], m[12], mt[12], tmp[4]);
	tmp[5] = fma(v[0], m[13], mt[13], tmp[5]);
	tmp[6] = fma(v[0], m[14], mt[14], tmp[6]);
	tmp[7] = fma(v[0], m[15], mt[15], tmp[7]);

	v[0] = load1(&psi[I + d1]);

	tmp[0] = fma(v[0], m[16], mt[16], tmp[0]);
	tmp[1] = fma(v[0], m[17], mt[17], tmp[1]);
	tmp[2] = fma(v[0], m[18], mt[18], tmp[2]);
	tmp[3] = fma(v[0], m[19], mt[19], tmp[3]);
	tmp[4] = fma(v[0], m[20], mt[20], tmp[4]);
	tmp[5] = fma(v[0], m[21], mt[21], tmp[5]);
	tmp[6] = fma(v[0], m[22], mt[22], tmp[6]);
	tmp[7] = fma(v[0], m[23], mt[23], tmp[7]);

	v[0] = load1(&psi[I + d0 + d1]);

	tmp[0] = fma(v[0], m[24], mt[24], tmp[0]);
	tmp[1] = fma(v[0], m[25], mt[25], tmp[1]);
	tmp[2] = fma(v[0], m[26], mt[26], tmp[2]);
	tmp[3] = fma(v[0], m[27], mt[27], tmp[3]);
	tmp[4] = fma(v[0], m[28], mt[28], tmp[4]);
	tmp[5] = fma(v[0], m[29], mt[29], tmp[5]);
	tmp[6] = fma(v[0], m[30], mt[30], tmp[6]);
	tmp[7] = fma(v[0], m[31], mt[31], tmp[7]);

	v[0] = load1(&psi[I + d2]);

	tmp[0] = fma(v[0], m[32], mt[32], tmp[0]);
	tmp[1] = fma(v[0], m[33], mt[33], tmp[1]);
	tmp[2] = fma(v[0], m[34], mt[34], tmp[2]);
	tmp[3] = fma(v[0], m[35], mt[35], tmp[3]);
	tmp[4] = fma(v[0], m[36], mt[36], tmp[4]);
	tmp[5] = fma(v[0], m[37], mt[37], tmp[5]);
	tmp[6] = fma(v[0], m[38], mt[38], tmp[6]);
	tmp[7] = fma(v[0], m[39], mt[39], tmp[7]);

	v[0] = load1(&psi[I + d0 + d2]);

	tmp[0] = fma(v[0], m[40], mt[40], tmp[0]);
	tmp[1] = fma(v[0], m[41], mt[41], tmp[1]);
	tmp[2] = fma(v[0], m[42], mt[42], tmp[2]);
	tmp[3] = fma(v[0], m[43], mt[43], tmp[3]);
	tmp[4] = fma(v[0], m[44], mt[44], tmp[4]);
	tmp[5] = fma(v[0], m[45], mt[45], tmp[5]);
	tmp[6] = fma(v[0], m[46], mt[46], tmp[6]);
	tmp[7] = fma(v[0], m[47], mt[47], tmp[7]);

	v[0] = load1(&psi[I + d1 + d2]);

	tmp[0] = fma(v[0], m[48], mt[48], tmp[0]);
	tmp[1] = fma(v[0], m[49], mt[49], tmp[1]);
	tmp[2] = fma(v[0], m[50], mt[50], tmp[2]);
	tmp[3] = fma(v[0], m[51], mt[51], tmp[3]);
	tmp[4] = fma(v[0], m[52], mt[52], tmp[4]);
	tmp[5] = fma(v[0], m[53], mt[53], tmp[5]);
	tmp[6] = fma(v[0], m[54], mt[54], tmp[6]);
	tmp[7] = fma(v[0], m[55], mt[55], tmp[7]);

	v[0] = load1(&psi[I + d0 + d1 + d2]);

	tmp[0] = fma(v[0], m[56], mt[56], tmp[0]);
	tmp[1] = fma(v[0], m[57], mt[57], tmp[1]);
	tmp[2] = fma(v[0], m[58], mt[58], tmp[2]);
	tmp[3] = fma(v[0], m[59], mt[59], tmp[3]);
	tmp[4] = fma(v[0], m[60], mt[60], tmp[4]);
	tmp[5] = fma(v[0], m[61], mt[61], tmp[5]);
	tmp[6] = fma(v[0], m[62], mt[62], tmp[6]);
	tmp[7] = fma(v[0], m[63], mt[63], tmp[7]);

	v[0] = load1(&psi[I + d3]);

	tmp[0] = fma(v[0], m[64], mt[64], tmp[0]);
	tmp[1] = fma(v[0], m[65], mt[65], tmp[1]);
	tmp[2] = fma(v[0], m[66], mt[66], tmp[2]);
	tmp[3] = fma(v[0], m[67], mt[67], tmp[3]);
	tmp[4] = fma(v[0], m[68], mt[68], tmp[4]);
	tmp[5] = fma(v[0], m[69], mt[69], tmp[5]);
	tmp[6] = fma(v[0], m[70], mt[70], tmp[6]);
	tmp[7] = fma(v[0], m[71], mt[71], tmp[7]);

	v[0] = load1(&psi[I + d0 + d3]);

	tmp[0] = fma(v[0], m[72], mt[72], tmp[0]);
	tmp[1] = fma(v[0], m[73], mt[73], tmp[1]);
	tmp[2] = fma(v[0], m[74], mt[74], tmp[2]);
	tmp[3] = fma(v[0], m[75], mt[75], tmp[3]);
	tmp[4] = fma(v[0], m[76], mt[76], tmp[4]);
	tmp[5] = fma(v[0], m[77], mt[77], tmp[5]);
	tmp[6] = fma(v[0], m[78], mt[78], tmp[6]);
	tmp[7] = fma(v[0], m[79], mt[79], tmp[7]);

	v[0] = load1(&psi[I + d1 + d3]);

	tmp[0] = fma(v[0], m[80], mt[80], tmp[0]);
	tmp[1] = fma(v[0], m[81], mt[81], tmp[1]);
	tmp[2] = fma(v[0], m[82], mt[82], tmp[2]);
	tmp[3] = fma(v[0], m[83], mt[83], tmp[3]);
	tmp[4] = fma(v[0], m[84], mt[84], tmp[4]);
	tmp[5] = fma(v[0], m[85], mt[85], tmp[5]);
	tmp[6] = fma(v[0], m[86], mt[86], tmp[6]);
	tmp[7] = fma(v[0], m[87], mt[87], tmp[7]);

	v[0] = load1(&psi[I + d0 + d1 + d3]);

	tmp[0] = fma(v[0], m[88], mt[88], tmp[0]);
	tmp[1] = fma(v[0], m[89], mt[89], tmp[1]);
	tmp[2] = fma(v[0], m[90], mt[90], tmp[2]);
	tmp[3] = fma(v[0], m[91], mt[91], tmp[3]);
	tmp[4] = fma(v[0], m[92], mt[92], tmp[4]);
	tmp[5] = fma(v[0], m[93], mt[93], tmp[5]);
	tmp[6] = fma(v[0], m[94], mt[94], tmp[6]);
	tmp[7] = fma(v[0], m[95], mt[95], tmp[7]);

	v[0] = load1(&psi[I + d2 + d3]);

	tmp[0] = fma(v[0], m[96], mt[96], tmp[0]);
	tmp[1] = fma(v[0], m[97], mt[97], tmp[1]);
	tmp[2] = fma(v[0], m[98], mt[98], tmp[2]);
	tmp[3] = fma(v[0], m[99], mt[99], tmp[3]);
	tmp[4] = fma(v[0], m[100], mt[100], tmp[4]);
	tmp[5] = fma(v[0], m[101], mt[101], tmp[5]);
	tmp[6] = fma(v[0], m[102], mt[102], tmp[6]);
	tmp[7] = fma(v[0], m[103], mt[103], tmp[7]);

	v[0] = load1(&psi[I + d0 + d2 + d3]);

	tmp[0] = fma(v[0], m[104], mt[104], tmp[0]);
	tmp[1] = fma(v[0], m[105], mt[105], tmp[1]);
	tmp[2] = fma(v[0], m[106], mt[106], tmp[2]);
	tmp[3] = fma(v[0], m[107], mt[107], tmp[3]);
	tmp[4] = fma(v[0], m[108], mt[108], tmp[4]);
	tmp[5] = fma(v[0], m[109], mt[109], tmp[5]);
	tmp[6] = fma(v[0], m[110], mt[110], tmp[6]);
	tmp[7] = fma(v[0], m[111], mt[111], tmp[7]);

	v[0] = load1(&psi[I + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[112], mt[112], tmp[0]);
	tmp[1] = fma(v[0], m[113], mt[113], tmp[1]);
	tmp[2] = fma(v[0], m[114], mt[114], tmp[2]);
	tmp[3] = fma(v[0], m[115], mt[115], tmp[3]);
	tmp[4] = fma(v[0], m[116], mt[116], tmp[4]);
	tmp[5] = fma(v[0], m[117], mt[117], tmp[5]);
	tmp[6] = fma(v[0], m[118], mt[118], tmp[6]);
	tmp[7] = fma(v[0], m[119], mt[119], tmp[7]);

	v[0] = load1(&psi[I + d0 + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[120], mt[120], tmp[0]);
	tmp[1] = fma(v[0], m[121], mt[121], tmp[1]);
	tmp[2] = fma(v[0], m[122], mt[122], tmp[2]);
	tmp[3] = fma(v[0], m[123], mt[123], tmp[3]);
	store((double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], tmp[1]);
	store((double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[2]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], tmp[3]);
	tmp[4] = fma(v[0], m[124], mt[124], tmp[4]);
	tmp[5] = fma(v[0], m[125], mt[125], tmp[5]);
	tmp[6] = fma(v[0], m[126], mt[126], tmp[6]);
	tmp[7] = fma(v[0], m[127], mt[127], tmp[7]);
	store((double*)&psi[I + d0 + d3], (double*)&psi[I + d3], tmp[4]);
	store((double*)&psi[I + d0 + d1 + d3], (double*)&psi[I + d1 + d3], tmp[5]);
	store((double*)&psi[I + d0 + d2 + d3], (double*)&psi[I + d2 + d3], tmp[6]);
	store((double*)&psi[I + d0 + d1 + d2 + d3], (double*)&psi[I + d1 + d2 + d3], tmp[7]);

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id3, unsigned id2, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	std::size_t d2 = 1ULL << id2;
	std::size_t d3 = 1ULL << id3;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1, d2, d3};
	permute_qubits_and_matrix(dsorted, 4, m);

	__m256d mm[128];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 8; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*8+r*1+c] = loada(&m[2*r+0][c+b*1], &m[2*r+1][c+b*1]);
			}
		}
	}

	__m256d mmt[128];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 8; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mmt[b*8+r*1+c] = loadbm(&m[2*r+0][c+b*1], &m[2*r+1][c+b*1]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp for collapse(LOOP_COLLAPSE4) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; ++i4){
							kernel_core(psi, i0 + i1 + i2 + i3 + i4, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
						}
					}
				}
			}
		}
	}
	else{
		#pragma omp for collapse(LOOP_COLLAPSE4) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; ++i4){
							if (((i0 + i1 + i2 + i3 + i4)&ctrlmask) == ctrlmask)
								kernel_core(psi, i0 + i1 + i2 + i3 + i4, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
						}
					}
				}
			}
		}
	}
#else
	std::intptr_t zero = 0;
	std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2] + dsorted[3];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
	}
#endif
}

