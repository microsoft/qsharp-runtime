// (C) 2018 ETH Zurich, ITP, Thomas HΣner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, M const& m, M const& mt)
{
	__m512d v[2];

	v[0] = load1x4(&psi[I]);
	v[1] = load1x4(&psi[I + d0]);

	__m512d tmp[8] = {_mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd(), _mm512_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], fma(v[1], m[1], mt[1], tmp[0]));
	tmp[1] = fma(v[0], m[2], mt[2], fma(v[1], m[3], mt[3], tmp[1]));
	tmp[2] = fma(v[0], m[4], mt[4], fma(v[1], m[5], mt[5], tmp[2]));
	tmp[3] = fma(v[0], m[6], mt[6], fma(v[1], m[7], mt[7], tmp[3]));
	tmp[4] = fma(v[0], m[8], mt[8], fma(v[1], m[9], mt[9], tmp[4]));
	tmp[5] = fma(v[0], m[10], mt[10], fma(v[1], m[11], mt[11], tmp[5]));
	tmp[6] = fma(v[0], m[12], mt[12], fma(v[1], m[13], mt[13], tmp[6]));
	tmp[7] = fma(v[0], m[14], mt[14], fma(v[1], m[15], mt[15], tmp[7]));

	v[0] = load1x4(&psi[I + d1]);
	v[1] = load1x4(&psi[I + d0 + d1]);

	tmp[0] = fma(v[0], m[16], mt[16], fma(v[1], m[17], mt[17], tmp[0]));
	tmp[1] = fma(v[0], m[18], mt[18], fma(v[1], m[19], mt[19], tmp[1]));
	tmp[2] = fma(v[0], m[20], mt[20], fma(v[1], m[21], mt[21], tmp[2]));
	tmp[3] = fma(v[0], m[22], mt[22], fma(v[1], m[23], mt[23], tmp[3]));
	tmp[4] = fma(v[0], m[24], mt[24], fma(v[1], m[25], mt[25], tmp[4]));
	tmp[5] = fma(v[0], m[26], mt[26], fma(v[1], m[27], mt[27], tmp[5]));
	tmp[6] = fma(v[0], m[28], mt[28], fma(v[1], m[29], mt[29], tmp[6]));
	tmp[7] = fma(v[0], m[30], mt[30], fma(v[1], m[31], mt[31], tmp[7]));

	v[0] = load1x4(&psi[I + d2]);
	v[1] = load1x4(&psi[I + d0 + d2]);

	tmp[0] = fma(v[0], m[32], mt[32], fma(v[1], m[33], mt[33], tmp[0]));
	tmp[1] = fma(v[0], m[34], mt[34], fma(v[1], m[35], mt[35], tmp[1]));
	tmp[2] = fma(v[0], m[36], mt[36], fma(v[1], m[37], mt[37], tmp[2]));
	tmp[3] = fma(v[0], m[38], mt[38], fma(v[1], m[39], mt[39], tmp[3]));
	tmp[4] = fma(v[0], m[40], mt[40], fma(v[1], m[41], mt[41], tmp[4]));
	tmp[5] = fma(v[0], m[42], mt[42], fma(v[1], m[43], mt[43], tmp[5]));
	tmp[6] = fma(v[0], m[44], mt[44], fma(v[1], m[45], mt[45], tmp[6]));
	tmp[7] = fma(v[0], m[46], mt[46], fma(v[1], m[47], mt[47], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d2]);
	v[1] = load1x4(&psi[I + d0 + d1 + d2]);

	tmp[0] = fma(v[0], m[48], mt[48], fma(v[1], m[49], mt[49], tmp[0]));
	tmp[1] = fma(v[0], m[50], mt[50], fma(v[1], m[51], mt[51], tmp[1]));
	tmp[2] = fma(v[0], m[52], mt[52], fma(v[1], m[53], mt[53], tmp[2]));
	tmp[3] = fma(v[0], m[54], mt[54], fma(v[1], m[55], mt[55], tmp[3]));
	tmp[4] = fma(v[0], m[56], mt[56], fma(v[1], m[57], mt[57], tmp[4]));
	tmp[5] = fma(v[0], m[58], mt[58], fma(v[1], m[59], mt[59], tmp[5]));
	tmp[6] = fma(v[0], m[60], mt[60], fma(v[1], m[61], mt[61], tmp[6]));
	tmp[7] = fma(v[0], m[62], mt[62], fma(v[1], m[63], mt[63], tmp[7]));

	v[0] = load1x4(&psi[I + d3]);
	v[1] = load1x4(&psi[I + d0 + d3]);

	tmp[0] = fma(v[0], m[64], mt[64], fma(v[1], m[65], mt[65], tmp[0]));
	tmp[1] = fma(v[0], m[66], mt[66], fma(v[1], m[67], mt[67], tmp[1]));
	tmp[2] = fma(v[0], m[68], mt[68], fma(v[1], m[69], mt[69], tmp[2]));
	tmp[3] = fma(v[0], m[70], mt[70], fma(v[1], m[71], mt[71], tmp[3]));
	tmp[4] = fma(v[0], m[72], mt[72], fma(v[1], m[73], mt[73], tmp[4]));
	tmp[5] = fma(v[0], m[74], mt[74], fma(v[1], m[75], mt[75], tmp[5]));
	tmp[6] = fma(v[0], m[76], mt[76], fma(v[1], m[77], mt[77], tmp[6]));
	tmp[7] = fma(v[0], m[78], mt[78], fma(v[1], m[79], mt[79], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d3]);
	v[1] = load1x4(&psi[I + d0 + d1 + d3]);

	tmp[0] = fma(v[0], m[80], mt[80], fma(v[1], m[81], mt[81], tmp[0]));
	tmp[1] = fma(v[0], m[82], mt[82], fma(v[1], m[83], mt[83], tmp[1]));
	tmp[2] = fma(v[0], m[84], mt[84], fma(v[1], m[85], mt[85], tmp[2]));
	tmp[3] = fma(v[0], m[86], mt[86], fma(v[1], m[87], mt[87], tmp[3]));
	tmp[4] = fma(v[0], m[88], mt[88], fma(v[1], m[89], mt[89], tmp[4]));
	tmp[5] = fma(v[0], m[90], mt[90], fma(v[1], m[91], mt[91], tmp[5]));
	tmp[6] = fma(v[0], m[92], mt[92], fma(v[1], m[93], mt[93], tmp[6]));
	tmp[7] = fma(v[0], m[94], mt[94], fma(v[1], m[95], mt[95], tmp[7]));

	v[0] = load1x4(&psi[I + d2 + d3]);
	v[1] = load1x4(&psi[I + d0 + d2 + d3]);

	tmp[0] = fma(v[0], m[96], mt[96], fma(v[1], m[97], mt[97], tmp[0]));
	tmp[1] = fma(v[0], m[98], mt[98], fma(v[1], m[99], mt[99], tmp[1]));
	tmp[2] = fma(v[0], m[100], mt[100], fma(v[1], m[101], mt[101], tmp[2]));
	tmp[3] = fma(v[0], m[102], mt[102], fma(v[1], m[103], mt[103], tmp[3]));
	tmp[4] = fma(v[0], m[104], mt[104], fma(v[1], m[105], mt[105], tmp[4]));
	tmp[5] = fma(v[0], m[106], mt[106], fma(v[1], m[107], mt[107], tmp[5]));
	tmp[6] = fma(v[0], m[108], mt[108], fma(v[1], m[109], mt[109], tmp[6]));
	tmp[7] = fma(v[0], m[110], mt[110], fma(v[1], m[111], mt[111], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d2 + d3]);
	v[1] = load1x4(&psi[I + d0 + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[112], mt[112], fma(v[1], m[113], mt[113], tmp[0]));
	tmp[1] = fma(v[0], m[114], mt[114], fma(v[1], m[115], mt[115], tmp[1]));
	tmp[2] = fma(v[0], m[116], mt[116], fma(v[1], m[117], mt[117], tmp[2]));
	tmp[3] = fma(v[0], m[118], mt[118], fma(v[1], m[119], mt[119], tmp[3]));
	tmp[4] = fma(v[0], m[120], mt[120], fma(v[1], m[121], mt[121], tmp[4]));
	tmp[5] = fma(v[0], m[122], mt[122], fma(v[1], m[123], mt[123], tmp[5]));
	tmp[6] = fma(v[0], m[124], mt[124], fma(v[1], m[125], mt[125], tmp[6]));
	tmp[7] = fma(v[0], m[126], mt[126], fma(v[1], m[127], mt[127], tmp[7]));

	v[0] = load1x4(&psi[I + d4]);
	v[1] = load1x4(&psi[I + d0 + d4]);

	tmp[0] = fma(v[0], m[128], mt[128], fma(v[1], m[129], mt[129], tmp[0]));
	tmp[1] = fma(v[0], m[130], mt[130], fma(v[1], m[131], mt[131], tmp[1]));
	tmp[2] = fma(v[0], m[132], mt[132], fma(v[1], m[133], mt[133], tmp[2]));
	tmp[3] = fma(v[0], m[134], mt[134], fma(v[1], m[135], mt[135], tmp[3]));
	tmp[4] = fma(v[0], m[136], mt[136], fma(v[1], m[137], mt[137], tmp[4]));
	tmp[5] = fma(v[0], m[138], mt[138], fma(v[1], m[139], mt[139], tmp[5]));
	tmp[6] = fma(v[0], m[140], mt[140], fma(v[1], m[141], mt[141], tmp[6]));
	tmp[7] = fma(v[0], m[142], mt[142], fma(v[1], m[143], mt[143], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d4]);
	v[1] = load1x4(&psi[I + d0 + d1 + d4]);

	tmp[0] = fma(v[0], m[144], mt[144], fma(v[1], m[145], mt[145], tmp[0]));
	tmp[1] = fma(v[0], m[146], mt[146], fma(v[1], m[147], mt[147], tmp[1]));
	tmp[2] = fma(v[0], m[148], mt[148], fma(v[1], m[149], mt[149], tmp[2]));
	tmp[3] = fma(v[0], m[150], mt[150], fma(v[1], m[151], mt[151], tmp[3]));
	tmp[4] = fma(v[0], m[152], mt[152], fma(v[1], m[153], mt[153], tmp[4]));
	tmp[5] = fma(v[0], m[154], mt[154], fma(v[1], m[155], mt[155], tmp[5]));
	tmp[6] = fma(v[0], m[156], mt[156], fma(v[1], m[157], mt[157], tmp[6]));
	tmp[7] = fma(v[0], m[158], mt[158], fma(v[1], m[159], mt[159], tmp[7]));

	v[0] = load1x4(&psi[I + d2 + d4]);
	v[1] = load1x4(&psi[I + d0 + d2 + d4]);

	tmp[0] = fma(v[0], m[160], mt[160], fma(v[1], m[161], mt[161], tmp[0]));
	tmp[1] = fma(v[0], m[162], mt[162], fma(v[1], m[163], mt[163], tmp[1]));
	tmp[2] = fma(v[0], m[164], mt[164], fma(v[1], m[165], mt[165], tmp[2]));
	tmp[3] = fma(v[0], m[166], mt[166], fma(v[1], m[167], mt[167], tmp[3]));
	tmp[4] = fma(v[0], m[168], mt[168], fma(v[1], m[169], mt[169], tmp[4]));
	tmp[5] = fma(v[0], m[170], mt[170], fma(v[1], m[171], mt[171], tmp[5]));
	tmp[6] = fma(v[0], m[172], mt[172], fma(v[1], m[173], mt[173], tmp[6]));
	tmp[7] = fma(v[0], m[174], mt[174], fma(v[1], m[175], mt[175], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d2 + d4]);
	v[1] = load1x4(&psi[I + d0 + d1 + d2 + d4]);

	tmp[0] = fma(v[0], m[176], mt[176], fma(v[1], m[177], mt[177], tmp[0]));
	tmp[1] = fma(v[0], m[178], mt[178], fma(v[1], m[179], mt[179], tmp[1]));
	tmp[2] = fma(v[0], m[180], mt[180], fma(v[1], m[181], mt[181], tmp[2]));
	tmp[3] = fma(v[0], m[182], mt[182], fma(v[1], m[183], mt[183], tmp[3]));
	tmp[4] = fma(v[0], m[184], mt[184], fma(v[1], m[185], mt[185], tmp[4]));
	tmp[5] = fma(v[0], m[186], mt[186], fma(v[1], m[187], mt[187], tmp[5]));
	tmp[6] = fma(v[0], m[188], mt[188], fma(v[1], m[189], mt[189], tmp[6]));
	tmp[7] = fma(v[0], m[190], mt[190], fma(v[1], m[191], mt[191], tmp[7]));

	v[0] = load1x4(&psi[I + d3 + d4]);
	v[1] = load1x4(&psi[I + d0 + d3 + d4]);

	tmp[0] = fma(v[0], m[192], mt[192], fma(v[1], m[193], mt[193], tmp[0]));
	tmp[1] = fma(v[0], m[194], mt[194], fma(v[1], m[195], mt[195], tmp[1]));
	tmp[2] = fma(v[0], m[196], mt[196], fma(v[1], m[197], mt[197], tmp[2]));
	tmp[3] = fma(v[0], m[198], mt[198], fma(v[1], m[199], mt[199], tmp[3]));
	tmp[4] = fma(v[0], m[200], mt[200], fma(v[1], m[201], mt[201], tmp[4]));
	tmp[5] = fma(v[0], m[202], mt[202], fma(v[1], m[203], mt[203], tmp[5]));
	tmp[6] = fma(v[0], m[204], mt[204], fma(v[1], m[205], mt[205], tmp[6]));
	tmp[7] = fma(v[0], m[206], mt[206], fma(v[1], m[207], mt[207], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d3 + d4]);
	v[1] = load1x4(&psi[I + d0 + d1 + d3 + d4]);

	tmp[0] = fma(v[0], m[208], mt[208], fma(v[1], m[209], mt[209], tmp[0]));
	tmp[1] = fma(v[0], m[210], mt[210], fma(v[1], m[211], mt[211], tmp[1]));
	tmp[2] = fma(v[0], m[212], mt[212], fma(v[1], m[213], mt[213], tmp[2]));
	tmp[3] = fma(v[0], m[214], mt[214], fma(v[1], m[215], mt[215], tmp[3]));
	tmp[4] = fma(v[0], m[216], mt[216], fma(v[1], m[217], mt[217], tmp[4]));
	tmp[5] = fma(v[0], m[218], mt[218], fma(v[1], m[219], mt[219], tmp[5]));
	tmp[6] = fma(v[0], m[220], mt[220], fma(v[1], m[221], mt[221], tmp[6]));
	tmp[7] = fma(v[0], m[222], mt[222], fma(v[1], m[223], mt[223], tmp[7]));

	v[0] = load1x4(&psi[I + d2 + d3 + d4]);
	v[1] = load1x4(&psi[I + d0 + d2 + d3 + d4]);

	tmp[0] = fma(v[0], m[224], mt[224], fma(v[1], m[225], mt[225], tmp[0]));
	tmp[1] = fma(v[0], m[226], mt[226], fma(v[1], m[227], mt[227], tmp[1]));
	tmp[2] = fma(v[0], m[228], mt[228], fma(v[1], m[229], mt[229], tmp[2]));
	tmp[3] = fma(v[0], m[230], mt[230], fma(v[1], m[231], mt[231], tmp[3]));
	tmp[4] = fma(v[0], m[232], mt[232], fma(v[1], m[233], mt[233], tmp[4]));
	tmp[5] = fma(v[0], m[234], mt[234], fma(v[1], m[235], mt[235], tmp[5]));
	tmp[6] = fma(v[0], m[236], mt[236], fma(v[1], m[237], mt[237], tmp[6]));
	tmp[7] = fma(v[0], m[238], mt[238], fma(v[1], m[239], mt[239], tmp[7]));

	v[0] = load1x4(&psi[I + d1 + d2 + d3 + d4]);
	v[1] = load1x4(&psi[I + d0 + d1 + d2 + d3 + d4]);

	tmp[0] = fma(v[0], m[240], mt[240], fma(v[1], m[241], mt[241], tmp[0]));
	tmp[1] = fma(v[0], m[242], mt[242], fma(v[1], m[243], mt[243], tmp[1]));
	tmp[2] = fma(v[0], m[244], mt[244], fma(v[1], m[245], mt[245], tmp[2]));
	tmp[3] = fma(v[0], m[246], mt[246], fma(v[1], m[247], mt[247], tmp[3]));
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], (double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], (double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[1]);
	store((double*)&psi[I + d0 + d1 + d3], (double*)&psi[I + d1 + d3], (double*)&psi[I + d0 + d3], (double*)&psi[I + d3], tmp[2]);
	store((double*)&psi[I + d0 + d1 + d2 + d3], (double*)&psi[I + d1 + d2 + d3], (double*)&psi[I + d0 + d2 + d3], (double*)&psi[I + d2 + d3], tmp[3]);
	tmp[4] = fma(v[0], m[248], mt[248], fma(v[1], m[249], mt[249], tmp[4]));
	tmp[5] = fma(v[0], m[250], mt[250], fma(v[1], m[251], mt[251], tmp[5]));
	tmp[6] = fma(v[0], m[252], mt[252], fma(v[1], m[253], mt[253], tmp[6]));
	tmp[7] = fma(v[0], m[254], mt[254], fma(v[1], m[255], mt[255], tmp[7]));
	store((double*)&psi[I + d0 + d1 + d4], (double*)&psi[I + d1 + d4], (double*)&psi[I + d0 + d4], (double*)&psi[I + d4], tmp[4]);
	store((double*)&psi[I + d0 + d1 + d2 + d4], (double*)&psi[I + d1 + d2 + d4], (double*)&psi[I + d0 + d2 + d4], (double*)&psi[I + d2 + d4], tmp[5]);
	store((double*)&psi[I + d0 + d1 + d3 + d4], (double*)&psi[I + d1 + d3 + d4], (double*)&psi[I + d0 + d3 + d4], (double*)&psi[I + d3 + d4], tmp[6]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4], (double*)&psi[I + d1 + d2 + d3 + d4], (double*)&psi[I + d0 + d2 + d3 + d4], (double*)&psi[I + d2 + d3 + d4], tmp[7]);

}

