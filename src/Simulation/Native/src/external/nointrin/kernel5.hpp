// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
inline void kernel_core(V& psi, std::size_t I, std::size_t d0, std::size_t d1, std::size_t d2, std::size_t d3, std::size_t d4, M const& m)
{
	std::complex<double> v[2];

	v[0] = psi[I];
	v[1] = psi[I + d0];

	std::complex<double> tmp[32] = {0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.};

	tmp[0] = fma(v[0], m[0], fma(v[1], m[1], tmp[0]));
	tmp[1] = fma(v[0], m[2], fma(v[1], m[3], tmp[1]));
	tmp[2] = fma(v[0], m[4], fma(v[1], m[5], tmp[2]));
	tmp[3] = fma(v[0], m[6], fma(v[1], m[7], tmp[3]));
	tmp[4] = fma(v[0], m[8], fma(v[1], m[9], tmp[4]));
	tmp[5] = fma(v[0], m[10], fma(v[1], m[11], tmp[5]));
	tmp[6] = fma(v[0], m[12], fma(v[1], m[13], tmp[6]));
	tmp[7] = fma(v[0], m[14], fma(v[1], m[15], tmp[7]));
	tmp[8] = fma(v[0], m[16], fma(v[1], m[17], tmp[8]));
	tmp[9] = fma(v[0], m[18], fma(v[1], m[19], tmp[9]));
	tmp[10] = fma(v[0], m[20], fma(v[1], m[21], tmp[10]));
	tmp[11] = fma(v[0], m[22], fma(v[1], m[23], tmp[11]));
	tmp[12] = fma(v[0], m[24], fma(v[1], m[25], tmp[12]));
	tmp[13] = fma(v[0], m[26], fma(v[1], m[27], tmp[13]));
	tmp[14] = fma(v[0], m[28], fma(v[1], m[29], tmp[14]));
	tmp[15] = fma(v[0], m[30], fma(v[1], m[31], tmp[15]));
	tmp[16] = fma(v[0], m[32], fma(v[1], m[33], tmp[16]));
	tmp[17] = fma(v[0], m[34], fma(v[1], m[35], tmp[17]));
	tmp[18] = fma(v[0], m[36], fma(v[1], m[37], tmp[18]));
	tmp[19] = fma(v[0], m[38], fma(v[1], m[39], tmp[19]));
	tmp[20] = fma(v[0], m[40], fma(v[1], m[41], tmp[20]));
	tmp[21] = fma(v[0], m[42], fma(v[1], m[43], tmp[21]));
	tmp[22] = fma(v[0], m[44], fma(v[1], m[45], tmp[22]));
	tmp[23] = fma(v[0], m[46], fma(v[1], m[47], tmp[23]));
	tmp[24] = fma(v[0], m[48], fma(v[1], m[49], tmp[24]));
	tmp[25] = fma(v[0], m[50], fma(v[1], m[51], tmp[25]));
	tmp[26] = fma(v[0], m[52], fma(v[1], m[53], tmp[26]));
	tmp[27] = fma(v[0], m[54], fma(v[1], m[55], tmp[27]));
	tmp[28] = fma(v[0], m[56], fma(v[1], m[57], tmp[28]));
	tmp[29] = fma(v[0], m[58], fma(v[1], m[59], tmp[29]));
	tmp[30] = fma(v[0], m[60], fma(v[1], m[61], tmp[30]));
	tmp[31] = fma(v[0], m[62], fma(v[1], m[63], tmp[31]));

	v[0] = psi[I + d1];
	v[1] = psi[I + d0 + d1];

	tmp[0] = fma(v[0], m[64], fma(v[1], m[65], tmp[0]));
	tmp[1] = fma(v[0], m[66], fma(v[1], m[67], tmp[1]));
	tmp[2] = fma(v[0], m[68], fma(v[1], m[69], tmp[2]));
	tmp[3] = fma(v[0], m[70], fma(v[1], m[71], tmp[3]));
	tmp[4] = fma(v[0], m[72], fma(v[1], m[73], tmp[4]));
	tmp[5] = fma(v[0], m[74], fma(v[1], m[75], tmp[5]));
	tmp[6] = fma(v[0], m[76], fma(v[1], m[77], tmp[6]));
	tmp[7] = fma(v[0], m[78], fma(v[1], m[79], tmp[7]));
	tmp[8] = fma(v[0], m[80], fma(v[1], m[81], tmp[8]));
	tmp[9] = fma(v[0], m[82], fma(v[1], m[83], tmp[9]));
	tmp[10] = fma(v[0], m[84], fma(v[1], m[85], tmp[10]));
	tmp[11] = fma(v[0], m[86], fma(v[1], m[87], tmp[11]));
	tmp[12] = fma(v[0], m[88], fma(v[1], m[89], tmp[12]));
	tmp[13] = fma(v[0], m[90], fma(v[1], m[91], tmp[13]));
	tmp[14] = fma(v[0], m[92], fma(v[1], m[93], tmp[14]));
	tmp[15] = fma(v[0], m[94], fma(v[1], m[95], tmp[15]));
	tmp[16] = fma(v[0], m[96], fma(v[1], m[97], tmp[16]));
	tmp[17] = fma(v[0], m[98], fma(v[1], m[99], tmp[17]));
	tmp[18] = fma(v[0], m[100], fma(v[1], m[101], tmp[18]));
	tmp[19] = fma(v[0], m[102], fma(v[1], m[103], tmp[19]));
	tmp[20] = fma(v[0], m[104], fma(v[1], m[105], tmp[20]));
	tmp[21] = fma(v[0], m[106], fma(v[1], m[107], tmp[21]));
	tmp[22] = fma(v[0], m[108], fma(v[1], m[109], tmp[22]));
	tmp[23] = fma(v[0], m[110], fma(v[1], m[111], tmp[23]));
	tmp[24] = fma(v[0], m[112], fma(v[1], m[113], tmp[24]));
	tmp[25] = fma(v[0], m[114], fma(v[1], m[115], tmp[25]));
	tmp[26] = fma(v[0], m[116], fma(v[1], m[117], tmp[26]));
	tmp[27] = fma(v[0], m[118], fma(v[1], m[119], tmp[27]));
	tmp[28] = fma(v[0], m[120], fma(v[1], m[121], tmp[28]));
	tmp[29] = fma(v[0], m[122], fma(v[1], m[123], tmp[29]));
	tmp[30] = fma(v[0], m[124], fma(v[1], m[125], tmp[30]));
	tmp[31] = fma(v[0], m[126], fma(v[1], m[127], tmp[31]));

	v[0] = psi[I + d2];
	v[1] = psi[I + d0 + d2];

	tmp[0] = fma(v[0], m[128], fma(v[1], m[129], tmp[0]));
	tmp[1] = fma(v[0], m[130], fma(v[1], m[131], tmp[1]));
	tmp[2] = fma(v[0], m[132], fma(v[1], m[133], tmp[2]));
	tmp[3] = fma(v[0], m[134], fma(v[1], m[135], tmp[3]));
	tmp[4] = fma(v[0], m[136], fma(v[1], m[137], tmp[4]));
	tmp[5] = fma(v[0], m[138], fma(v[1], m[139], tmp[5]));
	tmp[6] = fma(v[0], m[140], fma(v[1], m[141], tmp[6]));
	tmp[7] = fma(v[0], m[142], fma(v[1], m[143], tmp[7]));
	tmp[8] = fma(v[0], m[144], fma(v[1], m[145], tmp[8]));
	tmp[9] = fma(v[0], m[146], fma(v[1], m[147], tmp[9]));
	tmp[10] = fma(v[0], m[148], fma(v[1], m[149], tmp[10]));
	tmp[11] = fma(v[0], m[150], fma(v[1], m[151], tmp[11]));
	tmp[12] = fma(v[0], m[152], fma(v[1], m[153], tmp[12]));
	tmp[13] = fma(v[0], m[154], fma(v[1], m[155], tmp[13]));
	tmp[14] = fma(v[0], m[156], fma(v[1], m[157], tmp[14]));
	tmp[15] = fma(v[0], m[158], fma(v[1], m[159], tmp[15]));
	tmp[16] = fma(v[0], m[160], fma(v[1], m[161], tmp[16]));
	tmp[17] = fma(v[0], m[162], fma(v[1], m[163], tmp[17]));
	tmp[18] = fma(v[0], m[164], fma(v[1], m[165], tmp[18]));
	tmp[19] = fma(v[0], m[166], fma(v[1], m[167], tmp[19]));
	tmp[20] = fma(v[0], m[168], fma(v[1], m[169], tmp[20]));
	tmp[21] = fma(v[0], m[170], fma(v[1], m[171], tmp[21]));
	tmp[22] = fma(v[0], m[172], fma(v[1], m[173], tmp[22]));
	tmp[23] = fma(v[0], m[174], fma(v[1], m[175], tmp[23]));
	tmp[24] = fma(v[0], m[176], fma(v[1], m[177], tmp[24]));
	tmp[25] = fma(v[0], m[178], fma(v[1], m[179], tmp[25]));
	tmp[26] = fma(v[0], m[180], fma(v[1], m[181], tmp[26]));
	tmp[27] = fma(v[0], m[182], fma(v[1], m[183], tmp[27]));
	tmp[28] = fma(v[0], m[184], fma(v[1], m[185], tmp[28]));
	tmp[29] = fma(v[0], m[186], fma(v[1], m[187], tmp[29]));
	tmp[30] = fma(v[0], m[188], fma(v[1], m[189], tmp[30]));
	tmp[31] = fma(v[0], m[190], fma(v[1], m[191], tmp[31]));

	v[0] = psi[I + d1 + d2];
	v[1] = psi[I + d0 + d1 + d2];

	tmp[0] = fma(v[0], m[192], fma(v[1], m[193], tmp[0]));
	tmp[1] = fma(v[0], m[194], fma(v[1], m[195], tmp[1]));
	tmp[2] = fma(v[0], m[196], fma(v[1], m[197], tmp[2]));
	tmp[3] = fma(v[0], m[198], fma(v[1], m[199], tmp[3]));
	tmp[4] = fma(v[0], m[200], fma(v[1], m[201], tmp[4]));
	tmp[5] = fma(v[0], m[202], fma(v[1], m[203], tmp[5]));
	tmp[6] = fma(v[0], m[204], fma(v[1], m[205], tmp[6]));
	tmp[7] = fma(v[0], m[206], fma(v[1], m[207], tmp[7]));
	tmp[8] = fma(v[0], m[208], fma(v[1], m[209], tmp[8]));
	tmp[9] = fma(v[0], m[210], fma(v[1], m[211], tmp[9]));
	tmp[10] = fma(v[0], m[212], fma(v[1], m[213], tmp[10]));
	tmp[11] = fma(v[0], m[214], fma(v[1], m[215], tmp[11]));
	tmp[12] = fma(v[0], m[216], fma(v[1], m[217], tmp[12]));
	tmp[13] = fma(v[0], m[218], fma(v[1], m[219], tmp[13]));
	tmp[14] = fma(v[0], m[220], fma(v[1], m[221], tmp[14]));
	tmp[15] = fma(v[0], m[222], fma(v[1], m[223], tmp[15]));
	tmp[16] = fma(v[0], m[224], fma(v[1], m[225], tmp[16]));
	tmp[17] = fma(v[0], m[226], fma(v[1], m[227], tmp[17]));
	tmp[18] = fma(v[0], m[228], fma(v[1], m[229], tmp[18]));
	tmp[19] = fma(v[0], m[230], fma(v[1], m[231], tmp[19]));
	tmp[20] = fma(v[0], m[232], fma(v[1], m[233], tmp[20]));
	tmp[21] = fma(v[0], m[234], fma(v[1], m[235], tmp[21]));
	tmp[22] = fma(v[0], m[236], fma(v[1], m[237], tmp[22]));
	tmp[23] = fma(v[0], m[238], fma(v[1], m[239], tmp[23]));
	tmp[24] = fma(v[0], m[240], fma(v[1], m[241], tmp[24]));
	tmp[25] = fma(v[0], m[242], fma(v[1], m[243], tmp[25]));
	tmp[26] = fma(v[0], m[244], fma(v[1], m[245], tmp[26]));
	tmp[27] = fma(v[0], m[246], fma(v[1], m[247], tmp[27]));
	tmp[28] = fma(v[0], m[248], fma(v[1], m[249], tmp[28]));
	tmp[29] = fma(v[0], m[250], fma(v[1], m[251], tmp[29]));
	tmp[30] = fma(v[0], m[252], fma(v[1], m[253], tmp[30]));
	tmp[31] = fma(v[0], m[254], fma(v[1], m[255], tmp[31]));

	v[0] = psi[I + d3];
	v[1] = psi[I + d0 + d3];

	tmp[0] = fma(v[0], m[256], fma(v[1], m[257], tmp[0]));
	tmp[1] = fma(v[0], m[258], fma(v[1], m[259], tmp[1]));
	tmp[2] = fma(v[0], m[260], fma(v[1], m[261], tmp[2]));
	tmp[3] = fma(v[0], m[262], fma(v[1], m[263], tmp[3]));
	tmp[4] = fma(v[0], m[264], fma(v[1], m[265], tmp[4]));
	tmp[5] = fma(v[0], m[266], fma(v[1], m[267], tmp[5]));
	tmp[6] = fma(v[0], m[268], fma(v[1], m[269], tmp[6]));
	tmp[7] = fma(v[0], m[270], fma(v[1], m[271], tmp[7]));
	tmp[8] = fma(v[0], m[272], fma(v[1], m[273], tmp[8]));
	tmp[9] = fma(v[0], m[274], fma(v[1], m[275], tmp[9]));
	tmp[10] = fma(v[0], m[276], fma(v[1], m[277], tmp[10]));
	tmp[11] = fma(v[0], m[278], fma(v[1], m[279], tmp[11]));
	tmp[12] = fma(v[0], m[280], fma(v[1], m[281], tmp[12]));
	tmp[13] = fma(v[0], m[282], fma(v[1], m[283], tmp[13]));
	tmp[14] = fma(v[0], m[284], fma(v[1], m[285], tmp[14]));
	tmp[15] = fma(v[0], m[286], fma(v[1], m[287], tmp[15]));
	tmp[16] = fma(v[0], m[288], fma(v[1], m[289], tmp[16]));
	tmp[17] = fma(v[0], m[290], fma(v[1], m[291], tmp[17]));
	tmp[18] = fma(v[0], m[292], fma(v[1], m[293], tmp[18]));
	tmp[19] = fma(v[0], m[294], fma(v[1], m[295], tmp[19]));
	tmp[20] = fma(v[0], m[296], fma(v[1], m[297], tmp[20]));
	tmp[21] = fma(v[0], m[298], fma(v[1], m[299], tmp[21]));
	tmp[22] = fma(v[0], m[300], fma(v[1], m[301], tmp[22]));
	tmp[23] = fma(v[0], m[302], fma(v[1], m[303], tmp[23]));
	tmp[24] = fma(v[0], m[304], fma(v[1], m[305], tmp[24]));
	tmp[25] = fma(v[0], m[306], fma(v[1], m[307], tmp[25]));
	tmp[26] = fma(v[0], m[308], fma(v[1], m[309], tmp[26]));
	tmp[27] = fma(v[0], m[310], fma(v[1], m[311], tmp[27]));
	tmp[28] = fma(v[0], m[312], fma(v[1], m[313], tmp[28]));
	tmp[29] = fma(v[0], m[314], fma(v[1], m[315], tmp[29]));
	tmp[30] = fma(v[0], m[316], fma(v[1], m[317], tmp[30]));
	tmp[31] = fma(v[0], m[318], fma(v[1], m[319], tmp[31]));

	v[0] = psi[I + d1 + d3];
	v[1] = psi[I + d0 + d1 + d3];

	tmp[0] = fma(v[0], m[320], fma(v[1], m[321], tmp[0]));
	tmp[1] = fma(v[0], m[322], fma(v[1], m[323], tmp[1]));
	tmp[2] = fma(v[0], m[324], fma(v[1], m[325], tmp[2]));
	tmp[3] = fma(v[0], m[326], fma(v[1], m[327], tmp[3]));
	tmp[4] = fma(v[0], m[328], fma(v[1], m[329], tmp[4]));
	tmp[5] = fma(v[0], m[330], fma(v[1], m[331], tmp[5]));
	tmp[6] = fma(v[0], m[332], fma(v[1], m[333], tmp[6]));
	tmp[7] = fma(v[0], m[334], fma(v[1], m[335], tmp[7]));
	tmp[8] = fma(v[0], m[336], fma(v[1], m[337], tmp[8]));
	tmp[9] = fma(v[0], m[338], fma(v[1], m[339], tmp[9]));
	tmp[10] = fma(v[0], m[340], fma(v[1], m[341], tmp[10]));
	tmp[11] = fma(v[0], m[342], fma(v[1], m[343], tmp[11]));
	tmp[12] = fma(v[0], m[344], fma(v[1], m[345], tmp[12]));
	tmp[13] = fma(v[0], m[346], fma(v[1], m[347], tmp[13]));
	tmp[14] = fma(v[0], m[348], fma(v[1], m[349], tmp[14]));
	tmp[15] = fma(v[0], m[350], fma(v[1], m[351], tmp[15]));
	tmp[16] = fma(v[0], m[352], fma(v[1], m[353], tmp[16]));
	tmp[17] = fma(v[0], m[354], fma(v[1], m[355], tmp[17]));
	tmp[18] = fma(v[0], m[356], fma(v[1], m[357], tmp[18]));
	tmp[19] = fma(v[0], m[358], fma(v[1], m[359], tmp[19]));
	tmp[20] = fma(v[0], m[360], fma(v[1], m[361], tmp[20]));
	tmp[21] = fma(v[0], m[362], fma(v[1], m[363], tmp[21]));
	tmp[22] = fma(v[0], m[364], fma(v[1], m[365], tmp[22]));
	tmp[23] = fma(v[0], m[366], fma(v[1], m[367], tmp[23]));
	tmp[24] = fma(v[0], m[368], fma(v[1], m[369], tmp[24]));
	tmp[25] = fma(v[0], m[370], fma(v[1], m[371], tmp[25]));
	tmp[26] = fma(v[0], m[372], fma(v[1], m[373], tmp[26]));
	tmp[27] = fma(v[0], m[374], fma(v[1], m[375], tmp[27]));
	tmp[28] = fma(v[0], m[376], fma(v[1], m[377], tmp[28]));
	tmp[29] = fma(v[0], m[378], fma(v[1], m[379], tmp[29]));
	tmp[30] = fma(v[0], m[380], fma(v[1], m[381], tmp[30]));
	tmp[31] = fma(v[0], m[382], fma(v[1], m[383], tmp[31]));

	v[0] = psi[I + d2 + d3];
	v[1] = psi[I + d0 + d2 + d3];

	tmp[0] = fma(v[0], m[384], fma(v[1], m[385], tmp[0]));
	tmp[1] = fma(v[0], m[386], fma(v[1], m[387], tmp[1]));
	tmp[2] = fma(v[0], m[388], fma(v[1], m[389], tmp[2]));
	tmp[3] = fma(v[0], m[390], fma(v[1], m[391], tmp[3]));
	tmp[4] = fma(v[0], m[392], fma(v[1], m[393], tmp[4]));
	tmp[5] = fma(v[0], m[394], fma(v[1], m[395], tmp[5]));
	tmp[6] = fma(v[0], m[396], fma(v[1], m[397], tmp[6]));
	tmp[7] = fma(v[0], m[398], fma(v[1], m[399], tmp[7]));
	tmp[8] = fma(v[0], m[400], fma(v[1], m[401], tmp[8]));
	tmp[9] = fma(v[0], m[402], fma(v[1], m[403], tmp[9]));
	tmp[10] = fma(v[0], m[404], fma(v[1], m[405], tmp[10]));
	tmp[11] = fma(v[0], m[406], fma(v[1], m[407], tmp[11]));
	tmp[12] = fma(v[0], m[408], fma(v[1], m[409], tmp[12]));
	tmp[13] = fma(v[0], m[410], fma(v[1], m[411], tmp[13]));
	tmp[14] = fma(v[0], m[412], fma(v[1], m[413], tmp[14]));
	tmp[15] = fma(v[0], m[414], fma(v[1], m[415], tmp[15]));
	tmp[16] = fma(v[0], m[416], fma(v[1], m[417], tmp[16]));
	tmp[17] = fma(v[0], m[418], fma(v[1], m[419], tmp[17]));
	tmp[18] = fma(v[0], m[420], fma(v[1], m[421], tmp[18]));
	tmp[19] = fma(v[0], m[422], fma(v[1], m[423], tmp[19]));
	tmp[20] = fma(v[0], m[424], fma(v[1], m[425], tmp[20]));
	tmp[21] = fma(v[0], m[426], fma(v[1], m[427], tmp[21]));
	tmp[22] = fma(v[0], m[428], fma(v[1], m[429], tmp[22]));
	tmp[23] = fma(v[0], m[430], fma(v[1], m[431], tmp[23]));
	tmp[24] = fma(v[0], m[432], fma(v[1], m[433], tmp[24]));
	tmp[25] = fma(v[0], m[434], fma(v[1], m[435], tmp[25]));
	tmp[26] = fma(v[0], m[436], fma(v[1], m[437], tmp[26]));
	tmp[27] = fma(v[0], m[438], fma(v[1], m[439], tmp[27]));
	tmp[28] = fma(v[0], m[440], fma(v[1], m[441], tmp[28]));
	tmp[29] = fma(v[0], m[442], fma(v[1], m[443], tmp[29]));
	tmp[30] = fma(v[0], m[444], fma(v[1], m[445], tmp[30]));
	tmp[31] = fma(v[0], m[446], fma(v[1], m[447], tmp[31]));

	v[0] = psi[I + d1 + d2 + d3];
	v[1] = psi[I + d0 + d1 + d2 + d3];

	tmp[0] = fma(v[0], m[448], fma(v[1], m[449], tmp[0]));
	tmp[1] = fma(v[0], m[450], fma(v[1], m[451], tmp[1]));
	tmp[2] = fma(v[0], m[452], fma(v[1], m[453], tmp[2]));
	tmp[3] = fma(v[0], m[454], fma(v[1], m[455], tmp[3]));
	tmp[4] = fma(v[0], m[456], fma(v[1], m[457], tmp[4]));
	tmp[5] = fma(v[0], m[458], fma(v[1], m[459], tmp[5]));
	tmp[6] = fma(v[0], m[460], fma(v[1], m[461], tmp[6]));
	tmp[7] = fma(v[0], m[462], fma(v[1], m[463], tmp[7]));
	tmp[8] = fma(v[0], m[464], fma(v[1], m[465], tmp[8]));
	tmp[9] = fma(v[0], m[466], fma(v[1], m[467], tmp[9]));
	tmp[10] = fma(v[0], m[468], fma(v[1], m[469], tmp[10]));
	tmp[11] = fma(v[0], m[470], fma(v[1], m[471], tmp[11]));
	tmp[12] = fma(v[0], m[472], fma(v[1], m[473], tmp[12]));
	tmp[13] = fma(v[0], m[474], fma(v[1], m[475], tmp[13]));
	tmp[14] = fma(v[0], m[476], fma(v[1], m[477], tmp[14]));
	tmp[15] = fma(v[0], m[478], fma(v[1], m[479], tmp[15]));
	tmp[16] = fma(v[0], m[480], fma(v[1], m[481], tmp[16]));
	tmp[17] = fma(v[0], m[482], fma(v[1], m[483], tmp[17]));
	tmp[18] = fma(v[0], m[484], fma(v[1], m[485], tmp[18]));
	tmp[19] = fma(v[0], m[486], fma(v[1], m[487], tmp[19]));
	tmp[20] = fma(v[0], m[488], fma(v[1], m[489], tmp[20]));
	tmp[21] = fma(v[0], m[490], fma(v[1], m[491], tmp[21]));
	tmp[22] = fma(v[0], m[492], fma(v[1], m[493], tmp[22]));
	tmp[23] = fma(v[0], m[494], fma(v[1], m[495], tmp[23]));
	tmp[24] = fma(v[0], m[496], fma(v[1], m[497], tmp[24]));
	tmp[25] = fma(v[0], m[498], fma(v[1], m[499], tmp[25]));
	tmp[26] = fma(v[0], m[500], fma(v[1], m[501], tmp[26]));
	tmp[27] = fma(v[0], m[502], fma(v[1], m[503], tmp[27]));
	tmp[28] = fma(v[0], m[504], fma(v[1], m[505], tmp[28]));
	tmp[29] = fma(v[0], m[506], fma(v[1], m[507], tmp[29]));
	tmp[30] = fma(v[0], m[508], fma(v[1], m[509], tmp[30]));
	tmp[31] = fma(v[0], m[510], fma(v[1], m[511], tmp[31]));

	v[0] = psi[I + d4];
	v[1] = psi[I + d0 + d4];

	tmp[0] = fma(v[0], m[512], fma(v[1], m[513], tmp[0]));
	tmp[1] = fma(v[0], m[514], fma(v[1], m[515], tmp[1]));
	tmp[2] = fma(v[0], m[516], fma(v[1], m[517], tmp[2]));
	tmp[3] = fma(v[0], m[518], fma(v[1], m[519], tmp[3]));
	tmp[4] = fma(v[0], m[520], fma(v[1], m[521], tmp[4]));
	tmp[5] = fma(v[0], m[522], fma(v[1], m[523], tmp[5]));
	tmp[6] = fma(v[0], m[524], fma(v[1], m[525], tmp[6]));
	tmp[7] = fma(v[0], m[526], fma(v[1], m[527], tmp[7]));
	tmp[8] = fma(v[0], m[528], fma(v[1], m[529], tmp[8]));
	tmp[9] = fma(v[0], m[530], fma(v[1], m[531], tmp[9]));
	tmp[10] = fma(v[0], m[532], fma(v[1], m[533], tmp[10]));
	tmp[11] = fma(v[0], m[534], fma(v[1], m[535], tmp[11]));
	tmp[12] = fma(v[0], m[536], fma(v[1], m[537], tmp[12]));
	tmp[13] = fma(v[0], m[538], fma(v[1], m[539], tmp[13]));
	tmp[14] = fma(v[0], m[540], fma(v[1], m[541], tmp[14]));
	tmp[15] = fma(v[0], m[542], fma(v[1], m[543], tmp[15]));
	tmp[16] = fma(v[0], m[544], fma(v[1], m[545], tmp[16]));
	tmp[17] = fma(v[0], m[546], fma(v[1], m[547], tmp[17]));
	tmp[18] = fma(v[0], m[548], fma(v[1], m[549], tmp[18]));
	tmp[19] = fma(v[0], m[550], fma(v[1], m[551], tmp[19]));
	tmp[20] = fma(v[0], m[552], fma(v[1], m[553], tmp[20]));
	tmp[21] = fma(v[0], m[554], fma(v[1], m[555], tmp[21]));
	tmp[22] = fma(v[0], m[556], fma(v[1], m[557], tmp[22]));
	tmp[23] = fma(v[0], m[558], fma(v[1], m[559], tmp[23]));
	tmp[24] = fma(v[0], m[560], fma(v[1], m[561], tmp[24]));
	tmp[25] = fma(v[0], m[562], fma(v[1], m[563], tmp[25]));
	tmp[26] = fma(v[0], m[564], fma(v[1], m[565], tmp[26]));
	tmp[27] = fma(v[0], m[566], fma(v[1], m[567], tmp[27]));
	tmp[28] = fma(v[0], m[568], fma(v[1], m[569], tmp[28]));
	tmp[29] = fma(v[0], m[570], fma(v[1], m[571], tmp[29]));
	tmp[30] = fma(v[0], m[572], fma(v[1], m[573], tmp[30]));
	tmp[31] = fma(v[0], m[574], fma(v[1], m[575], tmp[31]));

	v[0] = psi[I + d1 + d4];
	v[1] = psi[I + d0 + d1 + d4];

	tmp[0] = fma(v[0], m[576], fma(v[1], m[577], tmp[0]));
	tmp[1] = fma(v[0], m[578], fma(v[1], m[579], tmp[1]));
	tmp[2] = fma(v[0], m[580], fma(v[1], m[581], tmp[2]));
	tmp[3] = fma(v[0], m[582], fma(v[1], m[583], tmp[3]));
	tmp[4] = fma(v[0], m[584], fma(v[1], m[585], tmp[4]));
	tmp[5] = fma(v[0], m[586], fma(v[1], m[587], tmp[5]));
	tmp[6] = fma(v[0], m[588], fma(v[1], m[589], tmp[6]));
	tmp[7] = fma(v[0], m[590], fma(v[1], m[591], tmp[7]));
	tmp[8] = fma(v[0], m[592], fma(v[1], m[593], tmp[8]));
	tmp[9] = fma(v[0], m[594], fma(v[1], m[595], tmp[9]));
	tmp[10] = fma(v[0], m[596], fma(v[1], m[597], tmp[10]));
	tmp[11] = fma(v[0], m[598], fma(v[1], m[599], tmp[11]));
	tmp[12] = fma(v[0], m[600], fma(v[1], m[601], tmp[12]));
	tmp[13] = fma(v[0], m[602], fma(v[1], m[603], tmp[13]));
	tmp[14] = fma(v[0], m[604], fma(v[1], m[605], tmp[14]));
	tmp[15] = fma(v[0], m[606], fma(v[1], m[607], tmp[15]));
	tmp[16] = fma(v[0], m[608], fma(v[1], m[609], tmp[16]));
	tmp[17] = fma(v[0], m[610], fma(v[1], m[611], tmp[17]));
	tmp[18] = fma(v[0], m[612], fma(v[1], m[613], tmp[18]));
	tmp[19] = fma(v[0], m[614], fma(v[1], m[615], tmp[19]));
	tmp[20] = fma(v[0], m[616], fma(v[1], m[617], tmp[20]));
	tmp[21] = fma(v[0], m[618], fma(v[1], m[619], tmp[21]));
	tmp[22] = fma(v[0], m[620], fma(v[1], m[621], tmp[22]));
	tmp[23] = fma(v[0], m[622], fma(v[1], m[623], tmp[23]));
	tmp[24] = fma(v[0], m[624], fma(v[1], m[625], tmp[24]));
	tmp[25] = fma(v[0], m[626], fma(v[1], m[627], tmp[25]));
	tmp[26] = fma(v[0], m[628], fma(v[1], m[629], tmp[26]));
	tmp[27] = fma(v[0], m[630], fma(v[1], m[631], tmp[27]));
	tmp[28] = fma(v[0], m[632], fma(v[1], m[633], tmp[28]));
	tmp[29] = fma(v[0], m[634], fma(v[1], m[635], tmp[29]));
	tmp[30] = fma(v[0], m[636], fma(v[1], m[637], tmp[30]));
	tmp[31] = fma(v[0], m[638], fma(v[1], m[639], tmp[31]));

	v[0] = psi[I + d2 + d4];
	v[1] = psi[I + d0 + d2 + d4];

	tmp[0] = fma(v[0], m[640], fma(v[1], m[641], tmp[0]));
	tmp[1] = fma(v[0], m[642], fma(v[1], m[643], tmp[1]));
	tmp[2] = fma(v[0], m[644], fma(v[1], m[645], tmp[2]));
	tmp[3] = fma(v[0], m[646], fma(v[1], m[647], tmp[3]));
	tmp[4] = fma(v[0], m[648], fma(v[1], m[649], tmp[4]));
	tmp[5] = fma(v[0], m[650], fma(v[1], m[651], tmp[5]));
	tmp[6] = fma(v[0], m[652], fma(v[1], m[653], tmp[6]));
	tmp[7] = fma(v[0], m[654], fma(v[1], m[655], tmp[7]));
	tmp[8] = fma(v[0], m[656], fma(v[1], m[657], tmp[8]));
	tmp[9] = fma(v[0], m[658], fma(v[1], m[659], tmp[9]));
	tmp[10] = fma(v[0], m[660], fma(v[1], m[661], tmp[10]));
	tmp[11] = fma(v[0], m[662], fma(v[1], m[663], tmp[11]));
	tmp[12] = fma(v[0], m[664], fma(v[1], m[665], tmp[12]));
	tmp[13] = fma(v[0], m[666], fma(v[1], m[667], tmp[13]));
	tmp[14] = fma(v[0], m[668], fma(v[1], m[669], tmp[14]));
	tmp[15] = fma(v[0], m[670], fma(v[1], m[671], tmp[15]));
	tmp[16] = fma(v[0], m[672], fma(v[1], m[673], tmp[16]));
	tmp[17] = fma(v[0], m[674], fma(v[1], m[675], tmp[17]));
	tmp[18] = fma(v[0], m[676], fma(v[1], m[677], tmp[18]));
	tmp[19] = fma(v[0], m[678], fma(v[1], m[679], tmp[19]));
	tmp[20] = fma(v[0], m[680], fma(v[1], m[681], tmp[20]));
	tmp[21] = fma(v[0], m[682], fma(v[1], m[683], tmp[21]));
	tmp[22] = fma(v[0], m[684], fma(v[1], m[685], tmp[22]));
	tmp[23] = fma(v[0], m[686], fma(v[1], m[687], tmp[23]));
	tmp[24] = fma(v[0], m[688], fma(v[1], m[689], tmp[24]));
	tmp[25] = fma(v[0], m[690], fma(v[1], m[691], tmp[25]));
	tmp[26] = fma(v[0], m[692], fma(v[1], m[693], tmp[26]));
	tmp[27] = fma(v[0], m[694], fma(v[1], m[695], tmp[27]));
	tmp[28] = fma(v[0], m[696], fma(v[1], m[697], tmp[28]));
	tmp[29] = fma(v[0], m[698], fma(v[1], m[699], tmp[29]));
	tmp[30] = fma(v[0], m[700], fma(v[1], m[701], tmp[30]));
	tmp[31] = fma(v[0], m[702], fma(v[1], m[703], tmp[31]));

	v[0] = psi[I + d1 + d2 + d4];
	v[1] = psi[I + d0 + d1 + d2 + d4];

	tmp[0] = fma(v[0], m[704], fma(v[1], m[705], tmp[0]));
	tmp[1] = fma(v[0], m[706], fma(v[1], m[707], tmp[1]));
	tmp[2] = fma(v[0], m[708], fma(v[1], m[709], tmp[2]));
	tmp[3] = fma(v[0], m[710], fma(v[1], m[711], tmp[3]));
	tmp[4] = fma(v[0], m[712], fma(v[1], m[713], tmp[4]));
	tmp[5] = fma(v[0], m[714], fma(v[1], m[715], tmp[5]));
	tmp[6] = fma(v[0], m[716], fma(v[1], m[717], tmp[6]));
	tmp[7] = fma(v[0], m[718], fma(v[1], m[719], tmp[7]));
	tmp[8] = fma(v[0], m[720], fma(v[1], m[721], tmp[8]));
	tmp[9] = fma(v[0], m[722], fma(v[1], m[723], tmp[9]));
	tmp[10] = fma(v[0], m[724], fma(v[1], m[725], tmp[10]));
	tmp[11] = fma(v[0], m[726], fma(v[1], m[727], tmp[11]));
	tmp[12] = fma(v[0], m[728], fma(v[1], m[729], tmp[12]));
	tmp[13] = fma(v[0], m[730], fma(v[1], m[731], tmp[13]));
	tmp[14] = fma(v[0], m[732], fma(v[1], m[733], tmp[14]));
	tmp[15] = fma(v[0], m[734], fma(v[1], m[735], tmp[15]));
	tmp[16] = fma(v[0], m[736], fma(v[1], m[737], tmp[16]));
	tmp[17] = fma(v[0], m[738], fma(v[1], m[739], tmp[17]));
	tmp[18] = fma(v[0], m[740], fma(v[1], m[741], tmp[18]));
	tmp[19] = fma(v[0], m[742], fma(v[1], m[743], tmp[19]));
	tmp[20] = fma(v[0], m[744], fma(v[1], m[745], tmp[20]));
	tmp[21] = fma(v[0], m[746], fma(v[1], m[747], tmp[21]));
	tmp[22] = fma(v[0], m[748], fma(v[1], m[749], tmp[22]));
	tmp[23] = fma(v[0], m[750], fma(v[1], m[751], tmp[23]));
	tmp[24] = fma(v[0], m[752], fma(v[1], m[753], tmp[24]));
	tmp[25] = fma(v[0], m[754], fma(v[1], m[755], tmp[25]));
	tmp[26] = fma(v[0], m[756], fma(v[1], m[757], tmp[26]));
	tmp[27] = fma(v[0], m[758], fma(v[1], m[759], tmp[27]));
	tmp[28] = fma(v[0], m[760], fma(v[1], m[761], tmp[28]));
	tmp[29] = fma(v[0], m[762], fma(v[1], m[763], tmp[29]));
	tmp[30] = fma(v[0], m[764], fma(v[1], m[765], tmp[30]));
	tmp[31] = fma(v[0], m[766], fma(v[1], m[767], tmp[31]));

	v[0] = psi[I + d3 + d4];
	v[1] = psi[I + d0 + d3 + d4];

	tmp[0] = fma(v[0], m[768], fma(v[1], m[769], tmp[0]));
	tmp[1] = fma(v[0], m[770], fma(v[1], m[771], tmp[1]));
	tmp[2] = fma(v[0], m[772], fma(v[1], m[773], tmp[2]));
	tmp[3] = fma(v[0], m[774], fma(v[1], m[775], tmp[3]));
	tmp[4] = fma(v[0], m[776], fma(v[1], m[777], tmp[4]));
	tmp[5] = fma(v[0], m[778], fma(v[1], m[779], tmp[5]));
	tmp[6] = fma(v[0], m[780], fma(v[1], m[781], tmp[6]));
	tmp[7] = fma(v[0], m[782], fma(v[1], m[783], tmp[7]));
	tmp[8] = fma(v[0], m[784], fma(v[1], m[785], tmp[8]));
	tmp[9] = fma(v[0], m[786], fma(v[1], m[787], tmp[9]));
	tmp[10] = fma(v[0], m[788], fma(v[1], m[789], tmp[10]));
	tmp[11] = fma(v[0], m[790], fma(v[1], m[791], tmp[11]));
	tmp[12] = fma(v[0], m[792], fma(v[1], m[793], tmp[12]));
	tmp[13] = fma(v[0], m[794], fma(v[1], m[795], tmp[13]));
	tmp[14] = fma(v[0], m[796], fma(v[1], m[797], tmp[14]));
	tmp[15] = fma(v[0], m[798], fma(v[1], m[799], tmp[15]));
	tmp[16] = fma(v[0], m[800], fma(v[1], m[801], tmp[16]));
	tmp[17] = fma(v[0], m[802], fma(v[1], m[803], tmp[17]));
	tmp[18] = fma(v[0], m[804], fma(v[1], m[805], tmp[18]));
	tmp[19] = fma(v[0], m[806], fma(v[1], m[807], tmp[19]));
	tmp[20] = fma(v[0], m[808], fma(v[1], m[809], tmp[20]));
	tmp[21] = fma(v[0], m[810], fma(v[1], m[811], tmp[21]));
	tmp[22] = fma(v[0], m[812], fma(v[1], m[813], tmp[22]));
	tmp[23] = fma(v[0], m[814], fma(v[1], m[815], tmp[23]));
	tmp[24] = fma(v[0], m[816], fma(v[1], m[817], tmp[24]));
	tmp[25] = fma(v[0], m[818], fma(v[1], m[819], tmp[25]));
	tmp[26] = fma(v[0], m[820], fma(v[1], m[821], tmp[26]));
	tmp[27] = fma(v[0], m[822], fma(v[1], m[823], tmp[27]));
	tmp[28] = fma(v[0], m[824], fma(v[1], m[825], tmp[28]));
	tmp[29] = fma(v[0], m[826], fma(v[1], m[827], tmp[29]));
	tmp[30] = fma(v[0], m[828], fma(v[1], m[829], tmp[30]));
	tmp[31] = fma(v[0], m[830], fma(v[1], m[831], tmp[31]));

	v[0] = psi[I + d1 + d3 + d4];
	v[1] = psi[I + d0 + d1 + d3 + d4];

	tmp[0] = fma(v[0], m[832], fma(v[1], m[833], tmp[0]));
	tmp[1] = fma(v[0], m[834], fma(v[1], m[835], tmp[1]));
	tmp[2] = fma(v[0], m[836], fma(v[1], m[837], tmp[2]));
	tmp[3] = fma(v[0], m[838], fma(v[1], m[839], tmp[3]));
	tmp[4] = fma(v[0], m[840], fma(v[1], m[841], tmp[4]));
	tmp[5] = fma(v[0], m[842], fma(v[1], m[843], tmp[5]));
	tmp[6] = fma(v[0], m[844], fma(v[1], m[845], tmp[6]));
	tmp[7] = fma(v[0], m[846], fma(v[1], m[847], tmp[7]));
	tmp[8] = fma(v[0], m[848], fma(v[1], m[849], tmp[8]));
	tmp[9] = fma(v[0], m[850], fma(v[1], m[851], tmp[9]));
	tmp[10] = fma(v[0], m[852], fma(v[1], m[853], tmp[10]));
	tmp[11] = fma(v[0], m[854], fma(v[1], m[855], tmp[11]));
	tmp[12] = fma(v[0], m[856], fma(v[1], m[857], tmp[12]));
	tmp[13] = fma(v[0], m[858], fma(v[1], m[859], tmp[13]));
	tmp[14] = fma(v[0], m[860], fma(v[1], m[861], tmp[14]));
	tmp[15] = fma(v[0], m[862], fma(v[1], m[863], tmp[15]));
	tmp[16] = fma(v[0], m[864], fma(v[1], m[865], tmp[16]));
	tmp[17] = fma(v[0], m[866], fma(v[1], m[867], tmp[17]));
	tmp[18] = fma(v[0], m[868], fma(v[1], m[869], tmp[18]));
	tmp[19] = fma(v[0], m[870], fma(v[1], m[871], tmp[19]));
	tmp[20] = fma(v[0], m[872], fma(v[1], m[873], tmp[20]));
	tmp[21] = fma(v[0], m[874], fma(v[1], m[875], tmp[21]));
	tmp[22] = fma(v[0], m[876], fma(v[1], m[877], tmp[22]));
	tmp[23] = fma(v[0], m[878], fma(v[1], m[879], tmp[23]));
	tmp[24] = fma(v[0], m[880], fma(v[1], m[881], tmp[24]));
	tmp[25] = fma(v[0], m[882], fma(v[1], m[883], tmp[25]));
	tmp[26] = fma(v[0], m[884], fma(v[1], m[885], tmp[26]));
	tmp[27] = fma(v[0], m[886], fma(v[1], m[887], tmp[27]));
	tmp[28] = fma(v[0], m[888], fma(v[1], m[889], tmp[28]));
	tmp[29] = fma(v[0], m[890], fma(v[1], m[891], tmp[29]));
	tmp[30] = fma(v[0], m[892], fma(v[1], m[893], tmp[30]));
	tmp[31] = fma(v[0], m[894], fma(v[1], m[895], tmp[31]));

	v[0] = psi[I + d2 + d3 + d4];
	v[1] = psi[I + d0 + d2 + d3 + d4];

	tmp[0] = fma(v[0], m[896], fma(v[1], m[897], tmp[0]));
	tmp[1] = fma(v[0], m[898], fma(v[1], m[899], tmp[1]));
	tmp[2] = fma(v[0], m[900], fma(v[1], m[901], tmp[2]));
	tmp[3] = fma(v[0], m[902], fma(v[1], m[903], tmp[3]));
	tmp[4] = fma(v[0], m[904], fma(v[1], m[905], tmp[4]));
	tmp[5] = fma(v[0], m[906], fma(v[1], m[907], tmp[5]));
	tmp[6] = fma(v[0], m[908], fma(v[1], m[909], tmp[6]));
	tmp[7] = fma(v[0], m[910], fma(v[1], m[911], tmp[7]));
	tmp[8] = fma(v[0], m[912], fma(v[1], m[913], tmp[8]));
	tmp[9] = fma(v[0], m[914], fma(v[1], m[915], tmp[9]));
	tmp[10] = fma(v[0], m[916], fma(v[1], m[917], tmp[10]));
	tmp[11] = fma(v[0], m[918], fma(v[1], m[919], tmp[11]));
	tmp[12] = fma(v[0], m[920], fma(v[1], m[921], tmp[12]));
	tmp[13] = fma(v[0], m[922], fma(v[1], m[923], tmp[13]));
	tmp[14] = fma(v[0], m[924], fma(v[1], m[925], tmp[14]));
	tmp[15] = fma(v[0], m[926], fma(v[1], m[927], tmp[15]));
	tmp[16] = fma(v[0], m[928], fma(v[1], m[929], tmp[16]));
	tmp[17] = fma(v[0], m[930], fma(v[1], m[931], tmp[17]));
	tmp[18] = fma(v[0], m[932], fma(v[1], m[933], tmp[18]));
	tmp[19] = fma(v[0], m[934], fma(v[1], m[935], tmp[19]));
	tmp[20] = fma(v[0], m[936], fma(v[1], m[937], tmp[20]));
	tmp[21] = fma(v[0], m[938], fma(v[1], m[939], tmp[21]));
	tmp[22] = fma(v[0], m[940], fma(v[1], m[941], tmp[22]));
	tmp[23] = fma(v[0], m[942], fma(v[1], m[943], tmp[23]));
	tmp[24] = fma(v[0], m[944], fma(v[1], m[945], tmp[24]));
	tmp[25] = fma(v[0], m[946], fma(v[1], m[947], tmp[25]));
	tmp[26] = fma(v[0], m[948], fma(v[1], m[949], tmp[26]));
	tmp[27] = fma(v[0], m[950], fma(v[1], m[951], tmp[27]));
	tmp[28] = fma(v[0], m[952], fma(v[1], m[953], tmp[28]));
	tmp[29] = fma(v[0], m[954], fma(v[1], m[955], tmp[29]));
	tmp[30] = fma(v[0], m[956], fma(v[1], m[957], tmp[30]));
	tmp[31] = fma(v[0], m[958], fma(v[1], m[959], tmp[31]));

	v[0] = psi[I + d1 + d2 + d3 + d4];
	v[1] = psi[I + d0 + d1 + d2 + d3 + d4];

	tmp[0] = fma(v[0], m[960], fma(v[1], m[961], tmp[0]));
	tmp[1] = fma(v[0], m[962], fma(v[1], m[963], tmp[1]));
	tmp[2] = fma(v[0], m[964], fma(v[1], m[965], tmp[2]));
	tmp[3] = fma(v[0], m[966], fma(v[1], m[967], tmp[3]));
	psi[I] = tmp[0];
	psi[I + d0] = tmp[1];
	psi[I + d1] = tmp[2];
	psi[I + d0 + d1] = tmp[3];
	tmp[4] = fma(v[0], m[968], fma(v[1], m[969], tmp[4]));
	tmp[5] = fma(v[0], m[970], fma(v[1], m[971], tmp[5]));
	tmp[6] = fma(v[0], m[972], fma(v[1], m[973], tmp[6]));
	tmp[7] = fma(v[0], m[974], fma(v[1], m[975], tmp[7]));
	psi[I + d2] = tmp[4];
	psi[I + d0 + d2] = tmp[5];
	psi[I + d1 + d2] = tmp[6];
	psi[I + d0 + d1 + d2] = tmp[7];
	tmp[8] = fma(v[0], m[976], fma(v[1], m[977], tmp[8]));
	tmp[9] = fma(v[0], m[978], fma(v[1], m[979], tmp[9]));
	tmp[10] = fma(v[0], m[980], fma(v[1], m[981], tmp[10]));
	tmp[11] = fma(v[0], m[982], fma(v[1], m[983], tmp[11]));
	psi[I + d3] = tmp[8];
	psi[I + d0 + d3] = tmp[9];
	psi[I + d1 + d3] = tmp[10];
	psi[I + d0 + d1 + d3] = tmp[11];
	tmp[12] = fma(v[0], m[984], fma(v[1], m[985], tmp[12]));
	tmp[13] = fma(v[0], m[986], fma(v[1], m[987], tmp[13]));
	tmp[14] = fma(v[0], m[988], fma(v[1], m[989], tmp[14]));
	tmp[15] = fma(v[0], m[990], fma(v[1], m[991], tmp[15]));
	psi[I + d2 + d3] = tmp[12];
	psi[I + d0 + d2 + d3] = tmp[13];
	psi[I + d1 + d2 + d3] = tmp[14];
	psi[I + d0 + d1 + d2 + d3] = tmp[15];
	tmp[16] = fma(v[0], m[992], fma(v[1], m[993], tmp[16]));
	tmp[17] = fma(v[0], m[994], fma(v[1], m[995], tmp[17]));
	tmp[18] = fma(v[0], m[996], fma(v[1], m[997], tmp[18]));
	tmp[19] = fma(v[0], m[998], fma(v[1], m[999], tmp[19]));
	psi[I + d4] = tmp[16];
	psi[I + d0 + d4] = tmp[17];
	psi[I + d1 + d4] = tmp[18];
	psi[I + d0 + d1 + d4] = tmp[19];
	tmp[20] = fma(v[0], m[1000], fma(v[1], m[1001], tmp[20]));
	tmp[21] = fma(v[0], m[1002], fma(v[1], m[1003], tmp[21]));
	tmp[22] = fma(v[0], m[1004], fma(v[1], m[1005], tmp[22]));
	tmp[23] = fma(v[0], m[1006], fma(v[1], m[1007], tmp[23]));
	psi[I + d2 + d4] = tmp[20];
	psi[I + d0 + d2 + d4] = tmp[21];
	psi[I + d1 + d2 + d4] = tmp[22];
	psi[I + d0 + d1 + d2 + d4] = tmp[23];
	tmp[24] = fma(v[0], m[1008], fma(v[1], m[1009], tmp[24]));
	tmp[25] = fma(v[0], m[1010], fma(v[1], m[1011], tmp[25]));
	tmp[26] = fma(v[0], m[1012], fma(v[1], m[1013], tmp[26]));
	tmp[27] = fma(v[0], m[1014], fma(v[1], m[1015], tmp[27]));
	psi[I + d3 + d4] = tmp[24];
	psi[I + d0 + d3 + d4] = tmp[25];
	psi[I + d1 + d3 + d4] = tmp[26];
	psi[I + d0 + d1 + d3 + d4] = tmp[27];
	tmp[28] = fma(v[0], m[1016], fma(v[1], m[1017], tmp[28]));
	tmp[29] = fma(v[0], m[1018], fma(v[1], m[1019], tmp[29]));
	tmp[30] = fma(v[0], m[1020], fma(v[1], m[1021], tmp[30]));
	tmp[31] = fma(v[0], m[1022], fma(v[1], m[1023], tmp[31]));
	psi[I + d2 + d3 + d4] = tmp[28];
	psi[I + d0 + d2 + d3 + d4] = tmp[29];
	psi[I + d1 + d2 + d3 + d4] = tmp[30];
	psi[I + d0 + d1 + d2 + d3 + d4] = tmp[31];

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

	std::complex<double> mm[1024];
	for (unsigned b = 0; b < 16; ++b){
		for (unsigned r = 0; r < 32; ++r){
			for (unsigned c = 0; c < 2; ++c){
				mm[b*64+r*2+c] = m[r][c+b*2];
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
								kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
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
									kernel_core(psi, i0 + i1 + i2 + i3 + i4 + i5, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
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
				kernel_core(psi, i, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	} else {
		#pragma omp parallel for schedule(static)
		for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(n); ++i)
			if ((i & ctrlmask) == ctrlmask && (i & dmask) == zero)
				kernel_core(psi, i, dsorted[4], dsorted[3], dsorted[2], dsorted[1], dsorted[0], mm);
	}
#endif
}

