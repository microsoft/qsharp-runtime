// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, std::size_t d5, std::size_t d6, M const& m)
{
	std::complex<double> v[4];

	v[0] = psi[I];
	v[1] = psi[I + d0];
	v[2] = psi[I + d1];
	v[3] = psi[I + d0 + d1];

	std::complex<double> tmp[128] = {0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.};
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[0 + i * 4 + 0], fma(v[1], m[0 + i * 4 + 1], fma(v[2], m[0 + i * 4 + 2], fma(v[3], m[0 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2];
	v[1] = psi[I + d0 + d2];
	v[2] = psi[I + d1 + d2];
	v[3] = psi[I + d0 + d1 + d2];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[512 + i * 4 + 0], fma(v[1], m[512 + i * 4 + 1], fma(v[2], m[512 + i * 4 + 2], fma(v[3], m[512 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3];
	v[1] = psi[I + d0 + d3];
	v[2] = psi[I + d1 + d3];
	v[3] = psi[I + d0 + d1 + d3];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[1024 + i * 4 + 0], fma(v[1], m[1024 + i * 4 + 1], fma(v[2], m[1024 + i * 4 + 2], fma(v[3], m[1024 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3];
	v[1] = psi[I + d0 + d2 + d3];
	v[2] = psi[I + d1 + d2 + d3];
	v[3] = psi[I + d0 + d1 + d2 + d3];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[1536 + i * 4 + 0], fma(v[1], m[1536 + i * 4 + 1], fma(v[2], m[1536 + i * 4 + 2], fma(v[3], m[1536 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d4];
	v[1] = psi[I + d0 + d4];
	v[2] = psi[I + d1 + d4];
	v[3] = psi[I + d0 + d1 + d4];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[2048 + i * 4 + 0], fma(v[1], m[2048 + i * 4 + 1], fma(v[2], m[2048 + i * 4 + 2], fma(v[3], m[2048 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d4];
	v[1] = psi[I + d0 + d2 + d4];
	v[2] = psi[I + d1 + d2 + d4];
	v[3] = psi[I + d0 + d1 + d2 + d4];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[2560 + i * 4 + 0], fma(v[1], m[2560 + i * 4 + 1], fma(v[2], m[2560 + i * 4 + 2], fma(v[3], m[2560 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d4];
	v[1] = psi[I + d0 + d3 + d4];
	v[2] = psi[I + d1 + d3 + d4];
	v[3] = psi[I + d0 + d1 + d3 + d4];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[3072 + i * 4 + 0], fma(v[1], m[3072 + i * 4 + 1], fma(v[2], m[3072 + i * 4 + 2], fma(v[3], m[3072 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d4];
	v[1] = psi[I + d0 + d2 + d3 + d4];
	v[2] = psi[I + d1 + d2 + d3 + d4];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d4];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[3584 + i * 4 + 0], fma(v[1], m[3584 + i * 4 + 1], fma(v[2], m[3584 + i * 4 + 2], fma(v[3], m[3584 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d5];
	v[1] = psi[I + d0 + d5];
	v[2] = psi[I + d1 + d5];
	v[3] = psi[I + d0 + d1 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[4096 + i * 4 + 0], fma(v[1], m[4096 + i * 4 + 1], fma(v[2], m[4096 + i * 4 + 2], fma(v[3], m[4096 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d5];
	v[1] = psi[I + d0 + d2 + d5];
	v[2] = psi[I + d1 + d2 + d5];
	v[3] = psi[I + d0 + d1 + d2 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[4608 + i * 4 + 0], fma(v[1], m[4608 + i * 4 + 1], fma(v[2], m[4608 + i * 4 + 2], fma(v[3], m[4608 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d5];
	v[1] = psi[I + d0 + d3 + d5];
	v[2] = psi[I + d1 + d3 + d5];
	v[3] = psi[I + d0 + d1 + d3 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[5120 + i * 4 + 0], fma(v[1], m[5120 + i * 4 + 1], fma(v[2], m[5120 + i * 4 + 2], fma(v[3], m[5120 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d5];
	v[1] = psi[I + d0 + d2 + d3 + d5];
	v[2] = psi[I + d1 + d2 + d3 + d5];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[5632 + i * 4 + 0], fma(v[1], m[5632 + i * 4 + 1], fma(v[2], m[5632 + i * 4 + 2], fma(v[3], m[5632 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d4 + d5];
	v[1] = psi[I + d0 + d4 + d5];
	v[2] = psi[I + d1 + d4 + d5];
	v[3] = psi[I + d0 + d1 + d4 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[6144 + i * 4 + 0], fma(v[1], m[6144 + i * 4 + 1], fma(v[2], m[6144 + i * 4 + 2], fma(v[3], m[6144 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d4 + d5];
	v[1] = psi[I + d0 + d2 + d4 + d5];
	v[2] = psi[I + d1 + d2 + d4 + d5];
	v[3] = psi[I + d0 + d1 + d2 + d4 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[6656 + i * 4 + 0], fma(v[1], m[6656 + i * 4 + 1], fma(v[2], m[6656 + i * 4 + 2], fma(v[3], m[6656 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d4 + d5];
	v[1] = psi[I + d0 + d3 + d4 + d5];
	v[2] = psi[I + d1 + d3 + d4 + d5];
	v[3] = psi[I + d0 + d1 + d3 + d4 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[7168 + i * 4 + 0], fma(v[1], m[7168 + i * 4 + 1], fma(v[2], m[7168 + i * 4 + 2], fma(v[3], m[7168 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d4 + d5];
	v[1] = psi[I + d0 + d2 + d3 + d4 + d5];
	v[2] = psi[I + d1 + d2 + d3 + d4 + d5];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d4 + d5];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[7680 + i * 4 + 0], fma(v[1], m[7680 + i * 4 + 1], fma(v[2], m[7680 + i * 4 + 2], fma(v[3], m[7680 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d6];
	v[1] = psi[I + d0 + d6];
	v[2] = psi[I + d1 + d6];
	v[3] = psi[I + d0 + d1 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[8192 + i * 4 + 0], fma(v[1], m[8192 + i * 4 + 1], fma(v[2], m[8192 + i * 4 + 2], fma(v[3], m[8192 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d6];
	v[1] = psi[I + d0 + d2 + d6];
	v[2] = psi[I + d1 + d2 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[8704 + i * 4 + 0], fma(v[1], m[8704 + i * 4 + 1], fma(v[2], m[8704 + i * 4 + 2], fma(v[3], m[8704 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d6];
	v[1] = psi[I + d0 + d3 + d6];
	v[2] = psi[I + d1 + d3 + d6];
	v[3] = psi[I + d0 + d1 + d3 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[9216 + i * 4 + 0], fma(v[1], m[9216 + i * 4 + 1], fma(v[2], m[9216 + i * 4 + 2], fma(v[3], m[9216 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d6];
	v[1] = psi[I + d0 + d2 + d3 + d6];
	v[2] = psi[I + d1 + d2 + d3 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[9728 + i * 4 + 0], fma(v[1], m[9728 + i * 4 + 1], fma(v[2], m[9728 + i * 4 + 2], fma(v[3], m[9728 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d4 + d6];
	v[1] = psi[I + d0 + d4 + d6];
	v[2] = psi[I + d1 + d4 + d6];
	v[3] = psi[I + d0 + d1 + d4 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[10240 + i * 4 + 0], fma(v[1], m[10240 + i * 4 + 1], fma(v[2], m[10240 + i * 4 + 2], fma(v[3], m[10240 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d4 + d6];
	v[1] = psi[I + d0 + d2 + d4 + d6];
	v[2] = psi[I + d1 + d2 + d4 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d4 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[10752 + i * 4 + 0], fma(v[1], m[10752 + i * 4 + 1], fma(v[2], m[10752 + i * 4 + 2], fma(v[3], m[10752 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d4 + d6];
	v[1] = psi[I + d0 + d3 + d4 + d6];
	v[2] = psi[I + d1 + d3 + d4 + d6];
	v[3] = psi[I + d0 + d1 + d3 + d4 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[11264 + i * 4 + 0], fma(v[1], m[11264 + i * 4 + 1], fma(v[2], m[11264 + i * 4 + 2], fma(v[3], m[11264 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d4 + d6];
	v[1] = psi[I + d0 + d2 + d3 + d4 + d6];
	v[2] = psi[I + d1 + d2 + d3 + d4 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d4 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[11776 + i * 4 + 0], fma(v[1], m[11776 + i * 4 + 1], fma(v[2], m[11776 + i * 4 + 2], fma(v[3], m[11776 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d5 + d6];
	v[1] = psi[I + d0 + d5 + d6];
	v[2] = psi[I + d1 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[12288 + i * 4 + 0], fma(v[1], m[12288 + i * 4 + 1], fma(v[2], m[12288 + i * 4 + 2], fma(v[3], m[12288 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d5 + d6];
	v[1] = psi[I + d0 + d2 + d5 + d6];
	v[2] = psi[I + d1 + d2 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[12800 + i * 4 + 0], fma(v[1], m[12800 + i * 4 + 1], fma(v[2], m[12800 + i * 4 + 2], fma(v[3], m[12800 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d5 + d6];
	v[1] = psi[I + d0 + d3 + d5 + d6];
	v[2] = psi[I + d1 + d3 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d3 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[13312 + i * 4 + 0], fma(v[1], m[13312 + i * 4 + 1], fma(v[2], m[13312 + i * 4 + 2], fma(v[3], m[13312 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d5 + d6];
	v[1] = psi[I + d0 + d2 + d3 + d5 + d6];
	v[2] = psi[I + d1 + d2 + d3 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[13824 + i * 4 + 0], fma(v[1], m[13824 + i * 4 + 1], fma(v[2], m[13824 + i * 4 + 2], fma(v[3], m[13824 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d4 + d5 + d6];
	v[1] = psi[I + d0 + d4 + d5 + d6];
	v[2] = psi[I + d1 + d4 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d4 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[14336 + i * 4 + 0], fma(v[1], m[14336 + i * 4 + 1], fma(v[2], m[14336 + i * 4 + 2], fma(v[3], m[14336 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d4 + d5 + d6];
	v[1] = psi[I + d0 + d2 + d4 + d5 + d6];
	v[2] = psi[I + d1 + d2 + d4 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d4 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[14848 + i * 4 + 0], fma(v[1], m[14848 + i * 4 + 1], fma(v[2], m[14848 + i * 4 + 2], fma(v[3], m[14848 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d3 + d4 + d5 + d6];
	v[1] = psi[I + d0 + d3 + d4 + d5 + d6];
	v[2] = psi[I + d1 + d3 + d4 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d3 + d4 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[15360 + i * 4 + 0], fma(v[1], m[15360 + i * 4 + 1], fma(v[2], m[15360 + i * 4 + 2], fma(v[3], m[15360 + i * 4 + 3], tmp[i]))));
	}


	v[0] = psi[I + d2 + d3 + d4 + d5 + d6];
	v[1] = psi[I + d0 + d2 + d3 + d4 + d5 + d6];
	v[2] = psi[I + d1 + d2 + d3 + d4 + d5 + d6];
	v[3] = psi[I + d0 + d1 + d2 + d3 + d4 + d5 + d6];
	for (unsigned i = 0; i < 128; ++i){
		tmp[i] = fma(v[0], m[15872 + i * 4 + 0], fma(v[1], m[15872 + i * 4 + 1], fma(v[2], m[15872 + i * 4 + 2], fma(v[3], m[15872 + i * 4 + 3], tmp[i]))));
	}

	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];
	psi[I + d1] = tmp[2];
	psi[I + d0 + d1] = tmp[3];
	psi[I + d2] = tmp[4];
	psi[I + d0 + d2] = tmp[5];
	psi[I + d1 + d2] = tmp[6];
	psi[I + d0 + d1 + d2] = tmp[7];
	psi[I + d3] = tmp[8];
	psi[I + d0 + d3] = tmp[9];
	psi[I + d1 + d3] = tmp[10];
	psi[I + d0 + d1 + d3] = tmp[11];
	psi[I + d2 + d3] = tmp[12];
	psi[I + d0 + d2 + d3] = tmp[13];
	psi[I + d1 + d2 + d3] = tmp[14];
	psi[I + d0 + d1 + d2 + d3] = tmp[15];
	psi[I + d4] = tmp[16];
	psi[I + d0 + d4] = tmp[17];
	psi[I + d1 + d4] = tmp[18];
	psi[I + d0 + d1 + d4] = tmp[19];
	psi[I + d2 + d4] = tmp[20];
	psi[I + d0 + d2 + d4] = tmp[21];
	psi[I + d1 + d2 + d4] = tmp[22];
	psi[I + d0 + d1 + d2 + d4] = tmp[23];
	psi[I + d3 + d4] = tmp[24];
	psi[I + d0 + d3 + d4] = tmp[25];
	psi[I + d1 + d3 + d4] = tmp[26];
	psi[I + d0 + d1 + d3 + d4] = tmp[27];
	psi[I + d2 + d3 + d4] = tmp[28];
	psi[I + d0 + d2 + d3 + d4] = tmp[29];
	psi[I + d1 + d2 + d3 + d4] = tmp[30];
	psi[I + d0 + d1 + d2 + d3 + d4] = tmp[31];
	psi[I + d5] = tmp[32];
	psi[I + d0 + d5] = tmp[33];
	psi[I + d1 + d5] = tmp[34];
	psi[I + d0 + d1 + d5] = tmp[35];
	psi[I + d2 + d5] = tmp[36];
	psi[I + d0 + d2 + d5] = tmp[37];
	psi[I + d1 + d2 + d5] = tmp[38];
	psi[I + d0 + d1 + d2 + d5] = tmp[39];
	psi[I + d3 + d5] = tmp[40];
	psi[I + d0 + d3 + d5] = tmp[41];
	psi[I + d1 + d3 + d5] = tmp[42];
	psi[I + d0 + d1 + d3 + d5] = tmp[43];
	psi[I + d2 + d3 + d5] = tmp[44];
	psi[I + d0 + d2 + d3 + d5] = tmp[45];
	psi[I + d1 + d2 + d3 + d5] = tmp[46];
	psi[I + d0 + d1 + d2 + d3 + d5] = tmp[47];
	psi[I + d4 + d5] = tmp[48];
	psi[I + d0 + d4 + d5] = tmp[49];
	psi[I + d1 + d4 + d5] = tmp[50];
	psi[I + d0 + d1 + d4 + d5] = tmp[51];
	psi[I + d2 + d4 + d5] = tmp[52];
	psi[I + d0 + d2 + d4 + d5] = tmp[53];
	psi[I + d1 + d2 + d4 + d5] = tmp[54];
	psi[I + d0 + d1 + d2 + d4 + d5] = tmp[55];
	psi[I + d3 + d4 + d5] = tmp[56];
	psi[I + d0 + d3 + d4 + d5] = tmp[57];
	psi[I + d1 + d3 + d4 + d5] = tmp[58];
	psi[I + d0 + d1 + d3 + d4 + d5] = tmp[59];
	psi[I + d2 + d3 + d4 + d5] = tmp[60];
	psi[I + d0 + d2 + d3 + d4 + d5] = tmp[61];
	psi[I + d1 + d2 + d3 + d4 + d5] = tmp[62];
	psi[I + d0 + d1 + d2 + d3 + d4 + d5] = tmp[63];
	psi[I + d6] = tmp[64];
	psi[I + d0 + d6] = tmp[65];
	psi[I + d1 + d6] = tmp[66];
	psi[I + d0 + d1 + d6] = tmp[67];
	psi[I + d2 + d6] = tmp[68];
	psi[I + d0 + d2 + d6] = tmp[69];
	psi[I + d1 + d2 + d6] = tmp[70];
	psi[I + d0 + d1 + d2 + d6] = tmp[71];
	psi[I + d3 + d6] = tmp[72];
	psi[I + d0 + d3 + d6] = tmp[73];
	psi[I + d1 + d3 + d6] = tmp[74];
	psi[I + d0 + d1 + d3 + d6] = tmp[75];
	psi[I + d2 + d3 + d6] = tmp[76];
	psi[I + d0 + d2 + d3 + d6] = tmp[77];
	psi[I + d1 + d2 + d3 + d6] = tmp[78];
	psi[I + d0 + d1 + d2 + d3 + d6] = tmp[79];
	psi[I + d4 + d6] = tmp[80];
	psi[I + d0 + d4 + d6] = tmp[81];
	psi[I + d1 + d4 + d6] = tmp[82];
	psi[I + d0 + d1 + d4 + d6] = tmp[83];
	psi[I + d2 + d4 + d6] = tmp[84];
	psi[I + d0 + d2 + d4 + d6] = tmp[85];
	psi[I + d1 + d2 + d4 + d6] = tmp[86];
	psi[I + d0 + d1 + d2 + d4 + d6] = tmp[87];
	psi[I + d3 + d4 + d6] = tmp[88];
	psi[I + d0 + d3 + d4 + d6] = tmp[89];
	psi[I + d1 + d3 + d4 + d6] = tmp[90];
	psi[I + d0 + d1 + d3 + d4 + d6] = tmp[91];
	psi[I + d2 + d3 + d4 + d6] = tmp[92];
	psi[I + d0 + d2 + d3 + d4 + d6] = tmp[93];
	psi[I + d1 + d2 + d3 + d4 + d6] = tmp[94];
	psi[I + d0 + d1 + d2 + d3 + d4 + d6] = tmp[95];
	psi[I + d5 + d6] = tmp[96];
	psi[I + d0 + d5 + d6] = tmp[97];
	psi[I + d1 + d5 + d6] = tmp[98];
	psi[I + d0 + d1 + d5 + d6] = tmp[99];
	psi[I + d2 + d5 + d6] = tmp[100];
	psi[I + d0 + d2 + d5 + d6] = tmp[101];
	psi[I + d1 + d2 + d5 + d6] = tmp[102];
	psi[I + d0 + d1 + d2 + d5 + d6] = tmp[103];
	psi[I + d3 + d5 + d6] = tmp[104];
	psi[I + d0 + d3 + d5 + d6] = tmp[105];
	psi[I + d1 + d3 + d5 + d6] = tmp[106];
	psi[I + d0 + d1 + d3 + d5 + d6] = tmp[107];
	psi[I + d2 + d3 + d5 + d6] = tmp[108];
	psi[I + d0 + d2 + d3 + d5 + d6] = tmp[109];
	psi[I + d1 + d2 + d3 + d5 + d6] = tmp[110];
	psi[I + d0 + d1 + d2 + d3 + d5 + d6] = tmp[111];
	psi[I + d4 + d5 + d6] = tmp[112];
	psi[I + d0 + d4 + d5 + d6] = tmp[113];
	psi[I + d1 + d4 + d5 + d6] = tmp[114];
	psi[I + d0 + d1 + d4 + d5 + d6] = tmp[115];
	psi[I + d2 + d4 + d5 + d6] = tmp[116];
	psi[I + d0 + d2 + d4 + d5 + d6] = tmp[117];
	psi[I + d1 + d2 + d4 + d5 + d6] = tmp[118];
	psi[I + d0 + d1 + d2 + d4 + d5 + d6] = tmp[119];
	psi[I + d3 + d4 + d5 + d6] = tmp[120];
	psi[I + d0 + d3 + d4 + d5 + d6] = tmp[121];
	psi[I + d1 + d3 + d4 + d5 + d6] = tmp[122];
	psi[I + d0 + d1 + d3 + d4 + d5 + d6] = tmp[123];
	psi[I + d2 + d3 + d4 + d5 + d6] = tmp[124];
	psi[I + d0 + d2 + d3 + d4 + d5 + d6] = tmp[125];
	psi[I + d1 + d2 + d3 + d4 + d5 + d6] = tmp[126];
	psi[I + d0 + d1 + d2 + d3 + d4 + d5 + d6] = tmp[127];

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

	std::complex<double> mm[16384];
	for (unsigned b = 0; b < 32; ++b){
		for (unsigned r = 0; r < 128; ++r){
			for (unsigned c = 0; c < 4; ++c){
				mm[b*512+r*4+c] = m[r][c+b*4];
			}
		}
	}


#ifndef _MSC_VER_OR_WSL
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE7) schedule(static)
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
		#pragma omp parallel for collapse(LOOP_COLLAPSE7) schedule(static)
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

