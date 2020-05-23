// (C) 2018 ETH Zurich, ITP, Thomas H�ner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, M const& m, M const& mt)
{
	__m512d v[1];

	v[0] = load1x4(&psi[I]);

	__m512d tmp[4] = {_mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], mt[1], tmp[1]);
	tmp[2] = fma(v[0], m[2], mt[2], tmp[2]);
	tmp[3] = fma(v[0], m[3], mt[3], tmp[3]);

	v[0] = load1x4(&psi[I + d0]);

	tmp[0] = fma(v[0], m[4], mt[4], tmp[0]);
	tmp[1] = fma(v[0], m[5], mt[5], tmp[1]);
	tmp[2] = fma(v[0], m[6], mt[6], tmp[2]);
	tmp[3] = fma(v[0], m[7], mt[7], tmp[3]);

	v[0] = load1x4(&psi[I + d1]);

	tmp[0] = fma(v[0], m[8], mt[8], tmp[0]);
	tmp[1] = fma(v[0], m[9], mt[9], tmp[1]);
	tmp[2] = fma(v[0], m[10], mt[10], tmp[2]);
	tmp[3] = fma(v[0], m[11], mt[11], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d1]);

	tmp[0] = fma(v[0], m[12], mt[12], tmp[0]);
	tmp[1] = fma(v[0], m[13], mt[13], tmp[1]);
	tmp[2] = fma(v[0], m[14], mt[14], tmp[2]);
	tmp[3] = fma(v[0], m[15], mt[15], tmp[3]);

	v[0] = load1x4(&psi[I + d2]);

	tmp[0] = fma(v[0], m[16], mt[16], tmp[0]);
	tmp[1] = fma(v[0], m[17], mt[17], tmp[1]);
	tmp[2] = fma(v[0], m[18], mt[18], tmp[2]);
	tmp[3] = fma(v[0], m[19], mt[19], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d2]);

	tmp[0] = fma(v[0], m[20], mt[20], tmp[0]);
	tmp[1] = fma(v[0], m[21], mt[21], tmp[1]);
	tmp[2] = fma(v[0], m[22], mt[22], tmp[2]);
	tmp[3] = fma(v[0], m[23], mt[23], tmp[3]);

	v[0] = load1x4(&psi[I + d1 + d2]);

	tmp[0] = fma(v[0], m[24], mt[24], tmp[0]);
	tmp[1] = fma(v[0], m[25], mt[25], tmp[1]);
	tmp[2] = fma(v[0], m[26], mt[26], tmp[2]);
	tmp[3] = fma(v[0], m[27], mt[27], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d1 + d2]);

	tmp[0] = fma(v[0], m[28], mt[28], tmp[0]);
	tmp[1] = fma(v[0], m[29], mt[29], tmp[1]);
	tmp[2] = fma(v[0], m[30], mt[30], tmp[2]);
	tmp[3] = fma(v[0], m[31], mt[31], tmp[3]);

	v[0] = load1x4(&psi[I + d3]);

	tmp[0] = fma(v[0], m[32], mt[32], tmp[0]);
	tmp[1] = fma(v[0], m[33], mt[33], tmp[1]);
	tmp[2] = fma(v[0], m[34], mt[34], tmp[2]);
	tmp[3] = fma(v[0], m[35], mt[35], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d3]);

	tmp[0] = fma(v[0], m[36], mt[36], tmp[0]);
	tmp[1] = fma(v[0], m[37], mt[37], tmp[1]);
	tmp[2] = fma(v[0], m[38], mt[38], tmp[2]);
	tmp[3] = fma(v[0], m[39], mt[39], tmp[3]);

	v[0] = load1x4(&psi[I + d1 + d3]);

	tmp[0] = fma(v[0], m[40], mt[40], tmp[0]);
	tmp[1] = fma(v[0], m[41], mt[41], tmp[1]);
	tmp[2] = fma(v[0], m[42], mt[42], tmp[2]);
	tmp[3] = fma(v[0], m[43], mt[43], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d1 + d3]);

	tmp[0] = fma(v[0], m[44], mt[44], tmp[0]);
	tmp[1] = fma(v[0], m[45], mt[45], tmp[1]);
	tmp[2] = fma(v[0], m[46], mt[46], tmp[2]);
	tmp[3] = fma(v[0], m[47], mt[47], tmp[3]);

	v[0] = load1x4(&psi[I + d2 + d3]);

	tmp[0] = fma(v[0], m[48], mt[48], tmp[0]);
	tmp[1] = fma(v[0], m[49], mt[49], tmp[1]);
	tmp[2] = fma(v[0], m[50], mt[50], tmp[2]);
	tmp[3] = fma(v[0], m[51], mt[51], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d2 + d3]);

	tmp[0] = fma(v[0], m[52], mt[52], tmp[0]);
	tmp[1] = fma(v[0], m[53], mt[53], tmp[1]);
	tmp[2] = fma(v[0], m[54], mt[54], tmp[2]);
	tmp[3] = fma(v[0], m[55], mt[55], tmp[3]);

	v[0] = load1x4(&psi[I + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[56], mt[56], tmp[0]);
	tmp[1] = fma(v[0], m[57], mt[57], tmp[1]);
	tmp[2] = fma(v[0], m[58], mt[58], tmp[2]);
	tmp[3] = fma(v[0], m[59], mt[59], tmp[3]);

	v[0] = load1x4(&psi[I + d0 + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[60], mt[60], tmp[0]);
	tmp[1] = fma(v[0], m[61], mt[61], tmp[1]);
	tmp[2] = fma(v[0], m[62], mt[62], tmp[2]);
	tmp[3] = fma(v[0], m[63], mt[63], tmp[3]);
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], (double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], (double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[1]);
	store((double*)&psi[I + d0 + d1 + d3], (double*)&psi[I + d1 + d3], (double*)&psi[I + d0 + d3], (double*)&psi[I + d3], tmp[2]);
	store((double*)&psi[I + d0 + d1 + d2 + d3], (double*)&psi[I + d1 + d2 + d3], (double*)&psi[I + d0 + d2 + d3], (double*)&psi[I + d2 + d3], tmp[3]);

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

	__m512d mm[64];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 4; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*4+r*1+c] = loada(&m[4*r+0][c+b*1], &m[4*r+1][c+b*1], &m[4*r+2][c+b*1], &m[4*r+3][c+b*1]);
			}
		}
	}

	__m512d mmt[64];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 4; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mmt[b*4+r*1+c] = loadbm(&m[4*r+0][c+b*1], &m[4*r+1][c+b*1], &m[4*r+2][c+b*1], &m[4*r+3][c+b*1]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE4) schedule(static)
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
		#pragma omp parallel for collapse(LOOP_COLLAPSE4) schedule(static)
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