// bit indices id[.] are given from high to low (e.g. control first for CNOT)
template <class V, class M>
void kernel(V& psi, unsigned id4, unsigned id3, unsigned id2, unsigned id1, unsigned id0, M const& matrix, std::size_t ctrlmask)
{
     std::size_t n = psi.size();
	std::size_t d0 = 1ULL << id0;
	std::size_t d1 = 1ULL << id1;
	std::size_t d2 = 1ULL << id2;
	std::size_t d3 = 1ULL << id3;
	std::size_t d4 = 1ULL << id4;
	auto m = matrix;
	std::size_t dsorted[] = {d0, d1, d2, d3, d4};
	permute_qubits_and_matrix(dsorted, 5, m);

	__m512d mm[256];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 8; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mm[b*16+r*2+c] = loada(&m[4*r+0][c+b*2], &m[4*r+1][c+b*2], &m[4*r+2][c+b*2], &m[4*r+3][c+b*2]);
			}
		}
	}

	__m512d mmt[256];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 8; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mmt[b*16+r*2+c] = loadbm(&m[4*r+0][c+b*2], &m[4*r+1][c+b*2], &m[4*r+2][c+b*2], &m[4*r+3][c+b*2]);
			}
		}
	}


#ifndef _MSC_VER
	if (ctrlmask == 0){
		#pragma omp parallel for collapse(LOOP_COLLAPSE5) schedule(static) proc_bind(spread)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; ++i5){
								kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
							}
						}
					}
				}
			}
		}
	}
	else{
		#pragma omp parallel for collapse(LOOP_COLLAPSE5) schedule(static)
		for (std::size_t i0 = 0; i0 < n; i0 += 2 * dsorted[0]){
			for (std::size_t i1 = 0; i1 < dsorted[0]; i1 += 2 * dsorted[1]){
				for (std::size_t i2 = 0; i2 < dsorted[1]; i2 += 2 * dsorted[2]){
					for (std::size_t i3 = 0; i3 < dsorted[2]; i3 += 2 * dsorted[3]){
						for (std::size_t i4 = 0; i4 < dsorted[3]; i4 += 2 * dsorted[4]){
							for (std::size_t i5 = 0; i5 < dsorted[4]; ++i5){
								if (((i0 + i1 + i2 + i3 + i4 + i5)&ctrlmask) == ctrlmask)
									kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
							}
						}
					}
				}
			}
		}
	}
#else
    std::intptr_t zero = 0;
    std::intptr_t dmask = dsorted[0] + dsorted[1] + dsorted[2] + dsorted[3] + dsorted[4];

    if (ctrlmask == 0){
        #pragma omp parallel for schedule(static)
        for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
            if ((i & dmask) == zero)
                kernel_core(psi, i, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
     } else {
        #pragma omp parallel for schedule(static)
        for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
            if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
                kernel_core(psi, i, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm, mmt);
     }
#endif
}

