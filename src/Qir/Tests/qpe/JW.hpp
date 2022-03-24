#ifndef JW_HPP
#define JW_HPP

#include <vector>
#include <tuple>
#include <cstdint>

//using namespace std;

// pub struct HTerm(Vec<i64>, Vec<f64>);
struct HTerm
{
    std::vector<int64_t> termIdxs;
    std::vector<double>  coeffs  ;
};

// pub struct JWOptimizedHTerms(pub Vec<HTerm>, pub Vec<HTerm>, pub Vec<HTerm>, pub Vec<HTerm>);
struct JWOptimizedHTerms
{
    std::vector<HTerm> zTerms        ;
    std::vector<HTerm> zzTerms       ;
    std::vector<HTerm> pqAndPqqrTerms;
    std::vector<HTerm> h0123Terms    ;
};

// pub struct JWInputState(pub (f64, f64), pub Vec<i64>);
struct JWInputState 
{
    std::tuple<double, double>   cmplxStateCoeffs{0.0, 0.0};  // (realStateCoeffs, imagStateCoeffs)
    std::vector<int64_t>         ints;
};

// pub struct JWInputStates(pub u64, pub Vec<JWInputState>);
struct JWInputStates
{
    //uint64_t                stateType   = 0;
    int64_t                      stateType   = 0;
    std::vector<JWInputState>    stateTerms  ;
};

 
// pub struct JWData(pub i64, pub JWOptimizedHTerms, pub JWInputStates, pub f64);
struct JWData
{
    int64_t             nQubits         = 0;
    JWOptimizedHTerms   terms           ;
    JWInputStates       inputStates     ;
    double              energyOffset    = 0.0;
};

#endif // #ifndef JW_HPP
