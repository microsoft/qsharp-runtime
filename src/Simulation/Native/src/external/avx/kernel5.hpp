// (C) 2018 ETH Zurich, ITP, Thomas HΣner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, M const& m, M const& mt)
{
	__m256d v[2];

	v[0] = load1(&psi[I]);
	v[1] = load1(&psi[I + d0]);

	__m256d tmp[16] = {_mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd(), _mm256_setzero_pd()};

	tmp[0] = fma(v[0], m[0], mt[0], fma(v[1], m[1], mt[1], tmp[0]));
	tmp[1] = fma(v[0], m[2], mt[2], fma(v[1], m[3], mt[3], tmp[1]));
	tmp[2] = fma(v[0], m[4], mt[4], fma(v[1], m[5], mt[5], tmp[2]));
	tmp[3] = fma(v[0], m[6], mt[6], fma(v[1], m[7], mt[7], tmp[3]));
	tmp[4] = fma(v[0], m[8], mt[8], fma(v[1], m[9], mt[9], tmp[4]));
	tmp[5] = fma(v[0], m[10], mt[10], fma(v[1], m[11], mt[11], tmp[5]));
	tmp[6] = fma(v[0], m[12], mt[12], fma(v[1], m[13], mt[13], tmp[6]));
	tmp[7] = fma(v[0], m[14], mt[14], fma(v[1], m[15], mt[15], tmp[7]));
	tmp[8] = fma(v[0], m[16], mt[16], fma(v[1], m[17], mt[17], tmp[8]));
	tmp[9] = fma(v[0], m[18], mt[18], fma(v[1], m[19], mt[19], tmp[9]));
	tmp[10] = fma(v[0], m[20], mt[20], fma(v[1], m[21], mt[21], tmp[10]));
	tmp[11] = fma(v[0], m[22], mt[22], fma(v[1], m[23], mt[23], tmp[11]));
	tmp[12] = fma(v[0], m[24], mt[24], fma(v[1], m[25], mt[25], tmp[12]));
	tmp[13] = fma(v[0], m[26], mt[26], fma(v[1], m[27], mt[27], tmp[13]));
	tmp[14] = fma(v[0], m[28], mt[28], fma(v[1], m[29], mt[29], tmp[14]));
	tmp[15] = fma(v[0], m[30], mt[30], fma(v[1], m[31], mt[31], tmp[15]));

	v[0] = load1(&psi[I + d1]);
	v[1] = load1(&psi[I + d0 + d1]);

	tmp[0] = fma(v[0], m[32], mt[32], fma(v[1], m[33], mt[33], tmp[0]));
	tmp[1] = fma(v[0], m[34], mt[34], fma(v[1], m[35], mt[35], tmp[1]));
	tmp[2] = fma(v[0], m[36], mt[36], fma(v[1], m[37], mt[37], tmp[2]));
	tmp[3] = fma(v[0], m[38], mt[38], fma(v[1], m[39], mt[39], tmp[3]));
	tmp[4] = fma(v[0], m[40], mt[40], fma(v[1], m[41], mt[41], tmp[4]));
	tmp[5] = fma(v[0], m[42], mt[42], fma(v[1], m[43], mt[43], tmp[5]));
	tmp[6] = fma(v[0], m[44], mt[44], fma(v[1], m[45], mt[45], tmp[6]));
	tmp[7] = fma(v[0], m[46], mt[46], fma(v[1], m[47], mt[47], tmp[7]));
	tmp[8] = fma(v[0], m[48], mt[48], fma(v[1], m[49], mt[49], tmp[8]));
	tmp[9] = fma(v[0], m[50], mt[50], fma(v[1], m[51], mt[51], tmp[9]));
	tmp[10] = fma(v[0], m[52], mt[52], fma(v[1], m[53], mt[53], tmp[10]));
	tmp[11] = fma(v[0], m[54], mt[54], fma(v[1], m[55], mt[55], tmp[11]));
	tmp[12] = fma(v[0], m[56], mt[56], fma(v[1], m[57], mt[57], tmp[12]));
	tmp[13] = fma(v[0], m[58], mt[58], fma(v[1], m[59], mt[59], tmp[13]));
	tmp[14] = fma(v[0], m[60], mt[60], fma(v[1], m[61], mt[61], tmp[14]));
	tmp[15] = fma(v[0], m[62], mt[62], fma(v[1], m[63], mt[63], tmp[15]));

	v[0] = load1(&psi[I + d2]);
	v[1] = load1(&psi[I + d0 + d2]);

	tmp[0] = fma(v[0], m[64], mt[64], fma(v[1], m[65], mt[65], tmp[0]));
	tmp[1] = fma(v[0], m[66], mt[66], fma(v[1], m[67], mt[67], tmp[1]));
	tmp[2] = fma(v[0], m[68], mt[68], fma(v[1], m[69], mt[69], tmp[2]));
	tmp[3] = fma(v[0], m[70], mt[70], fma(v[1], m[71], mt[71], tmp[3]));
	tmp[4] = fma(v[0], m[72], mt[72], fma(v[1], m[73], mt[73], tmp[4]));
	tmp[5] = fma(v[0], m[74], mt[74], fma(v[1], m[75], mt[75], tmp[5]));
	tmp[6] = fma(v[0], m[76], mt[76], fma(v[1], m[77], mt[77], tmp[6]));
	tmp[7] = fma(v[0], m[78], mt[78], fma(v[1], m[79], mt[79], tmp[7]));
	tmp[8] = fma(v[0], m[80], mt[80], fma(v[1], m[81], mt[81], tmp[8]));
	tmp[9] = fma(v[0], m[82], mt[82], fma(v[1], m[83], mt[83], tmp[9]));
	tmp[10] = fma(v[0], m[84], mt[84], fma(v[1], m[85], mt[85], tmp[10]));
	tmp[11] = fma(v[0], m[86], mt[86], fma(v[1], m[87], mt[87], tmp[11]));
	tmp[12] = fma(v[0], m[88], mt[88], fma(v[1], m[89], mt[89], tmp[12]));
	tmp[13] = fma(v[0], m[90], mt[90], fma(v[1], m[91], mt[91], tmp[13]));
	tmp[14] = fma(v[0], m[92], mt[92], fma(v[1], m[93], mt[93], tmp[14]));
	tmp[15] = fma(v[0], m[94], mt[94], fma(v[1], m[95], mt[95], tmp[15]));

	v[0] = load1(&psi[I + d1 + d2]);
	v[1] = load1(&psi[I + d0 + d1 + d2]);

	tmp[0] = fma(v[0], m[96], mt[96], fma(v[1], m[97], mt[97], tmp[0]));
	tmp[1] = fma(v[0], m[98], mt[98], fma(v[1], m[99], mt[99], tmp[1]));
	tmp[2] = fma(v[0], m[100], mt[100], fma(v[1], m[101], mt[101], tmp[2]));
	tmp[3] = fma(v[0], m[102], mt[102], fma(v[1], m[103], mt[103], tmp[3]));
	tmp[4] = fma(v[0], m[104], mt[104], fma(v[1], m[105], mt[105], tmp[4]));
	tmp[5] = fma(v[0], m[106], mt[106], fma(v[1], m[107], mt[107], tmp[5]));
	tmp[6] = fma(v[0], m[108], mt[108], fma(v[1], m[109], mt[109], tmp[6]));
	tmp[7] = fma(v[0], m[110], mt[110], fma(v[1], m[111], mt[111], tmp[7]));
	tmp[8] = fma(v[0], m[112], mt[112], fma(v[1], m[113], mt[113], tmp[8]));
	tmp[9] = fma(v[0], m[114], mt[114], fma(v[1], m[115], mt[115], tmp[9]));
	tmp[10] = fma(v[0], m[116], mt[116], fma(v[1], m[117], mt[117], tmp[10]));
	tmp[11] = fma(v[0], m[118], mt[118], fma(v[1], m[119], mt[119], tmp[11]));
	tmp[12] = fma(v[0], m[120], mt[120], fma(v[1], m[121], mt[121], tmp[12]));
	tmp[13] = fma(v[0], m[122], mt[122], fma(v[1], m[123], mt[123], tmp[13]));
	tmp[14] = fma(v[0], m[124], mt[124], fma(v[1], m[125], mt[125], tmp[14]));
	tmp[15] = fma(v[0], m[126], mt[126], fma(v[1], m[127], mt[127], tmp[15]));

	v[0] = load1(&psi[I + d3]);
	v[1] = load1(&psi[I + d0 + d3]);

	tmp[0] = fma(v[0], m[128], mt[128], fma(v[1], m[129], mt[129], tmp[0]));
	tmp[1] = fma(v[0], m[130], mt[130], fma(v[1], m[131], mt[131], tmp[1]));
	tmp[2] = fma(v[0], m[132], mt[132], fma(v[1], m[133], mt[133], tmp[2]));
	tmp[3] = fma(v[0], m[134], mt[134], fma(v[1], m[135], mt[135], tmp[3]));
	tmp[4] = fma(v[0], m[136], mt[136], fma(v[1], m[137], mt[137], tmp[4]));
	tmp[5] = fma(v[0], m[138], mt[138], fma(v[1], m[139], mt[139], tmp[5]));
	tmp[6] = fma(v[0], m[140], mt[140], fma(v[1], m[141], mt[141], tmp[6]));
	tmp[7] = fma(v[0], m[142], mt[142], fma(v[1], m[143], mt[143], tmp[7]));
	tmp[8] = fma(v[0], m[144], mt[144], fma(v[1], m[145], mt[145], tmp[8]));
	tmp[9] = fma(v[0], m[146], mt[146], fma(v[1], m[147], mt[147], tmp[9]));
	tmp[10] = fma(v[0], m[148], mt[148], fma(v[1], m[149], mt[149], tmp[10]));
	tmp[11] = fma(v[0], m[150], mt[150], fma(v[1], m[151], mt[151], tmp[11]));
	tmp[12] = fma(v[0], m[152], mt[152], fma(v[1], m[153], mt[153], tmp[12]));
	tmp[13] = fma(v[0], m[154], mt[154], fma(v[1], m[155], mt[155], tmp[13]));
	tmp[14] = fma(v[0], m[156], mt[156], fma(v[1], m[157], mt[157], tmp[14]));
	tmp[15] = fma(v[0], m[158], mt[158], fma(v[1], m[159], mt[159], tmp[15]));

	v[0] = load1(&psi[I + d1 + d3]);
	v[1] = load1(&psi[I + d0 + d1 + d3]);

	tmp[0] = fma(v[0], m[160], mt[160], fma(v[1], m[161], mt[161], tmp[0]));
	tmp[1] = fma(v[0], m[162], mt[162], fma(v[1], m[163], mt[163], tmp[1]));
	tmp[2] = fma(v[0], m[164], mt[164], fma(v[1], m[165], mt[165], tmp[2]));
	tmp[3] = fma(v[0], m[166], mt[166], fma(v[1], m[167], mt[167], tmp[3]));
	tmp[4] = fma(v[0], m[168], mt[168], fma(v[1], m[169], mt[169], tmp[4]));
	tmp[5] = fma(v[0], m[170], mt[170], fma(v[1], m[171], mt[171], tmp[5]));
	tmp[6] = fma(v[0], m[172], mt[172], fma(v[1], m[173], mt[173], tmp[6]));
	tmp[7] = fma(v[0], m[174], mt[174], fma(v[1], m[175], mt[175], tmp[7]));
	tmp[8] = fma(v[0], m[176], mt[176], fma(v[1], m[177], mt[177], tmp[8]));
	tmp[9] = fma(v[0], m[178], mt[178], fma(v[1], m[179], mt[179], tmp[9]));
	tmp[10] = fma(v[0], m[180], mt[180], fma(v[1], m[181], mt[181], tmp[10]));
	tmp[11] = fma(v[0], m[182], mt[182], fma(v[1], m[183], mt[183], tmp[11]));
	tmp[12] = fma(v[0], m[184], mt[184], fma(v[1], m[185], mt[185], tmp[12]));
	tmp[13] = fma(v[0], m[186], mt[186], fma(v[1], m[187], mt[187], tmp[13]));
	tmp[14] = fma(v[0], m[188], mt[188], fma(v[1], m[189], mt[189], tmp[14]));
	tmp[15] = fma(v[0], m[190], mt[190], fma(v[1], m[191], mt[191], tmp[15]));

	v[0] = load1(&psi[I + d2 + d3]);
	v[1] = load1(&psi[I + d0 + d2 + d3]);

	tmp[0] = fma(v[0], m[192], mt[192], fma(v[1], m[193], mt[193], tmp[0]));
	tmp[1] = fma(v[0], m[194], mt[194], fma(v[1], m[195], mt[195], tmp[1]));
	tmp[2] = fma(v[0], m[196], mt[196], fma(v[1], m[197], mt[197], tmp[2]));
	tmp[3] = fma(v[0], m[198], mt[198], fma(v[1], m[199], mt[199], tmp[3]));
	tmp[4] = fma(v[0], m[200], mt[200], fma(v[1], m[201], mt[201], tmp[4]));
	tmp[5] = fma(v[0], m[202], mt[202], fma(v[1], m[203], mt[203], tmp[5]));
	tmp[6] = fma(v[0], m[204], mt[204], fma(v[1], m[205], mt[205], tmp[6]));
	tmp[7] = fma(v[0], m[206], mt[206], fma(v[1], m[207], mt[207], tmp[7]));
	tmp[8] = fma(v[0], m[208], mt[208], fma(v[1], m[209], mt[209], tmp[8]));
	tmp[9] = fma(v[0], m[210], mt[210], fma(v[1], m[211], mt[211], tmp[9]));
	tmp[10] = fma(v[0], m[212], mt[212], fma(v[1], m[213], mt[213], tmp[10]));
	tmp[11] = fma(v[0], m[214], mt[214], fma(v[1], m[215], mt[215], tmp[11]));
	tmp[12] = fma(v[0], m[216], mt[216], fma(v[1], m[217], mt[217], tmp[12]));
	tmp[13] = fma(v[0], m[218], mt[218], fma(v[1], m[219], mt[219], tmp[13]));
	tmp[14] = fma(v[0], m[220], mt[220], fma(v[1], m[221], mt[221], tmp[14]));
	tmp[15] = fma(v[0], m[222], mt[222], fma(v[1], m[223], mt[223], tmp[15]));

	v[0] = load1(&psi[I + d1 + d2 + d3]);
	v[1] = load1(&psi[I + d0 + d1 + d2 + d3]);

	tmp[0] = fma(v[0], m[224], mt[224], fma(v[1], m[225], mt[225], tmp[0]));
	tmp[1] = fma(v[0], m[226], mt[226], fma(v[1], m[227], mt[227], tmp[1]));
	tmp[2] = fma(v[0], m[228], mt[228], fma(v[1], m[229], mt[229], tmp[2]));
	tmp[3] = fma(v[0], m[230], mt[230], fma(v[1], m[231], mt[231], tmp[3]));
	tmp[4] = fma(v[0], m[232], mt[232], fma(v[1], m[233], mt[233], tmp[4]));
	tmp[5] = fma(v[0], m[234], mt[234], fma(v[1], m[235], mt[235], tmp[5]));
	tmp[6] = fma(v[0], m[236], mt[236], fma(v[1], m[237], mt[237], tmp[6]));
	tmp[7] = fma(v[0], m[238], mt[238], fma(v[1], m[239], mt[239], tmp[7]));
	tmp[8] = fma(v[0], m[240], mt[240], fma(v[1], m[241], mt[241], tmp[8]));
	tmp[9] = fma(v[0], m[242], mt[242], fma(v[1], m[243], mt[243], tmp[9]));
	tmp[10] = fma(v[0], m[244], mt[244], fma(v[1], m[245], mt[245], tmp[10]));
	tmp[11] = fma(v[0], m[246], mt[246], fma(v[1], m[247], mt[247], tmp[11]));
	tmp[12] = fma(v[0], m[248], mt[248], fma(v[1], m[249], mt[249], tmp[12]));
	tmp[13] = fma(v[0], m[250], mt[250], fma(v[1], m[251], mt[251], tmp[13]));
	tmp[14] = fma(v[0], m[252], mt[252], fma(v[1], m[253], mt[253], tmp[14]));
	tmp[15] = fma(v[0], m[254], mt[254], fma(v[1], m[255], mt[255], tmp[15]));

	v[0] = load1(&psi[I + d4]);
	v[1] = load1(&psi[I + d0 + d4]);

	tmp[0] = fma(v[0], m[256], mt[256], fma(v[1], m[257], mt[257], tmp[0]));
	tmp[1] = fma(v[0], m[258], mt[258], fma(v[1], m[259], mt[259], tmp[1]));
	tmp[2] = fma(v[0], m[260], mt[260], fma(v[1], m[261], mt[261], tmp[2]));
	tmp[3] = fma(v[0], m[262], mt[262], fma(v[1], m[263], mt[263], tmp[3]));
	tmp[4] = fma(v[0], m[264], mt[264], fma(v[1], m[265], mt[265], tmp[4]));
	tmp[5] = fma(v[0], m[266], mt[266], fma(v[1], m[267], mt[267], tmp[5]));
	tmp[6] = fma(v[0], m[268], mt[268], fma(v[1], m[269], mt[269], tmp[6]));
	tmp[7] = fma(v[0], m[270], mt[270], fma(v[1], m[271], mt[271], tmp[7]));
	tmp[8] = fma(v[0], m[272], mt[272], fma(v[1], m[273], mt[273], tmp[8]));
	tmp[9] = fma(v[0], m[274], mt[274], fma(v[1], m[275], mt[275], tmp[9]));
	tmp[10] = fma(v[0], m[276], mt[276], fma(v[1], m[277], mt[277], tmp[10]));
	tmp[11] = fma(v[0], m[278], mt[278], fma(v[1], m[279], mt[279], tmp[11]));
	tmp[12] = fma(v[0], m[280], mt[280], fma(v[1], m[281], mt[281], tmp[12]));
	tmp[13] = fma(v[0], m[282], mt[282], fma(v[1], m[283], mt[283], tmp[13]));
	tmp[14] = fma(v[0], m[284], mt[284], fma(v[1], m[285], mt[285], tmp[14]));
	tmp[15] = fma(v[0], m[286], mt[286], fma(v[1], m[287], mt[287], tmp[15]));

	v[0] = load1(&psi[I + d1 + d4]);
	v[1] = load1(&psi[I + d0 + d1 + d4]);

	tmp[0] = fma(v[0], m[288], mt[288], fma(v[1], m[289], mt[289], tmp[0]));
	tmp[1] = fma(v[0], m[290], mt[290], fma(v[1], m[291], mt[291], tmp[1]));
	tmp[2] = fma(v[0], m[292], mt[292], fma(v[1], m[293], mt[293], tmp[2]));
	tmp[3] = fma(v[0], m[294], mt[294], fma(v[1], m[295], mt[295], tmp[3]));
	tmp[4] = fma(v[0], m[296], mt[296], fma(v[1], m[297], mt[297], tmp[4]));
	tmp[5] = fma(v[0], m[298], mt[298], fma(v[1], m[299], mt[299], tmp[5]));
	tmp[6] = fma(v[0], m[300], mt[300], fma(v[1], m[301], mt[301], tmp[6]));
	tmp[7] = fma(v[0], m[302], mt[302], fma(v[1], m[303], mt[303], tmp[7]));
	tmp[8] = fma(v[0], m[304], mt[304], fma(v[1], m[305], mt[305], tmp[8]));
	tmp[9] = fma(v[0], m[306], mt[306], fma(v[1], m[307], mt[307], tmp[9]));
	tmp[10] = fma(v[0], m[308], mt[308], fma(v[1], m[309], mt[309], tmp[10]));
	tmp[11] = fma(v[0], m[310], mt[310], fma(v[1], m[311], mt[311], tmp[11]));
	tmp[12] = fma(v[0], m[312], mt[312], fma(v[1], m[313], mt[313], tmp[12]));
	tmp[13] = fma(v[0], m[314], mt[314], fma(v[1], m[315], mt[315], tmp[13]));
	tmp[14] = fma(v[0], m[316], mt[316], fma(v[1], m[317], mt[317], tmp[14]));
	tmp[15] = fma(v[0], m[318], mt[318], fma(v[1], m[319], mt[319], tmp[15]));

	v[0] = load1(&psi[I + d2 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d4]);

	tmp[0] = fma(v[0], m[320], mt[320], fma(v[1], m[321], mt[321], tmp[0]));
	tmp[1] = fma(v[0], m[322], mt[322], fma(v[1], m[323], mt[323], tmp[1]));
	tmp[2] = fma(v[0], m[324], mt[324], fma(v[1], m[325], mt[325], tmp[2]));
	tmp[3] = fma(v[0], m[326], mt[326], fma(v[1], m[327], mt[327], tmp[3]));
	tmp[4] = fma(v[0], m[328], mt[328], fma(v[1], m[329], mt[329], tmp[4]));
	tmp[5] = fma(v[0], m[330], mt[330], fma(v[1], m[331], mt[331], tmp[5]));
	tmp[6] = fma(v[0], m[332], mt[332], fma(v[1], m[333], mt[333], tmp[6]));
	tmp[7] = fma(v[0], m[334], mt[334], fma(v[1], m[335], mt[335], tmp[7]));
	tmp[8] = fma(v[0], m[336], mt[336], fma(v[1], m[337], mt[337], tmp[8]));
	tmp[9] = fma(v[0], m[338], mt[338], fma(v[1], m[339], mt[339], tmp[9]));
	tmp[10] = fma(v[0], m[340], mt[340], fma(v[1], m[341], mt[341], tmp[10]));
	tmp[11] = fma(v[0], m[342], mt[342], fma(v[1], m[343], mt[343], tmp[11]));
	tmp[12] = fma(v[0], m[344], mt[344], fma(v[1], m[345], mt[345], tmp[12]));
	tmp[13] = fma(v[0], m[346], mt[346], fma(v[1], m[347], mt[347], tmp[13]));
	tmp[14] = fma(v[0], m[348], mt[348], fma(v[1], m[349], mt[349], tmp[14]));
	tmp[15] = fma(v[0], m[350], mt[350], fma(v[1], m[351], mt[351], tmp[15]));

	v[0] = load1(&psi[I + d1 + d2 + d4]);
	v[1] = load1(&psi[I + d0 + d1 + d2 + d4]);

	tmp[0] = fma(v[0], m[352], mt[352], fma(v[1], m[353], mt[353], tmp[0]));
	tmp[1] = fma(v[0], m[354], mt[354], fma(v[1], m[355], mt[355], tmp[1]));
	tmp[2] = fma(v[0], m[356], mt[356], fma(v[1], m[357], mt[357], tmp[2]));
	tmp[3] = fma(v[0], m[358], mt[358], fma(v[1], m[359], mt[359], tmp[3]));
	tmp[4] = fma(v[0], m[360], mt[360], fma(v[1], m[361], mt[361], tmp[4]));
	tmp[5] = fma(v[0], m[362], mt[362], fma(v[1], m[363], mt[363], tmp[5]));
	tmp[6] = fma(v[0], m[364], mt[364], fma(v[1], m[365], mt[365], tmp[6]));
	tmp[7] = fma(v[0], m[366], mt[366], fma(v[1], m[367], mt[367], tmp[7]));
	tmp[8] = fma(v[0], m[368], mt[368], fma(v[1], m[369], mt[369], tmp[8]));
	tmp[9] = fma(v[0], m[370], mt[370], fma(v[1], m[371], mt[371], tmp[9]));
	tmp[10] = fma(v[0], m[372], mt[372], fma(v[1], m[373], mt[373], tmp[10]));
	tmp[11] = fma(v[0], m[374], mt[374], fma(v[1], m[375], mt[375], tmp[11]));
	tmp[12] = fma(v[0], m[376], mt[376], fma(v[1], m[377], mt[377], tmp[12]));
	tmp[13] = fma(v[0], m[378], mt[378], fma(v[1], m[379], mt[379], tmp[13]));
	tmp[14] = fma(v[0], m[380], mt[380], fma(v[1], m[381], mt[381], tmp[14]));
	tmp[15] = fma(v[0], m[382], mt[382], fma(v[1], m[383], mt[383], tmp[15]));

	v[0] = load1(&psi[I + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d3 + d4]);

	tmp[0] = fma(v[0], m[384], mt[384], fma(v[1], m[385], mt[385], tmp[0]));
	tmp[1] = fma(v[0], m[386], mt[386], fma(v[1], m[387], mt[387], tmp[1]));
	tmp[2] = fma(v[0], m[388], mt[388], fma(v[1], m[389], mt[389], tmp[2]));
	tmp[3] = fma(v[0], m[390], mt[390], fma(v[1], m[391], mt[391], tmp[3]));
	tmp[4] = fma(v[0], m[392], mt[392], fma(v[1], m[393], mt[393], tmp[4]));
	tmp[5] = fma(v[0], m[394], mt[394], fma(v[1], m[395], mt[395], tmp[5]));
	tmp[6] = fma(v[0], m[396], mt[396], fma(v[1], m[397], mt[397], tmp[6]));
	tmp[7] = fma(v[0], m[398], mt[398], fma(v[1], m[399], mt[399], tmp[7]));
	tmp[8] = fma(v[0], m[400], mt[400], fma(v[1], m[401], mt[401], tmp[8]));
	tmp[9] = fma(v[0], m[402], mt[402], fma(v[1], m[403], mt[403], tmp[9]));
	tmp[10] = fma(v[0], m[404], mt[404], fma(v[1], m[405], mt[405], tmp[10]));
	tmp[11] = fma(v[0], m[406], mt[406], fma(v[1], m[407], mt[407], tmp[11]));
	tmp[12] = fma(v[0], m[408], mt[408], fma(v[1], m[409], mt[409], tmp[12]));
	tmp[13] = fma(v[0], m[410], mt[410], fma(v[1], m[411], mt[411], tmp[13]));
	tmp[14] = fma(v[0], m[412], mt[412], fma(v[1], m[413], mt[413], tmp[14]));
	tmp[15] = fma(v[0], m[414], mt[414], fma(v[1], m[415], mt[415], tmp[15]));

	v[0] = load1(&psi[I + d1 + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d1 + d3 + d4]);

	tmp[0] = fma(v[0], m[416], mt[416], fma(v[1], m[417], mt[417], tmp[0]));
	tmp[1] = fma(v[0], m[418], mt[418], fma(v[1], m[419], mt[419], tmp[1]));
	tmp[2] = fma(v[0], m[420], mt[420], fma(v[1], m[421], mt[421], tmp[2]));
	tmp[3] = fma(v[0], m[422], mt[422], fma(v[1], m[423], mt[423], tmp[3]));
	tmp[4] = fma(v[0], m[424], mt[424], fma(v[1], m[425], mt[425], tmp[4]));
	tmp[5] = fma(v[0], m[426], mt[426], fma(v[1], m[427], mt[427], tmp[5]));
	tmp[6] = fma(v[0], m[428], mt[428], fma(v[1], m[429], mt[429], tmp[6]));
	tmp[7] = fma(v[0], m[430], mt[430], fma(v[1], m[431], mt[431], tmp[7]));
	tmp[8] = fma(v[0], m[432], mt[432], fma(v[1], m[433], mt[433], tmp[8]));
	tmp[9] = fma(v[0], m[434], mt[434], fma(v[1], m[435], mt[435], tmp[9]));
	tmp[10] = fma(v[0], m[436], mt[436], fma(v[1], m[437], mt[437], tmp[10]));
	tmp[11] = fma(v[0], m[438], mt[438], fma(v[1], m[439], mt[439], tmp[11]));
	tmp[12] = fma(v[0], m[440], mt[440], fma(v[1], m[441], mt[441], tmp[12]));
	tmp[13] = fma(v[0], m[442], mt[442], fma(v[1], m[443], mt[443], tmp[13]));
	tmp[14] = fma(v[0], m[444], mt[444], fma(v[1], m[445], mt[445], tmp[14]));
	tmp[15] = fma(v[0], m[446], mt[446], fma(v[1], m[447], mt[447], tmp[15]));

	v[0] = load1(&psi[I + d2 + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d2 + d3 + d4]);

	tmp[0] = fma(v[0], m[448], mt[448], fma(v[1], m[449], mt[449], tmp[0]));
	tmp[1] = fma(v[0], m[450], mt[450], fma(v[1], m[451], mt[451], tmp[1]));
	tmp[2] = fma(v[0], m[452], mt[452], fma(v[1], m[453], mt[453], tmp[2]));
	tmp[3] = fma(v[0], m[454], mt[454], fma(v[1], m[455], mt[455], tmp[3]));
	tmp[4] = fma(v[0], m[456], mt[456], fma(v[1], m[457], mt[457], tmp[4]));
	tmp[5] = fma(v[0], m[458], mt[458], fma(v[1], m[459], mt[459], tmp[5]));
	tmp[6] = fma(v[0], m[460], mt[460], fma(v[1], m[461], mt[461], tmp[6]));
	tmp[7] = fma(v[0], m[462], mt[462], fma(v[1], m[463], mt[463], tmp[7]));
	tmp[8] = fma(v[0], m[464], mt[464], fma(v[1], m[465], mt[465], tmp[8]));
	tmp[9] = fma(v[0], m[466], mt[466], fma(v[1], m[467], mt[467], tmp[9]));
	tmp[10] = fma(v[0], m[468], mt[468], fma(v[1], m[469], mt[469], tmp[10]));
	tmp[11] = fma(v[0], m[470], mt[470], fma(v[1], m[471], mt[471], tmp[11]));
	tmp[12] = fma(v[0], m[472], mt[472], fma(v[1], m[473], mt[473], tmp[12]));
	tmp[13] = fma(v[0], m[474], mt[474], fma(v[1], m[475], mt[475], tmp[13]));
	tmp[14] = fma(v[0], m[476], mt[476], fma(v[1], m[477], mt[477], tmp[14]));
	tmp[15] = fma(v[0], m[478], mt[478], fma(v[1], m[479], mt[479], tmp[15]));

	v[0] = load1(&psi[I + d1 + d2 + d3 + d4]);
	v[1] = load1(&psi[I + d0 + d1 + d2 + d3 + d4]);

	tmp[0] = fma(v[0], m[480], mt[480], fma(v[1], m[481], mt[481], tmp[0]));
	tmp[1] = fma(v[0], m[482], mt[482], fma(v[1], m[483], mt[483], tmp[1]));
	tmp[2] = fma(v[0], m[484], mt[484], fma(v[1], m[485], mt[485], tmp[2]));
	tmp[3] = fma(v[0], m[486], mt[486], fma(v[1], m[487], mt[487], tmp[3]));
	store((double*)&psi[I + d0], (double*)&psi[I], tmp[0]);
	store((double*)&psi[I + d0 + d1], (double*)&psi[I + d1], tmp[1]);
	store((double*)&psi[I + d0 + d2], (double*)&psi[I + d2], tmp[2]);
	store((double*)&psi[I + d0 + d1 + d2], (double*)&psi[I + d1 + d2], tmp[3]);
	tmp[4] = fma(v[0], m[488], mt[488], fma(v[1], m[489], mt[489], tmp[4]));
	tmp[5] = fma(v[0], m[490], mt[490], fma(v[1], m[491], mt[491], tmp[5]));
	tmp[6] = fma(v[0], m[492], mt[492], fma(v[1], m[493], mt[493], tmp[6]));
	tmp[7] = fma(v[0], m[494], mt[494], fma(v[1], m[495], mt[495], tmp[7]));
	store((double*)&psi[I + d0 + d3], (double*)&psi[I + d3], tmp[4]);
	store((double*)&psi[I + d0 + d1 + d3], (double*)&psi[I + d1 + d3], tmp[5]);
	store((double*)&psi[I + d0 + d2 + d3], (double*)&psi[I + d2 + d3], tmp[6]);
	store((double*)&psi[I + d0 + d1 + d2 + d3], (double*)&psi[I + d1 + d2 + d3], tmp[7]);
	tmp[8] = fma(v[0], m[496], mt[496], fma(v[1], m[497], mt[497], tmp[8]));
	tmp[9] = fma(v[0], m[498], mt[498], fma(v[1], m[499], mt[499], tmp[9]));
	tmp[10] = fma(v[0], m[500], mt[500], fma(v[1], m[501], mt[501], tmp[10]));
	tmp[11] = fma(v[0], m[502], mt[502], fma(v[1], m[503], mt[503], tmp[11]));
	store((double*)&psi[I + d0 + d4], (double*)&psi[I + d4], tmp[8]);
	store((double*)&psi[I + d0 + d1 + d4], (double*)&psi[I + d1 + d4], tmp[9]);
	store((double*)&psi[I + d0 + d2 + d4], (double*)&psi[I + d2 + d4], tmp[10]);
	store((double*)&psi[I + d0 + d1 + d2 + d4], (double*)&psi[I + d1 + d2 + d4], tmp[11]);
	tmp[12] = fma(v[0], m[504], mt[504], fma(v[1], m[505], mt[505], tmp[12]));
	tmp[13] = fma(v[0], m[506], mt[506], fma(v[1], m[507], mt[507], tmp[13]));
	tmp[14] = fma(v[0], m[508], mt[508], fma(v[1], m[509], mt[509], tmp[14]));
	tmp[15] = fma(v[0], m[510], mt[510], fma(v[1], m[511], mt[511], tmp[15]));
	store((double*)&psi[I + d0 + d3 + d4], (double*)&psi[I + d3 + d4], tmp[12]);
	store((double*)&psi[I + d0 + d1 + d3 + d4], (double*)&psi[I + d1 + d3 + d4], tmp[13]);
	store((double*)&psi[I + d0 + d2 + d3 + d4], (double*)&psi[I + d2 + d3 + d4], tmp[14]);
	store((double*)&psi[I + d0 + d1 + d2 + d3 + d4], (double*)&psi[I + d1 + d2 + d3 + d4], tmp[15]);

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

	__m256d mm[512];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 16; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mm[b*32+r*2+c] = loada(&m[2*r+0][c+b*2], &m[2*r+1][c+b*2]);
			}
		}
	}

	__m256d mmt[512];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 16; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mmt[b*32+r*2+c] = loadbm(&m[2*r+0][c+b*2], &m[2*r+1][c+b*2]);
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

