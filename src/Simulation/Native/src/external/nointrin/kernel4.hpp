// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, M const& m)
{
	std::complex<double> v[1];

	v[0] = psi[I];

	std::complex<double> tmp[16] = {0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.};

	tmp[0] = fma(v[0], m[0], tmp[0]);
	tmp[1] = fma(v[0], m[1], tmp[1]);
	tmp[2] = fma(v[0], m[2], tmp[2]);
	tmp[3] = fma(v[0], m[3], tmp[3]);
	tmp[4] = fma(v[0], m[4], tmp[4]);
	tmp[5] = fma(v[0], m[5], tmp[5]);
	tmp[6] = fma(v[0], m[6], tmp[6]);
	tmp[7] = fma(v[0], m[7], tmp[7]);
	tmp[8] = fma(v[0], m[8], tmp[8]);
	tmp[9] = fma(v[0], m[9], tmp[9]);
	tmp[10] = fma(v[0], m[10], tmp[10]);
	tmp[11] = fma(v[0], m[11], tmp[11]);
	tmp[12] = fma(v[0], m[12], tmp[12]);
	tmp[13] = fma(v[0], m[13], tmp[13]);
	tmp[14] = fma(v[0], m[14], tmp[14]);
	tmp[15] = fma(v[0], m[15], tmp[15]);

	v[0] = psi[I + d0];

	tmp[0] = fma(v[0], m[16], tmp[0]);
	tmp[1] = fma(v[0], m[17], tmp[1]);
	tmp[2] = fma(v[0], m[18], tmp[2]);
	tmp[3] = fma(v[0], m[19], tmp[3]);
	tmp[4] = fma(v[0], m[20], tmp[4]);
	tmp[5] = fma(v[0], m[21], tmp[5]);
	tmp[6] = fma(v[0], m[22], tmp[6]);
	tmp[7] = fma(v[0], m[23], tmp[7]);
	tmp[8] = fma(v[0], m[24], tmp[8]);
	tmp[9] = fma(v[0], m[25], tmp[9]);
	tmp[10] = fma(v[0], m[26], tmp[10]);
	tmp[11] = fma(v[0], m[27], tmp[11]);
	tmp[12] = fma(v[0], m[28], tmp[12]);
	tmp[13] = fma(v[0], m[29], tmp[13]);
	tmp[14] = fma(v[0], m[30], tmp[14]);
	tmp[15] = fma(v[0], m[31], tmp[15]);

	v[0] = psi[I + d1];

	tmp[0] = fma(v[0], m[32], tmp[0]);
	tmp[1] = fma(v[0], m[33], tmp[1]);
	tmp[2] = fma(v[0], m[34], tmp[2]);
	tmp[3] = fma(v[0], m[35], tmp[3]);
	tmp[4] = fma(v[0], m[36], tmp[4]);
	tmp[5] = fma(v[0], m[37], tmp[5]);
	tmp[6] = fma(v[0], m[38], tmp[6]);
	tmp[7] = fma(v[0], m[39], tmp[7]);
	tmp[8] = fma(v[0], m[40], tmp[8]);
	tmp[9] = fma(v[0], m[41], tmp[9]);
	tmp[10] = fma(v[0], m[42], tmp[10]);
	tmp[11] = fma(v[0], m[43], tmp[11]);
	tmp[12] = fma(v[0], m[44], tmp[12]);
	tmp[13] = fma(v[0], m[45], tmp[13]);
	tmp[14] = fma(v[0], m[46], tmp[14]);
	tmp[15] = fma(v[0], m[47], tmp[15]);

	v[0] = psi[I + d0 + d1];

	tmp[0] = fma(v[0], m[48], tmp[0]);
	tmp[1] = fma(v[0], m[49], tmp[1]);
	tmp[2] = fma(v[0], m[50], tmp[2]);
	tmp[3] = fma(v[0], m[51], tmp[3]);
	tmp[4] = fma(v[0], m[52], tmp[4]);
	tmp[5] = fma(v[0], m[53], tmp[5]);
	tmp[6] = fma(v[0], m[54], tmp[6]);
	tmp[7] = fma(v[0], m[55], tmp[7]);
	tmp[8] = fma(v[0], m[56], tmp[8]);
	tmp[9] = fma(v[0], m[57], tmp[9]);
	tmp[10] = fma(v[0], m[58], tmp[10]);
	tmp[11] = fma(v[0], m[59], tmp[11]);
	tmp[12] = fma(v[0], m[60], tmp[12]);
	tmp[13] = fma(v[0], m[61], tmp[13]);
	tmp[14] = fma(v[0], m[62], tmp[14]);
	tmp[15] = fma(v[0], m[63], tmp[15]);

	v[0] = psi[I + d2];

	tmp[0] = fma(v[0], m[64], tmp[0]);
	tmp[1] = fma(v[0], m[65], tmp[1]);
	tmp[2] = fma(v[0], m[66], tmp[2]);
	tmp[3] = fma(v[0], m[67], tmp[3]);
	tmp[4] = fma(v[0], m[68], tmp[4]);
	tmp[5] = fma(v[0], m[69], tmp[5]);
	tmp[6] = fma(v[0], m[70], tmp[6]);
	tmp[7] = fma(v[0], m[71], tmp[7]);
	tmp[8] = fma(v[0], m[72], tmp[8]);
	tmp[9] = fma(v[0], m[73], tmp[9]);
	tmp[10] = fma(v[0], m[74], tmp[10]);
	tmp[11] = fma(v[0], m[75], tmp[11]);
	tmp[12] = fma(v[0], m[76], tmp[12]);
	tmp[13] = fma(v[0], m[77], tmp[13]);
	tmp[14] = fma(v[0], m[78], tmp[14]);
	tmp[15] = fma(v[0], m[79], tmp[15]);

	v[0] = psi[I + d0 + d2];

	tmp[0] = fma(v[0], m[80], tmp[0]);
	tmp[1] = fma(v[0], m[81], tmp[1]);
	tmp[2] = fma(v[0], m[82], tmp[2]);
	tmp[3] = fma(v[0], m[83], tmp[3]);
	tmp[4] = fma(v[0], m[84], tmp[4]);
	tmp[5] = fma(v[0], m[85], tmp[5]);
	tmp[6] = fma(v[0], m[86], tmp[6]);
	tmp[7] = fma(v[0], m[87], tmp[7]);
	tmp[8] = fma(v[0], m[88], tmp[8]);
	tmp[9] = fma(v[0], m[89], tmp[9]);
	tmp[10] = fma(v[0], m[90], tmp[10]);
	tmp[11] = fma(v[0], m[91], tmp[11]);
	tmp[12] = fma(v[0], m[92], tmp[12]);
	tmp[13] = fma(v[0], m[93], tmp[13]);
	tmp[14] = fma(v[0], m[94], tmp[14]);
	tmp[15] = fma(v[0], m[95], tmp[15]);

	v[0] = psi[I + d1 + d2];

	tmp[0] = fma(v[0], m[96], tmp[0]);
	tmp[1] = fma(v[0], m[97], tmp[1]);
	tmp[2] = fma(v[0], m[98], tmp[2]);
	tmp[3] = fma(v[0], m[99], tmp[3]);
	tmp[4] = fma(v[0], m[100], tmp[4]);
	tmp[5] = fma(v[0], m[101], tmp[5]);
	tmp[6] = fma(v[0], m[102], tmp[6]);
	tmp[7] = fma(v[0], m[103], tmp[7]);
	tmp[8] = fma(v[0], m[104], tmp[8]);
	tmp[9] = fma(v[0], m[105], tmp[9]);
	tmp[10] = fma(v[0], m[106], tmp[10]);
	tmp[11] = fma(v[0], m[107], tmp[11]);
	tmp[12] = fma(v[0], m[108], tmp[12]);
	tmp[13] = fma(v[0], m[109], tmp[13]);
	tmp[14] = fma(v[0], m[110], tmp[14]);
	tmp[15] = fma(v[0], m[111], tmp[15]);

	v[0] = psi[I + d0 + d1 + d2];

	tmp[0] = fma(v[0], m[112], tmp[0]);
	tmp[1] = fma(v[0], m[113], tmp[1]);
	tmp[2] = fma(v[0], m[114], tmp[2]);
	tmp[3] = fma(v[0], m[115], tmp[3]);
	tmp[4] = fma(v[0], m[116], tmp[4]);
	tmp[5] = fma(v[0], m[117], tmp[5]);
	tmp[6] = fma(v[0], m[118], tmp[6]);
	tmp[7] = fma(v[0], m[119], tmp[7]);
	tmp[8] = fma(v[0], m[120], tmp[8]);
	tmp[9] = fma(v[0], m[121], tmp[9]);
	tmp[10] = fma(v[0], m[122], tmp[10]);
	tmp[11] = fma(v[0], m[123], tmp[11]);
	tmp[12] = fma(v[0], m[124], tmp[12]);
	tmp[13] = fma(v[0], m[125], tmp[13]);
	tmp[14] = fma(v[0], m[126], tmp[14]);
	tmp[15] = fma(v[0], m[127], tmp[15]);

	v[0] = psi[I + d3];

	tmp[0] = fma(v[0], m[128], tmp[0]);
	tmp[1] = fma(v[0], m[129], tmp[1]);
	tmp[2] = fma(v[0], m[130], tmp[2]);
	tmp[3] = fma(v[0], m[131], tmp[3]);
	tmp[4] = fma(v[0], m[132], tmp[4]);
	tmp[5] = fma(v[0], m[133], tmp[5]);
	tmp[6] = fma(v[0], m[134], tmp[6]);
	tmp[7] = fma(v[0], m[135], tmp[7]);
	tmp[8] = fma(v[0], m[136], tmp[8]);
	tmp[9] = fma(v[0], m[137], tmp[9]);
	tmp[10] = fma(v[0], m[138], tmp[10]);
	tmp[11] = fma(v[0], m[139], tmp[11]);
	tmp[12] = fma(v[0], m[140], tmp[12]);
	tmp[13] = fma(v[0], m[141], tmp[13]);
	tmp[14] = fma(v[0], m[142], tmp[14]);
	tmp[15] = fma(v[0], m[143], tmp[15]);

	v[0] = psi[I + d0 + d3];

	tmp[0] = fma(v[0], m[144], tmp[0]);
	tmp[1] = fma(v[0], m[145], tmp[1]);
	tmp[2] = fma(v[0], m[146], tmp[2]);
	tmp[3] = fma(v[0], m[147], tmp[3]);
	tmp[4] = fma(v[0], m[148], tmp[4]);
	tmp[5] = fma(v[0], m[149], tmp[5]);
	tmp[6] = fma(v[0], m[150], tmp[6]);
	tmp[7] = fma(v[0], m[151], tmp[7]);
	tmp[8] = fma(v[0], m[152], tmp[8]);
	tmp[9] = fma(v[0], m[153], tmp[9]);
	tmp[10] = fma(v[0], m[154], tmp[10]);
	tmp[11] = fma(v[0], m[155], tmp[11]);
	tmp[12] = fma(v[0], m[156], tmp[12]);
	tmp[13] = fma(v[0], m[157], tmp[13]);
	tmp[14] = fma(v[0], m[158], tmp[14]);
	tmp[15] = fma(v[0], m[159], tmp[15]);

	v[0] = psi[I + d1 + d3];

	tmp[0] = fma(v[0], m[160], tmp[0]);
	tmp[1] = fma(v[0], m[161], tmp[1]);
	tmp[2] = fma(v[0], m[162], tmp[2]);
	tmp[3] = fma(v[0], m[163], tmp[3]);
	tmp[4] = fma(v[0], m[164], tmp[4]);
	tmp[5] = fma(v[0], m[165], tmp[5]);
	tmp[6] = fma(v[0], m[166], tmp[6]);
	tmp[7] = fma(v[0], m[167], tmp[7]);
	tmp[8] = fma(v[0], m[168], tmp[8]);
	tmp[9] = fma(v[0], m[169], tmp[9]);
	tmp[10] = fma(v[0], m[170], tmp[10]);
	tmp[11] = fma(v[0], m[171], tmp[11]);
	tmp[12] = fma(v[0], m[172], tmp[12]);
	tmp[13] = fma(v[0], m[173], tmp[13]);
	tmp[14] = fma(v[0], m[174], tmp[14]);
	tmp[15] = fma(v[0], m[175], tmp[15]);

	v[0] = psi[I + d0 + d1 + d3];

	tmp[0] = fma(v[0], m[176], tmp[0]);
	tmp[1] = fma(v[0], m[177], tmp[1]);
	tmp[2] = fma(v[0], m[178], tmp[2]);
	tmp[3] = fma(v[0], m[179], tmp[3]);
	tmp[4] = fma(v[0], m[180], tmp[4]);
	tmp[5] = fma(v[0], m[181], tmp[5]);
	tmp[6] = fma(v[0], m[182], tmp[6]);
	tmp[7] = fma(v[0], m[183], tmp[7]);
	tmp[8] = fma(v[0], m[184], tmp[8]);
	tmp[9] = fma(v[0], m[185], tmp[9]);
	tmp[10] = fma(v[0], m[186], tmp[10]);
	tmp[11] = fma(v[0], m[187], tmp[11]);
	tmp[12] = fma(v[0], m[188], tmp[12]);
	tmp[13] = fma(v[0], m[189], tmp[13]);
	tmp[14] = fma(v[0], m[190], tmp[14]);
	tmp[15] = fma(v[0], m[191], tmp[15]);

	v[0] = psi[I + d2 + d3];

	tmp[0] = fma(v[0], m[192], tmp[0]);
	tmp[1] = fma(v[0], m[193], tmp[1]);
	tmp[2] = fma(v[0], m[194], tmp[2]);
	tmp[3] = fma(v[0], m[195], tmp[3]);
	tmp[4] = fma(v[0], m[196], tmp[4]);
	tmp[5] = fma(v[0], m[197], tmp[5]);
	tmp[6] = fma(v[0], m[198], tmp[6]);
	tmp[7] = fma(v[0], m[199], tmp[7]);
	tmp[8] = fma(v[0], m[200], tmp[8]);
	tmp[9] = fma(v[0], m[201], tmp[9]);
	tmp[10] = fma(v[0], m[202], tmp[10]);
	tmp[11] = fma(v[0], m[203], tmp[11]);
	tmp[12] = fma(v[0], m[204], tmp[12]);
	tmp[13] = fma(v[0], m[205], tmp[13]);
	tmp[14] = fma(v[0], m[206], tmp[14]);
	tmp[15] = fma(v[0], m[207], tmp[15]);

	v[0] = psi[I + d0 + d2 + d3];

	tmp[0] = fma(v[0], m[208], tmp[0]);
	tmp[1] = fma(v[0], m[209], tmp[1]);
	tmp[2] = fma(v[0], m[210], tmp[2]);
	tmp[3] = fma(v[0], m[211], tmp[3]);
	tmp[4] = fma(v[0], m[212], tmp[4]);
	tmp[5] = fma(v[0], m[213], tmp[5]);
	tmp[6] = fma(v[0], m[214], tmp[6]);
	tmp[7] = fma(v[0], m[215], tmp[7]);
	tmp[8] = fma(v[0], m[216], tmp[8]);
	tmp[9] = fma(v[0], m[217], tmp[9]);
	tmp[10] = fma(v[0], m[218], tmp[10]);
	tmp[11] = fma(v[0], m[219], tmp[11]);
	tmp[12] = fma(v[0], m[220], tmp[12]);
	tmp[13] = fma(v[0], m[221], tmp[13]);
	tmp[14] = fma(v[0], m[222], tmp[14]);
	tmp[15] = fma(v[0], m[223], tmp[15]);

	v[0] = psi[I + d1 + d2 + d3];

	tmp[0] = fma(v[0], m[224], tmp[0]);
	tmp[1] = fma(v[0], m[225], tmp[1]);
	tmp[2] = fma(v[0], m[226], tmp[2]);
	tmp[3] = fma(v[0], m[227], tmp[3]);
	tmp[4] = fma(v[0], m[228], tmp[4]);
	tmp[5] = fma(v[0], m[229], tmp[5]);
	tmp[6] = fma(v[0], m[230], tmp[6]);
	tmp[7] = fma(v[0], m[231], tmp[7]);
	tmp[8] = fma(v[0], m[232], tmp[8]);
	tmp[9] = fma(v[0], m[233], tmp[9]);
	tmp[10] = fma(v[0], m[234], tmp[10]);
	tmp[11] = fma(v[0], m[235], tmp[11]);
	tmp[12] = fma(v[0], m[236], tmp[12]);
	tmp[13] = fma(v[0], m[237], tmp[13]);
	tmp[14] = fma(v[0], m[238], tmp[14]);
	tmp[15] = fma(v[0], m[239], tmp[15]);

	v[0] = psi[I + d0 + d1 + d2 + d3];

	tmp[0] = fma(v[0], m[240], tmp[0]);
	tmp[1] = fma(v[0], m[241], tmp[1]);
	tmp[2] = fma(v[0], m[242], tmp[2]);
	tmp[3] = fma(v[0], m[243], tmp[3]);
	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];
	psi[I + d1] = tmp[2];
	psi[I + d0 + d1] = tmp[3];
	tmp[4] = fma(v[0], m[244], tmp[4]);
	tmp[5] = fma(v[0], m[245], tmp[5]);
	tmp[6] = fma(v[0], m[246], tmp[6]);
	tmp[7] = fma(v[0], m[247], tmp[7]);
	psi[I + d2] = tmp[4];
	psi[I + d0 + d2] = tmp[5];
	psi[I + d1 + d2] = tmp[6];
	psi[I + d0 + d1 + d2] = tmp[7];
	tmp[8] = fma(v[0], m[248], tmp[8]);
	tmp[9] = fma(v[0], m[249], tmp[9]);
	tmp[10] = fma(v[0], m[250], tmp[10]);
	tmp[11] = fma(v[0], m[251], tmp[11]);
	psi[I + d3] = tmp[8];
	psi[I + d0 + d3] = tmp[9];
	psi[I + d1 + d3] = tmp[10];
	psi[I + d0 + d1 + d3] = tmp[11];
	tmp[12] = fma(v[0], m[252], tmp[12]);
	tmp[13] = fma(v[0], m[253], tmp[13]);
	tmp[14] = fma(v[0], m[254], tmp[14]);
	tmp[15] = fma(v[0], m[255], tmp[15]);
	psi[I + d2 + d3] = tmp[12];
	psi[I + d0 + d2 + d3] = tmp[13];
	psi[I + d1 + d2 + d3] = tmp[14];
	psi[I + d0 + d1 + d2 + d3] = tmp[15];

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

	std::complex<double> mm[256];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 16; ++r){
			for (unsigned c = 0; c < 1; ++c){
				mm[b*16+r*1+c] = m[r][c+b*1];
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
							kernel_core(psi, i0 + i1 + i2 + i3 + i4, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
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
								kernel_core(psi, i0 + i1 + i2 + i3 + i4, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
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
				kernel_core(psi, i, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	}
#endif
}

