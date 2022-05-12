// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#ifndef CINTRIN_HPP_
#define CINTRIN_HPP_

//#include <x86intrin.h>
#include <immintrin.h>
#include <complex>
#include <vector>
#include <algorithm>

template <class M, class I>
inline void permute_qubits_and_matrix(I *delta_list, unsigned n, M & matrix){
	using Pair = std::pair<std::size_t, std::size_t>;
	std::vector<Pair> qubits(n);
	for (std::size_t i = 0; i < qubits.size(); ++i){
		qubits[i].first = i;
		qubits[i].second = delta_list[i];
	}
	std::sort(qubits.begin(), qubits.end(), [](Pair const& p1, Pair const& p2){ return p1.second < p2.second; });
	
	M old = matrix;
	
	for (std::size_t i = 0; i < (1ULL << qubits.size()); ++i){
		for (std::size_t j = 0; j < (1ULL << qubits.size()); ++j){
			std::size_t old_i=0, old_j=0;
			for (std::size_t k = 0; k < qubits.size(); ++k){
				old_i |= ((i >> k)&1ULL) << qubits[k].first;
				old_j |= ((j >> k)&1ULL) << qubits[k].first;
			}
			matrix[i][j] = old[old_i][old_j];
		}
	}
	std::sort(delta_list, delta_list+n, std::greater<I>());
}

inline std::complex<double> fma(std::complex<double> const& c1, std::complex<double> const& c2, std::complex<double> const& a){
	// Expanded complex FMA to hard coded access (much faster)
#ifdef _MSC_VER
	double r = (c1._Val[0] * c2._Val[0] - c1._Val[1] * c2._Val[1]) + a._Val[0];
	double i = (c1._Val[0] * c2._Val[1] + c1._Val[1] * c2._Val[0]) + a._Val[1];
#else
	double r = (c1.real() * c2.real() - c1.imag() * c2.imag()) + a.real();
	double i = (c1.real() * c2.imag() + c1.imag() * c2.real()) + a.imag();
#endif
	return std::complex<double>(r, i);
}

inline __m256d fma(__m256d const& c1, __m256d const& c2, __m256d const& a){
	auto const c1t = _mm256_permute_pd(c1, 5);
	#ifndef HAVE_FMA
	auto tmp = _mm256_addsub_pd(_mm256_mul_pd(c1t, _mm256_permute_pd(c2, 15)), a);
	return _mm256_addsub_pd(_mm256_mul_pd(c1, _mm256_permute_pd(c2, 0)), tmp);
	#else
	return _mm256_fmaddsub_pd(c1, _mm256_permute_pd(c2, 0), _mm256_fmaddsub_pd(c1t, _mm256_permute_pd(c2, 15), a));
	#endif
}
inline __m256d fma(__m256d const& c1, __m256d const& c2, __m256d const& c2tm, __m256d const& a){
	auto const c1t = _mm256_permute_pd(c1, 5);
	#ifndef HAVE_FMA
	auto const tmp = _mm256_add_pd(_mm256_mul_pd(c1, c2), a);
	return _mm256_add_pd(_mm256_mul_pd(c1t, c2tm), tmp);
	#else
	return _mm256_fmadd_pd(c1, c2, _mm256_fmadd_pd(c1t, c2tm, a));
	#endif
}
template <class U>
inline __m256d load1(U *p){
	/*auto const tmp = _mm_load_pd((double const*)p);
	return _mm256_insertf128_pd(_mm256_castpd128_pd256(tmp), tmp, 0x1);*/
	return _mm256_broadcast_pd((__m128d const*)p);
}
template <class U>
inline __m256d load(U const*p1, U const*p2){
	return _mm256_insertf128_pd(_mm256_castpd128_pd256(_mm_load_pd((double const*)p1)), _mm_load_pd((double const*)p2), 0x1);
}
template <class U>
inline __m256d loadab(U *p1, U *p2){
	return load(p1, p2);
	//return _mm256_set_pd(std::imag(*p2), std::real(*p2), std::imag(*p1), std::real(*p1));
}
template <class U>
inline __m256d loada(U *p1, U *p2){
	auto r1 = _mm_load1_pd((double*)p1);
	auto r2 = _mm_load1_pd((double*)p2);
	return _mm256_insertf128_pd(_mm256_castpd128_pd256(r1), r2, 0x1);
	//return _mm256_set_pd(std::real(*p2), std::real(*p2), std::real(*p1), std::real(*p1));
}
template <class U>
inline __m256d loadbm(U *p1, U *p2){
	auto const mpmp = _mm256_set_pd(1., -1., 1., -1.);
	auto i1 = _mm_load1_pd(((double*)p1)+1);
	auto i2 = _mm_load1_pd(((double*)p2)+1);
	auto tmp = _mm256_insertf128_pd(_mm256_castpd128_pd256(i1), i2, 0x1);
	return _mm256_mul_pd(tmp, mpmp);
	//return _mm256_set_pd(std::imag(*p2), -std::imag(*p2), std::imag(*p1), -std::imag(*p1));
}
template <class U>
inline __m256d loadb(U *p1, U *p2){
	auto i1 = _mm_load1_pd(((double*)p1)+1);
	auto i2 = _mm_load1_pd(((double*)p2)+1);
	return _mm256_insertf128_pd(_mm256_castpd128_pd256(i1), i2, 0x1);
}
template <class U>
inline void store(U* high, U* low, __m256d const& a){
	_mm_store_pd(low, _mm256_castpd256_pd128(a));
	_mm_store_pd(high, _mm256_extractf128_pd(a, 0x1));
}


