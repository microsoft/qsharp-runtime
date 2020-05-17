// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, std::size_t d5, M const& m)
{
	__m256d v[4];

	v[0] = load1(&psi[I]);
	v[1] = load1(&psi[I + d0]);
	v[2] = load1(&psi[I + d1]);
	v[3] = load1(&psi[I + d0 + d1]);

	__m256d tmp[32] = {_mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd()};
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[0 + i * 4 + 0], fma(v[1], m[0 + i * 4 + 1], fma(v[2], m[0 + i * 4 + 2], fma(v[3], m[0 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2]);
	v[1] = load1(&psi[I + d0 + d2]);
	v[2] = load1(&psi[I + d1 + d2]);
	v[3] = load1(&psi[I + d0 + d1 + d2]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[128 + i * 4 + 0], fma(v[1], m[128 + i * 4 + 1], fma(v[2], m[128 + i * 4 + 2], fma(v[3], m[128 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3]);
	v[1] = load1(&psi[I + d0 + d3]);
	v[2] = load1(&psi[I + d1 + d3]);
	v[3] = load1(&psi[I + d0 + d1 + d3]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[256 + i * 4 + 0], fma(v[1], m[256 + i * 4 + 1], fma(v[2], m[256 + i * 4 + 2], fma(v[3], m[256 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3]);
	v[1] = load1(&psi[I + d0 + d2 + d3]);
	v[2] = load1(&psi[I + d1 + d2 + d3]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[384 + i * 4 + 0], fma(v[1], m[384 + i * 4 + 1], fma(v[2], m[384 + i * 4 + 2], fma(v[3], m[384 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4]);
	v[1] = load1(&psi[I + d0 + d4]);
	v[2] = load1(&psi[I + d1 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d4]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[512 + i * 4 + 0], fma(v[1], m[512 + i * 4 + 1], fma(v[2], m[512 + i * 4 + 2], fma(v[3], m[512 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d4]);
	v[2] = load1(&psi[I + d1 + d2 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[640 + i * 4 + 0], fma(v[1], m[640 + i * 4 + 1], fma(v[2], m[640 + i * 4 + 2], fma(v[3], m[640 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d3 + d4]);
	v[2] = load1(&psi[I + d1 + d3 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[768 + i * 4 + 0], fma(v[1], m[768 + i * 4 + 1], fma(v[2], m[768 + i * 4 + 2], fma(v[3], m[768 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[896 + i * 4 + 0], fma(v[1], m[896 + i * 4 + 1], fma(v[2], m[896 + i * 4 + 2], fma(v[3], m[896 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d5]);
	v[1] = load1(&psi[I + d0 + d5]);
	v[2] = load1(&psi[I + d1 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1024 + i * 4 + 0], fma(v[1], m[1024 + i * 4 + 1], fma(v[2], m[1024 + i * 4 + 2], fma(v[3], m[1024 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1152 + i * 4 + 0], fma(v[1], m[1152 + i * 4 + 1], fma(v[2], m[1152 + i * 4 + 2], fma(v[3], m[1152 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d5]);
	v[1] = load1(&psi[I + d0 + d3 + d5]);
	v[2] = load1(&psi[I + d1 + d3 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1280 + i * 4 + 0], fma(v[1], m[1280 + i * 4 + 1], fma(v[2], m[1280 + i * 4 + 2], fma(v[3], m[1280 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1408 + i * 4 + 0], fma(v[1], m[1408 + i * 4 + 1], fma(v[2], m[1408 + i * 4 + 2], fma(v[3], m[1408 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d4 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1536 + i * 4 + 0], fma(v[1], m[1536 + i * 4 + 1], fma(v[2], m[1536 + i * 4 + 2], fma(v[3], m[1536 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1664 + i * 4 + 0], fma(v[1], m[1664 + i * 4 + 1], fma(v[2], m[1664 + i * 4 + 2], fma(v[3], m[1664 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d3 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d3 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1792 + i * 4 + 0], fma(v[1], m[1792 + i * 4 + 1], fma(v[2], m[1792 + i * 4 + 2], fma(v[3], m[1792 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4 + d5]);
	for (unsigned i = 0; i < 32; ++i){
		tmp[i] = fma(v[0], m[1920 + i * 4 + 0], fma(v[1], m[1920 + i * 4 + 1], fma(v[2], m[1920 + i * 4 + 2], fma(v[3], m[1920 + i * 4 + 3], tmp[i]))));
	}

	store((double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], tmp[1]);
	store((double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[2]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], tmp[3]);
	store((double*)&psi[I + d0 + d3], (double*)&psi[I + d3], tmp[4]);
	store((double*)&psi[I + d0 + d1 + d3], (double*)&psi[I + d1 + d3], tmp[5]);
	store((double*)&psi[I + d0 + d2 + d3], (double*)&psi[I + d2 + d3], tmp[6]);
	store((double*)&psi[I + d0 + d1 + d2 + d3], (double*)&psi[I + d1 + d2 + d3], tmp[7]);
	store((double*)&psi[I + d0 + d4], (double*)&psi[I + d4], tmp[8]);
	store((double*)&psi[I + d0 + d1 + d4], (double*)&psi[I + d1 + d4], tmp[9]);
	store((double*)&psi[I + d0 + d2 + d4], (double*)&psi[I + d2 + d4], tmp[10]);
	store((double*)&psi[I + d0 + d1 + d2 + d4], (double*)&psi[I + d1 + d2 + d4], tmp[11]);
	store((double*)&psi[I + d0 + d3 + d4], (double*)&psi[I + d3 + d4], tmp[12]);
	store((double*)&psi[I + d0 + d1 + d3 + d4], (double*)&psi[I + d1 + d3 + d4], tmp[13]);
	store((double*)&psi[I + d0 + d2 + d3 + d4], (double*)&psi[I + d2 + d3 + d4], tmp[14]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4], (double*)&psi[I + d1 + d2 + d3 + d4], tmp[15]);
	store((double*)&psi[I + d0 + d5], (double*)&psi[I + d5], tmp[16]);
	store((double*)&psi[I + d0 + d1 + d5], (double*)&psi[I + d1 + d5], tmp[17]);
	store((double*)&psi[I + d0 + d2 + d5], (double*)&psi[I + d2 + d5], tmp[18]);
	store((double*)&psi[I + d0 + d1 + d2 + d5], (double*)&psi[I + d1 + d2 + d5], tmp[19]);
	store((double*)&psi[I + d0 + d3 + d5], (double*)&psi[I + d3 + d5], tmp[20]);
	store((double*)&psi[I + d0 + d1 + d3 + d5], (double*)&psi[I + d1 + d3 + d5], tmp[21]);
	store((double*)&psi[I + d0 + d2 + d3 + d5], (double*)&psi[I + d2 + d3 + d5], tmp[22]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d5], (double*)&psi[I + d1 + d2 + d3 + d5], tmp[23]);
	store((double*)&psi[I + d0 + d4 + d5], (double*)&psi[I + d4 + d5], tmp[24]);
	store((double*)&psi[I + d0 + d1 + d4 + d5], (double*)&psi[I + d1 + d4 + d5], tmp[25]);
	store((double*)&psi[I + d0 + d2 + d4 + d5], (double*)&psi[I + d2 + d4 + d5], tmp[26]);
	store((double*)&psi[I + d0 + d1 + d2 + d4 + d5], (double*)&psi[I + d1 + d2 + d4 + d5], tmp[27]);
	store((double*)&psi[I + d0 + d3 + d4 + d5], (double*)&psi[I + d3 + d4 + d5], tmp[28]);
	store((double*)&psi[I + d0 + d1 + d3 + d4 + d5], (double*)&psi[I + d1 + d3 + d4 + d5], tmp[29]);
	store((double*)&psi[I + d0 + d2 + d3 + d4 + d5], (double*)&psi[I + d2 + d3 + d4 + d5], tmp[30]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4 + d5], (double*)&psi[I + d1 + d2 + d3 + d4 + d5], tmp[31]);

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id5, unsigned id4, unsigned id3, unsigned id2, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	std::size_t d2 = 1ULL << id2;
	std::size_t d3 = 1ULL << id3;
	std::size_t d4 = 1ULL << id4;
	std::size_t d5 = 1ULL << id5;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1, d2, d3, d4, d5};
	permute_qubits_and_matrix(dsorted, 6, m);

	__m256d mm[2048];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 32; ++r){
			for (unsigned c = 0; c < 4; ++c){
				mm[b*128+r*4+c] = loadab(&m[2*r+0][c+b*4], &m[2*r+1][c+b*4]);
			}
		}
	}


#ifndef _MSC_VER_OR_WSL
	if (ctrlmask == 0){
		#pragma omp for collapse(LOOP_COLLAPSE6) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; i5 += 2 * dsorted[5]){
								for (std::size_t i6 = 0; i6 < dsorted[5]; ++i6){
									kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5 + i6, dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
								}
							}
						}
					}
				}
			}
		}
	}
	else{
		#pragma omp for collapse(LOOP_COLLAPSE6) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; i5 += 2 * dsorted[5]){
								for (std::size_t i6 = 0; i6 < dsorted[5]; ++i6){
									if (((i0 + i1 + i2 + i3 + i4 + i5 + i6)&ctrlmask) == ctrlmask)
										kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5 + i6, dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
								}
							}
						}
					}
				}
			}
		}
	}
#else
	std::intptr_t zero = 0;
	std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2] + dsorted[3] + dsorted[4] + dsorted[5];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	}
#endif
}

