// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#ifndef TIMING_HPP_
#define TIMING_HPP_

#include <sys/time.h>

class Timer{
public:
	Timer() {
		start();
	};
	void start(){
		gettimeofday(&t1, 0);
		__asm__ __volatile__ ("cpuid" : : "a" (0) : "bx", "cx", "dx" );
		__asm__ __volatile__ ("rdtsc" : "=a"(cstart.lh.low), "=d"(cstart.lh.high));
		cstop.cs=cstart.cs;
	}
	unsigned long long stop(){
		gettimeofday(&t2, 0);
		__asm__ __volatile__ ("rdtsc" : "=a"(cstop.lh.low), "=d"(cstop.lh.high));
		__asm__ __volatile__ ("cpuid" : : "a" (0) : "bx", "cx", "dx" );
		return 1.e6*(t2.tv_sec-t1.tv_sec)+(t2.tv_usec-t1.tv_usec);
	}
	unsigned long long cycles(){
		return cstop.cs-cstart.cs;
	}
private:
	using counter_t=union{
		unsigned long long cs;
		struct {
			unsigned low;
			unsigned high;
		} lh;
	};
	timeval t1,t2;
	counter_t cstart, cstop;
};

#endif