// avx-512
#ifdef HAVE_AVX512
inline __m512d mul(__m512d const& c1, __m512d const& c2, __m512d const& c2tm){
        /*auto ac_bd = _mm512_mul_pd(c1, c2);
        auto multbmadmc = _mm512_mul_pd(c1, c2tm);
        return _mm512_hsub_pd(ac_bd, multbmadmc);*/
        auto c1t = _mm512_permute_pd(c1, 85);
        return _mm512_add_pd(_mm512_mul_pd(c1, c2), _mm512_mul_pd(c1t, c2tm));
}
inline __m512d add(__m512d const& c1, __m512d const& c2){
        return _mm512_add_pd(c1, c2);
}
inline __m512d fma(__m512d const& c1, __m512d const& c2, __m512d const& a){
        auto const c1t = _mm512_permute_pd(c1, 85);
        #ifndef HAVE_FMA
        auto tmp = _mm512_addsub_pd(_mm512_mul_pd(c1t, _mm512_permute_pd(c2, 255)), a);
        return _mm512_addsub_pd(_mm512_mul_pd(c1, _mm512_permute_pd(c2, 0)), tmp);
        #else
        return _mm512_fmaddsub_pd(c1, _mm512_permute_pd(c2, 0), _mm512_fmaddsub_pd(c1t, _mm512_permute_pd(c2, 255), a));
        #endif
}
inline __m512d fma(__m512d const& c1, __m512d const& c2, __m512d const& c2tm, __m512d const& a){
        auto const c1t = _mm512_permute_pd(c1, 85);
        #ifndef HAVE_FMA
        auto const tmp = _mm512_add_pd(_mm512_mul_pd(c1, c2), a);
        return _mm512_add_pd(_mm512_mul_pd(c1t, c2tm), tmp);
        #else
        return _mm512_fmadd_pd(c1, c2, _mm512_fmadd_pd(c1t, c2tm, a));
        #endif
}
template <class U>
inline __m512d load1x4(U *p){
        return _mm512_broadcast_f64x4(load1(p));
}
template <class U>
inline __m512d loadab(U *p1, U *p2, U *p3, U* p4){
        return _mm512_insertf64x4(_mm512_castpd256_pd512(loadab(p1, p2)), loadab(p3, p4), 0x1);
}
template <class U>
inline __m512d loada(U *p1, U *p2, U *p3, U *p4){
        return _mm512_insertf64x4(_mm512_castpd256_pd512(loada(p1, p2)), loada(p3, p4), 0x1);
}
template <class U>
inline __m512d loadbm(U *p1, U *p2, U *p3, U *p4){
        return _mm512_insertf64x4(_mm512_castpd256_pd512(loadbm(p1, p2)), loadbm(p3, p4), 0x1);
}
template <class U>
inline void store(U* hhigh, U* hlow, U* lhigh, U* llow, __m512d const& a){
        auto al = _mm512_castpd512_pd256(a);
        _mm_storeu_pd(llow, _mm256_castpd256_pd128(al));
        _mm_storeu_pd(lhigh, _mm256_extractf128_pd(al, 0x1));
        auto ah = _mm512_extractf64x4_pd(a, 0x1);
        _mm_storeu_pd(hlow, _mm256_castpd256_pd128(ah));
        _mm_storeu_pd(hhigh, _mm256_extractf128_pd(ah, 0x1));
}
template <class U>
inline __m512d load(U const*p1, U const*p2, U const*p3, U const*p4){
        auto tmp = _mm256_insertf128_pd(_mm256_castpd128_pd256(_mm_loadu_pd((double const*)p1)), _mm_loadu_pd((double const*)p2), 0x1);
        auto tmp2 = _mm256_insertf128_pd(_mm256_castpd128_pd256(_mm_loadu_pd((double const*)p3)), _mm_loadu_pd((double const*)p4), 0x1);
        return _mm512_insertf64x4(_mm512_castpd256_pd512(tmp), tmp2, 0x1);
}
#endif
#endif
