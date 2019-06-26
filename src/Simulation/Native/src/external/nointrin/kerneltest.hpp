// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

template <class V, class M>
void kernel7test(V &v, unsigned p, unsigned o, unsigned n, unsigned l, unsigned i, unsigned j, unsigned k, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 64*((s>>p)&1) + 32*((s>>o)&1) + 16*((s>>n)&1) + 8*((s>>l)&1) + 4*((s>>i)&1)+2*((s>>j)&1)+((s>>k)&1);
		for (unsigned i2 = 0; i2 < 128; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>6)&1)
				s2^=(1<<p);
			if ((helper>>5)&1)
				s2^=(1<<o);
			if ((helper>>4)&1)
				s2^=(1<<n);
			if ((helper>>3)&1)
				s2^=(1<<l);
			if ((helper>>2)&1)
				s2^=(1<<i);
			if ((helper>>1)&1)
				s2^=(1<<j);
			if (helper&1)
				s2^=(1<<k);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}
template <class V, class M>
void kernel6test(V &v, unsigned o, unsigned n, unsigned l, unsigned i, unsigned j, unsigned k, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 32*((s>>o)&1) + 16*((s>>n)&1) + 8*((s>>l)&1) + 4*((s>>i)&1)+2*((s>>j)&1)+((s>>k)&1);
		for (unsigned i2 = 0; i2 < 64; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>5)&1)
				s2^=(1<<o);
			if ((helper>>4)&1)
				s2^=(1<<n);
			if ((helper>>3)&1)
				s2^=(1<<l);
			if ((helper>>2)&1)
				s2^=(1<<i);
			if ((helper>>1)&1)
				s2^=(1<<j);
			if (helper&1)
				s2^=(1<<k);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}

template <class V, class M>
void kernel5test(V &v, unsigned n, unsigned l, unsigned i, unsigned j, unsigned k, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 16*((s>>n)&1) + 8*((s>>l)&1) + 4*((s>>i)&1)+2*((s>>j)&1)+((s>>k)&1);
		for (unsigned i2 = 0; i2 < 32; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>4)&1)
				s2^=(1<<n);
			if ((helper>>3)&1)
				s2^=(1<<l);
			if ((helper>>2)&1)
				s2^=(1<<i);
			if ((helper>>1)&1)
				s2^=(1<<j);
			if (helper&1)
				s2^=(1<<k);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}

template <class V, class M>
void kernel4test(V &v, unsigned l, unsigned i, unsigned j, unsigned k, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 8*((s>>l)&1) + 4*((s>>i)&1)+2*((s>>j)&1)+((s>>k)&1);
		for (unsigned i2 = 0; i2 < 16; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>3)&1)
				s2^=(1<<l);
			if ((helper>>2)&1)
				s2^=(1<<i);
			if ((helper>>1)&1)
				s2^=(1<<j);
			if (helper&1)
				s2^=(1<<k);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}

template <class V, class M>
void kernel3test(V &v, unsigned i, unsigned j, unsigned k, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 4*((s>>i)&1)+2*((s>>j)&1)+((s>>k)&1);
		for (unsigned i2 = 0; i2 < 8; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>2)&1)
				s2^=(1<<i);
			if ((helper>>1)&1)
				s2^=(1<<j);
			if (helper&1)
				s2^=(1<<k);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}

template <class V, class M>
void kernel2test(V &v, unsigned i, unsigned j, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = 2*((s>>i)&1)+((s>>j)&1);
		for (unsigned i2 = 0; i2 < 4; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if ((helper>>1)&1)
				s2^=(1<<i);
			if ((helper)&1)
				s2^=(1<<j);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}

template <class V, class M>
void kernel1test(V &v, unsigned i, M const& m){
	V psi(v.size(), 0.);
	for (std::size_t s = 0; s < v.size(); ++s){
		unsigned idx = ((s>>i)&1);
		for (unsigned i2 = 0; i2 < 2; ++i2){
			std::size_t s2 = s;
			unsigned helper = idx^i2;
			if (helper&1)
				s2^=(1<<i);
			psi[s2]+=m[i2][idx]*v[s];
		}
	}
	v = std::move(psi);
}


template <class V>
void toffoli(V &v, unsigned i, unsigned j, unsigned k){
	#pragma omp parallel for schedule(static)
	for (std::size_t s = 0; s < v.size(); ++s){
		if ((bool)((s>>i)&1) && (bool)((s>>j)&1) && !(bool)((s>>k)&1))
			swap(v[s+(1<<k)], v[s]);
	}
}
template <class V>
void cx(V &v, unsigned i, unsigned j){
	#pragma omp parallel for schedule(static)
	for (std::size_t s = 0; s < v.size(); ++s){
		if ((bool)((s>>i)&1) && !(bool)((s>>j)&1))
			swap(v[s+(1<<j)], v[s]);
	}
}
template <class V>
void x(V &v, unsigned i){
	std::size_t d = 1UL << i;
	#pragma omp parallel for schedule(static)
	for (std::size_t s = 0; s < v.size(); s+=2*d){
		for (std::size_t s2 = 0; s2 < d; ++s2)
			swap(v[s+s2+d], v[s+s2]);
	}
}


