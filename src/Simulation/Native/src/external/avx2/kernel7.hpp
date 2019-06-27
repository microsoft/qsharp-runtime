// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, std::size_t d5, std::size_t d6, M const& m)
{
	__m256d v[4];

	v[0] = load1(&psi[I]);
	v[1] = load1(&psi[I + d0]);
	v[2] = load1(&psi[I + d1]);
	v[3] = load1(&psi[I + d0 + d1]);

	__m256d tmp[64] = {_mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd()};
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[0 + i * 4 + 0], fma(v[1], m[0 + i * 4 + 1], fma(v[2], m[0 + i * 4 + 2], fma(v[3], m[0 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2]);
	v[1] = load1(&psi[I + d0 + d2]);
	v[2] = load1(&psi[I + d1 + d2]);
	v[3] = load1(&psi[I + d0 + d1 + d2]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[256 + i * 4 + 0], fma(v[1], m[256 + i * 4 + 1], fma(v[2], m[256 + i * 4 + 2], fma(v[3], m[256 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3]);
	v[1] = load1(&psi[I + d0 + d3]);
	v[2] = load1(&psi[I + d1 + d3]);
	v[3] = load1(&psi[I + d0 + d1 + d3]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[512 + i * 4 + 0], fma(v[1], m[512 + i * 4 + 1], fma(v[2], m[512 + i * 4 + 2], fma(v[3], m[512 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3]);
	v[1] = load1(&psi[I + d0 + d2 + d3]);
	v[2] = load1(&psi[I + d1 + d2 + d3]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[768 + i * 4 + 0], fma(v[1], m[768 + i * 4 + 1], fma(v[2], m[768 + i * 4 + 2], fma(v[3], m[768 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4]);
	v[1] = load1(&psi[I + d0 + d4]);
	v[2] = load1(&psi[I + d1 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d4]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[1024 + i * 4 + 0], fma(v[1], m[1024 + i * 4 + 1], fma(v[2], m[1024 + i * 4 + 2], fma(v[3], m[1024 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d4]);
	v[2] = load1(&psi[I + d1 + d2 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[1280 + i * 4 + 0], fma(v[1], m[1280 + i * 4 + 1], fma(v[2], m[1280 + i * 4 + 2], fma(v[3], m[1280 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d3 + d4]);
	v[2] = load1(&psi[I + d1 + d3 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[1536 + i * 4 + 0], fma(v[1], m[1536 + i * 4 + 1], fma(v[2], m[1536 + i * 4 + 2], fma(v[3], m[1536 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[1792 + i * 4 + 0], fma(v[1], m[1792 + i * 4 + 1], fma(v[2], m[1792 + i * 4 + 2], fma(v[3], m[1792 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d5]);
	v[1] = load1(&psi[I + d0 + d5]);
	v[2] = load1(&psi[I + d1 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[2048 + i * 4 + 0], fma(v[1], m[2048 + i * 4 + 1], fma(v[2], m[2048 + i * 4 + 2], fma(v[3], m[2048 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[2304 + i * 4 + 0], fma(v[1], m[2304 + i * 4 + 1], fma(v[2], m[2304 + i * 4 + 2], fma(v[3], m[2304 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d5]);
	v[1] = load1(&psi[I + d0 + d3 + d5]);
	v[2] = load1(&psi[I + d1 + d3 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[2560 + i * 4 + 0], fma(v[1], m[2560 + i * 4 + 1], fma(v[2], m[2560 + i * 4 + 2], fma(v[3], m[2560 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[2816 + i * 4 + 0], fma(v[1], m[2816 + i * 4 + 1], fma(v[2], m[2816 + i * 4 + 2], fma(v[3], m[2816 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d4 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[3072 + i * 4 + 0], fma(v[1], m[3072 + i * 4 + 1], fma(v[2], m[3072 + i * 4 + 2], fma(v[3], m[3072 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[3328 + i * 4 + 0], fma(v[1], m[3328 + i * 4 + 1], fma(v[2], m[3328 + i * 4 + 2], fma(v[3], m[3328 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d3 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d3 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[3584 + i * 4 + 0], fma(v[1], m[3584 + i * 4 + 1], fma(v[2], m[3584 + i * 4 + 2], fma(v[3], m[3584 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4 + d5]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4 + d5]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4 + d5]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4 + d5]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[3840 + i * 4 + 0], fma(v[1], m[3840 + i * 4 + 1], fma(v[2], m[3840 + i * 4 + 2], fma(v[3], m[3840 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d6]);
	v[1] = load1(&psi[I + d0 + d6]);
	v[2] = load1(&psi[I + d1 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[4096 + i * 4 + 0], fma(v[1], m[4096 + i * 4 + 1], fma(v[2], m[4096 + i * 4 + 2], fma(v[3], m[4096 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[4352 + i * 4 + 0], fma(v[1], m[4352 + i * 4 + 1], fma(v[2], m[4352 + i * 4 + 2], fma(v[3], m[4352 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d6]);
	v[1] = load1(&psi[I + d0 + d3 + d6]);
	v[2] = load1(&psi[I + d1 + d3 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[4608 + i * 4 + 0], fma(v[1], m[4608 + i * 4 + 1], fma(v[2], m[4608 + i * 4 + 2], fma(v[3], m[4608 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[4864 + i * 4 + 0], fma(v[1], m[4864 + i * 4 + 1], fma(v[2], m[4864 + i * 4 + 2], fma(v[3], m[4864 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4 + d6]);
	v[1] = load1(&psi[I + d0 + d4 + d6]);
	v[2] = load1(&psi[I + d1 + d4 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d4 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[5120 + i * 4 + 0], fma(v[1], m[5120 + i * 4 + 1], fma(v[2], m[5120 + i * 4 + 2], fma(v[3], m[5120 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d4 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d4 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[5376 + i * 4 + 0], fma(v[1], m[5376 + i * 4 + 1], fma(v[2], m[5376 + i * 4 + 2], fma(v[3], m[5376 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4 + d6]);
	v[1] = load1(&psi[I + d0 + d3 + d4 + d6]);
	v[2] = load1(&psi[I + d1 + d3 + d4 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[5632 + i * 4 + 0], fma(v[1], m[5632 + i * 4 + 1], fma(v[2], m[5632 + i * 4 + 2], fma(v[3], m[5632 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[5888 + i * 4 + 0], fma(v[1], m[5888 + i * 4 + 1], fma(v[2], m[5888 + i * 4 + 2], fma(v[3], m[5888 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[6144 + i * 4 + 0], fma(v[1], m[6144 + i * 4 + 1], fma(v[2], m[6144 + i * 4 + 2], fma(v[3], m[6144 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[6400 + i * 4 + 0], fma(v[1], m[6400 + i * 4 + 1], fma(v[2], m[6400 + i * 4 + 2], fma(v[3], m[6400 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d3 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d3 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[6656 + i * 4 + 0], fma(v[1], m[6656 + i * 4 + 1], fma(v[2], m[6656 + i * 4 + 2], fma(v[3], m[6656 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[6912 + i * 4 + 0], fma(v[1], m[6912 + i * 4 + 1], fma(v[2], m[6912 + i * 4 + 2], fma(v[3], m[6912 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d4 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d4 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d4 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d4 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[7168 + i * 4 + 0], fma(v[1], m[7168 + i * 4 + 1], fma(v[2], m[7168 + i * 4 + 2], fma(v[3], m[7168 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d4 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d4 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d4 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d4 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[7424 + i * 4 + 0], fma(v[1], m[7424 + i * 4 + 1], fma(v[2], m[7424 + i * 4 + 2], fma(v[3], m[7424 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d3 + d4 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d3 + d4 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d3 + d4 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d3 + d4 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[7680 + i * 4 + 0], fma(v[1], m[7680 + i * 4 + 1], fma(v[2], m[7680 + i * 4 + 2], fma(v[3], m[7680 + i * 4 + 3], tmp[i]))));
	}


	v[0] = load1(&psi[I + d2 + d3 + d4 + d5 + d6]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4 + d5 + d6]);
	v[2] = load1(&psi[I + d1 + d2 + d3 + d4 + d5 + d6]);
	v[3] = load1(&psi[I + d0 + d1 + d2 + d3 + d4 + d5 + d6]);
	for (unsigned i = 0; i < 64; ++i){
		tmp[i] = fma(v[0], m[7936 + i * 4 + 0], fma(v[1], m[7936 + i * 4 + 1], fma(v[2], m[7936 + i * 4 + 2], fma(v[3], m[7936 + i * 4 + 3], tmp[i]))));
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
	store((double*)&psi[I + d0 + d6], (double*)&psi[I + d6], tmp[32]);
	store((double*)&psi[I + d0 + d1 + d6], (double*)&psi[I + d1 + d6], tmp[33]);
	store((double*)&psi[I + d0 + d2 + d6], (double*)&psi[I + d2 + d6], tmp[34]);
	store((double*)&psi[I + d0 + d1 + d2 + d6], (double*)&psi[I + d1 + d2 + d6], tmp[35]);
	store((double*)&psi[I + d0 + d3 + d6], (double*)&psi[I + d3 + d6], tmp[36]);
	store((double*)&psi[I + d0 + d1 + d3 + d6], (double*)&psi[I + d1 + d3 + d6], tmp[37]);
	store((double*)&psi[I + d0 + d2 + d3 + d6], (double*)&psi[I + d2 + d3 + d6], tmp[38]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d6], (double*)&psi[I + d1 + d2 + d3 + d6], tmp[39]);
	store((double*)&psi[I + d0 + d4 + d6], (double*)&psi[I + d4 + d6], tmp[40]);
	store((double*)&psi[I + d0 + d1 + d4 + d6], (double*)&psi[I + d1 + d4 + d6], tmp[41]);
	store((double*)&psi[I + d0 + d2 + d4 + d6], (double*)&psi[I + d2 + d4 + d6], tmp[42]);
	store((double*)&psi[I + d0 + d1 + d2 + d4 + d6], (double*)&psi[I + d1 + d2 + d4 + d6], tmp[43]);
	store((double*)&psi[I + d0 + d3 + d4 + d6], (double*)&psi[I + d3 + d4 + d6], tmp[44]);
	store((double*)&psi[I + d0 + d1 + d3 + d4 + d6], (double*)&psi[I + d1 + d3 + d4 + d6], tmp[45]);
	store((double*)&psi[I + d0 + d2 + d3 + d4 + d6], (double*)&psi[I + d2 + d3 + d4 + d6], tmp[46]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4 + d6], (double*)&psi[I + d1 + d2 + d3 + d4 + d6], tmp[47]);
	store((double*)&psi[I + d0 + d5 + d6], (double*)&psi[I + d5 + d6], tmp[48]);
	store((double*)&psi[I + d0 + d1 + d5 + d6], (double*)&psi[I + d1 + d5 + d6], tmp[49]);
	store((double*)&psi[I + d0 + d2 + d5 + d6], (double*)&psi[I + d2 + d5 + d6], tmp[50]);
	store((double*)&psi[I + d0 + d1 + d2 + d5 + d6], (double*)&psi[I + d1 + d2 + d5 + d6], tmp[51]);
	store((double*)&psi[I + d0 + d3 + d5 + d6], (double*)&psi[I + d3 + d5 + d6], tmp[52]);
	store((double*)&psi[I + d0 + d1 + d3 + d5 + d6], (double*)&psi[I + d1 + d3 + d5 + d6], tmp[53]);
	store((double*)&psi[I + d0 + d2 + d3 + d5 + d6], (double*)&psi[I + d2 + d3 + d5 + d6], tmp[54]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d5 + d6], (double*)&psi[I + d1 + d2 + d3 + d5 + d6], tmp[55]);
	store((double*)&psi[I + d0 + d4 + d5 + d6], (double*)&psi[I + d4 + d5 + d6], tmp[56]);
	store((double*)&psi[I + d0 + d1 + d4 + d5 + d6], (double*)&psi[I + d1 + d4 + d5 + d6], tmp[57]);
	store((double*)&psi[I + d0 + d2 + d4 + d5 + d6], (double*)&psi[I + d2 + d4 + d5 + d6], tmp[58]);
	store((double*)&psi[I + d0 + d1 + d2 + d4 + d5 + d6], (double*)&psi[I + d1 + d2 + d4 + d5 + d6], tmp[59]);
	store((double*)&psi[I + d0 + d3 + d4 + d5 + d6], (double*)&psi[I + d3 + d4 + d5 + d6], tmp[60]);
	store((double*)&psi[I + d0 + d1 + d3 + d4 + d5 + d6], (double*)&psi[I + d1 + d3 + d4 + d5 + d6], tmp[61]);
	store((double*)&psi[I + d0 + d2 + d3 + d4 + d5 + d6], (double*)&psi[I + d2 + d3 + d4 + d5 + d6], tmp[62]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4 + d5 + d6], (double*)&psi[I + d1 + d2 + d3 + d4 + d5 + d6], tmp[63]);

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id6, unsigned id5, unsigned id4, unsigned id3, unsigned id2, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	std::size_t d2 = 1ULL << id2;
	std::size_t d3 = 1ULL << id3;
	std::size_t d4 = 1ULL << id4;
	std::size_t d5 = 1ULL << id5;
	std::size_t d6 = 1ULL << id6;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1, d2, d3, d4, d5, d6};
	permute_qubits_and_matrix(dsorted, 7, m);

	__m256d mm[8192];
	for (unsigned b = 0; b < 32; ++b){
		for (unsigned r = 0; r < 64; ++r){
			for (unsigned c = 0; c < 4; ++c){
				mm[b*256+r*4+c] = loadab(&m[2*r+0][c+b*4], &m[2*r+1][c+b*4]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp for collapse(LOOP_COLLAPSE7) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; i5 += 2 * dsorted[5]){
								for (std::size_t i6 = 0; i6 < dsorted[5]; i6 += 2 * dsorted[6]){
									for (std::size_t i7 = 0; i7 < dsorted[6]; ++i7){
										kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5 + i6 + i7, dsorted[6], dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	else{
		#pragma omp for collapse(LOOP_COLLAPSE7) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; i5 += 2 * dsorted[5]){
								for (std::size_t i6 = 0; i6 < dsorted[5]; i6 += 2 * dsorted[6]){
									for (std::size_t i7 = 0; i7 < dsorted[6]; ++i7){
										if (((i0 + i1 + i2 + i3 + i4 + i5 + i6 + i7)&ctrlmask) == ctrlmask)
											kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5 + i6 + i7, dsorted[6], dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
									}
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
	std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2] + dsorted[3] + dsorted[4] + dsorted[5] + dsorted[6];

	if (ctrlmask == 0){
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & dmask) == zero)
				kernel_core(psi, i, dsorted[6], dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[6], dsorted[5], dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	}
#endif
}

