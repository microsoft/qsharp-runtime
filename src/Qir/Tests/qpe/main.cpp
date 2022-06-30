#include <iostream>
#include <fstream>
#include <memory>   // unique_ptr

#pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wfloat-equal"
    #include "nlohmann/json.hpp"
#pragma clang diagnostic pop

#include "QirUtils.hpp"         // Array
#include "QirRuntimeApi_I.hpp"  // IRuntimeDriver
#include "SimFactory.hpp"       // CreateFullstateSimulator()
#include "QirContext.hpp"       // QirExecutionContext::Scoped
#include "JW.hpp"
#include "JW_json.hpp"
#include "JW_QIR.hpp"

using json = nlohmann::json;

using namespace std;

// define internal double @Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__body   (i64 %nQubits, i64 %nZTerms, %Array      * %zTermIdxs, %Array      * %zCoeffs, i64 %nZzTerms, %Array      * %zzTermIdxs, %Array      * %zzCoeffs, i64 %nPqAndPqqrTerms, %Array      * %pqAndPqqrTermIdxs, %Array      * %pqAndPqqrCoeffs, i64 %nH0123Terms, %Array      * %h0123TermIdxs, %Array      * %h0123Coeffs, i64 %stateType, %Array      * %realStateCoeffs, %Array      * %imagStateCoeffs, %Array      * %nStateTermIdxs, %Array      * %stateTermIdxs, double %energyOffset, i64 %nBitsPrecision, double %trotterStepSize, i64 %trotterOrder) {    
// define          double @Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__Interop(i64 %nQubits, i64 %nZTerms, { i64, i8* }* %zTermIdxs, { i64, i8* }* %zCoeffs, i64 %nZzTerms, { i64, i8* }* %zzTermIdxs, { i64, i8* }* %zzCoeffs, i64 %nPqAndPqqrTerms, { i64, i8* }* %pqAndPqqrTermIdxs, { i64, i8* }* %pqAndPqqrCoeffs, i64 %nH0123Terms, { i64, i8* }* %h0123TermIdxs, { i64, i8* }* %h0123Coeffs, i64 %stateType, { i64, i8* }* %realStateCoeffs, { i64, i8* }* %imagStateCoeffs, { i64, i8* }* %nStateTermIdxs, { i64, i8* }* %stateTermIdxs, double %energyOffset, i64 %nBitsPrecision, double %trotterStepSize, i64 %trotterOrder) #1 {

// @Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__Interop() is of interest.

// define double @Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__Interop(i64 %nQubits, i64 %nZTerms, { i64, i8* }* %zTermIdxs, { i64, i8* }* %zCoeffs, i64 %nZzTerms, { i64, i8* }* %zzTermIdxs, { i64, i8* }* %zzCoeffs, i64 %nPqAndPqqrTerms, { i64, i8* }* %pqAndPqqrTermIdxs, { i64, i8* }* %pqAndPqqrCoeffs, i64 %nH0123Terms, { i64, i8* }* %h0123TermIdxs, { i64, i8* }* %h0123Coeffs, i64 %stateType, { i64, i8* }* %realStateCoeffs, { i64, i8* }* %imagStateCoeffs, { i64, i8* }* %nStateTermIdxs, { i64, i8* }* %stateTermIdxs, double %energyOffset, i64 %nBitsPrecision, double %trotterStepSize, i64 %trotterOrder) #1 {
extern "C" double Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__Interop( // NOLINT
    int64_t nQubits, 
    
    int64_t nZTerms, 
    const Array* zTermIdxs, 
    const Array* zCoeffs, 
    
    int64_t nZzTerms, 
    const Array* zzTermIdxs, 
    const Array* zzCoeffs, 
    
    //int64_t nPqAndPqqrTerms, 
    const Array* nPqAndPqqrTerms,

    const Array* pqAndPqqrTermIdxs, 
    const Array* pqAndPqqrCoeffs, 

    int64_t nH0123Terms, 
    const Array* h0123TermIdxs, 
    const Array* h0123Coeffs, 
    
    int64_t stateType, 
    const Array* realStateCoeffs, 
    const Array* imagStateCoeffs, 
    const Array* nStateTermIdxs, 
    const Array* stateTermIdxs, 
    
    double energyOffset, 
    int64_t nBitsPrecision, 
    double trotterStepSize, 
    int64_t trotterOrder);

void printHterm(const std::vector<HTerm>& terms, const char * name);

void printHterm(const std::vector<HTerm>& terms, const char * name)
{
    cout << name << ":" << endl;
    cout << "size: " << terms.size() << endl;
    cout << "{" << endl;
    for(const HTerm& term : terms)
    {
        cout << "  termIdxs: { ";
        for(int64_t termIdx: term.termIdxs)
        {
            cout << termIdx << ", ";
        }
        cout << "}, coeffs: { ";
        for(double coeff: term.coeffs)
        {
            cout << coeff << ", ";
        }
        cout << "}" << endl;
    }
    cout << "}" << endl;
}

int main(int argc, const char * argv[])
{
    if(argc < 2)
    {
        std::cout << "Input file is missing" << std::endl;
        return 1;
    }

    // Open a file
    std::ifstream inFileStream(argv[1]);
    if (! inFileStream.is_open()) {
        std::cout << "Failed to open file \"" << argv[1] <<"\" for input" << std::endl;
        return 1;
    }

    json j;
    inFileStream >> j;

    inFileStream.close();
    
    const JWData jwData = j.get<JWData>();      // JW_json.hpp

    //std::cout << std::setw(4) << j << std::endl;
    cout << jwData.nQubits << " " << jwData.energyOffset << endl;

    // // Flatten data for the QIR entry point.
    // var (nQubits, terms, inputState, energyOffset) = jwData;
    const auto& [nQubits, terms, inputState, energyOffset] = jwData;
    // var (zTerms, zzTerms, pqAndPqqrTerms, h0123Terms) = terms;
    const auto& [zTerms, zzTerms, pqAndPqqrTerms, h0123Terms] = terms;
    //printHterm(zzTerms, "zzTerms");
    // printHterm(pqAndPqqrTerms, "pqAndPqqrTerms");

    // var (zTermIdxs, zCoeffs) = FlattenTerms(zTerms);
    const auto& [zTermIdxs, zCoeffs] = FlattenTerms(zTerms);
    // var (zzTermIdxs, zzCoeffs) = FlattenTerms(zzTerms);
    const auto& [zzTermIdxs, zzCoeffs] = FlattenTerms(zzTerms);
    // var (pqAndPqqrTermIdxs, pqAndPqqrCoeffs) = FlattenTerms(pqAndPqqrTerms);
    const auto& [pqAndPqqrTermIdxs, pqAndPqqrCoeffs] = FlattenTerms(pqAndPqqrTerms);
    // var (h0123TermIdxs, h0123Coeffs) = FlattenTerms(h0123Terms);
    const auto& [h0123TermIdxs, h0123Coeffs] = FlattenTerms(h0123Terms);

    // var (stateType, stateTerms) = inputState;
    const auto& [stateType, stateTerms] = inputState;
    // var realStateCoeffs = new QArray<double>(stateTerms.Select(t => t.Item1.Item1));
    Array realStateCoeffs {(int64_t)(stateTerms.size()), 
                           new double[stateTerms.size()]}; // If throws then we fail fast.
    // {
        // double* copyToDoubleIter = (double*)(realStateCoeffs.buffer);
        // for_each(stateTerms.begin(), stateTerms.end(), 
        //         [&copyToDoubleIter](JWInputState state) 
        //         { 
        //             *copyToDoubleIter = std::get<0>(state.cmplxStateCoeffs);     // Copy real part.
        //             ++copyToDoubleIter; 
        //         });
        transform(stateTerms.begin(), stateTerms.end(), (double*)(realStateCoeffs.buffer), //copyToDoubleIter, 
                  [](const JWInputState& state) -> double { return std::get<0>(state.cmplxStateCoeffs); } );    // Copy real part.

    // }
    // var imagStateCoeffs = new QArray<double>(stateTerms.Select(t => t.Item1.Item2));
    Array imagStateCoeffs {(int64_t)(stateTerms.size()), new double[stateTerms.size()]};
    // {
        // double* copyToDoubleIter = (double*)(imagStateCoeffs.buffer);
        // for_each(stateTerms.begin(), stateTerms.end(), 
        //         [&copyToDoubleIter](JWInputState state) 
        //         { 
        //             *copyToDoubleIter = std::get<1>(state.cmplxStateCoeffs);     // Copy imag part.
        //             ++copyToDoubleIter; 
        //         });
        transform(stateTerms.begin(), stateTerms.end(), (double*)(imagStateCoeffs.buffer), // copyToDoubleIter, 
                  [](const JWInputState& state) -> double { return std::get<1>(state.cmplxStateCoeffs); } );    // Copy imag part.
    // }

    // var (nStateTermIdxs, stateTermIdxs) = FlattenJagged(stateTerms.Select(t => t.Item2.ToArray()).ToArray());
    // (IQArray<long>, IQArray<T>) FlattenJagged<T>(T[][] xs) =>
    //     (
    //         new QArray<long>(xs.Select(inner => (long)inner.Length)),
    //         FlattenArray(xs)
    //     );
    Array nStateTermIdxs {(int64_t)(stateTerms.size()), new int64_t[stateTerms.size()]};
    int64_t overallItemCount = 0;
    // {
        // int64_t* copyToI64Iter = (int64_t*)(nStateTermIdxs.buffer);
        // for_each(stateTerms.begin(), stateTerms.end(), 
        //         [&copyToI64Iter](JWInputState state) 
        //         { 
        //             *copyToI64Iter = state.ints.size();
        //             ++copyToI64Iter; 
        //         });
        transform(stateTerms.begin(), stateTerms.end(), (int64_t*)(nStateTermIdxs.buffer), // copyToI64Iter, 
                  [&overallItemCount](const JWInputState& state) -> int64_t 
                  {
                      overallItemCount += state.ints.size();
                      return (int64_t)(state.ints.size());
                  } );
    // }
    //const int64_t overallItemCount = OverallItemCount(stateTerms);
    Array stateTermIdxs { overallItemCount, new int64_t[(size_t)overallItemCount] };
    {
        int64_t* copyToI64Iter = (int64_t*)(stateTermIdxs.buffer);
        for_each(stateTerms.begin(), stateTerms.end(), 
                 [&copyToI64Iter](const JWInputState& state)
                 {
                     copyToI64Iter = copy(state.ints.begin(), state.ints.end(), copyToI64Iter);
                 });
    }


    const Array zTermIdxsArg = FlattenArray(zTermIdxs);
    const Array zCoeffsArg   = FlattenArray(zCoeffs);
    const Array zzTermIdxsArg = FlattenArray(zzTermIdxs);
    const Array zzCoeffsArg = FlattenArray(zzCoeffs);
    
    Array nPqAndPqqrTermsArg { (int64_t)(pqAndPqqrTermIdxs.size()), new int64_t[pqAndPqqrTermIdxs.size()] };
    transform(pqAndPqqrTermIdxs.begin(), pqAndPqqrTermIdxs.end(), 
              (int64_t*)(nPqAndPqqrTermsArg.buffer),
              [](const vector<int64_t>& termIdxs) -> int64_t 
              {
                  return (int64_t)(termIdxs.size());
              } );
    // const Array pqAndPqqrTermIdxsArg = FlattenArray(pqAndPqqrTermIdxs);
    const Array pqAndPqqrTermIdxsArg = FlattenArrayI64(pqAndPqqrTermIdxs);

    const Array pqAndPqqrCoeffsArg = FlattenArray(pqAndPqqrCoeffs);
    const Array h0123TermIdxsArg = FlattenArray(h0123TermIdxs);
    const Array h0123CoeffsArg = FlattenArray(h0123Coeffs);

    // Initialize simulator.
    unique_ptr<Microsoft::Quantum::IRuntimeDriver> sim = Microsoft::Quantum::CreateFullstateSimulator();
    Microsoft::Quantum::QirExecutionContext::Scoped qirctx(sim.get(), true /*trackAllocatedObjects*/);

    // var result = await EstimateEnergyFromFlattenedJWData.Run(sim,
    auto result = Microsoft__PnnlCollaboration__EstimateEnergyFromFlattenedJWData__Interop(
    //     nQubits: nQubits,                                        int64_t nQubits,          
        nQubits,
                                                                                              
    //     nZTerms: zTerms.Count,                                   int64_t nZTerms,          
        (int64_t)(zTerms.size()),
    //     zTermIdxs: FlattenArray(zTermIdxs),                      const Array* zTermIdxs,         
        &zTermIdxsArg,
    //     zCoeffs: FlattenArray(zCoeffs),                          const Array* zCoeffs,           
        &zCoeffsArg,
                                                                                              
    //     nZzTerms: zzTerms.Count,                                 int64_t nZzTerms,         
        (int64_t)(zzTerms.size()),
    //     zzTermIdxs: FlattenArray(zzTermIdxs),                    const Array* zzTermIdxs,        
        &zzTermIdxsArg,
    //     zzCoeffs: FlattenArray(zzCoeffs),                        const Array* zzCoeffs,          
        &zzCoeffsArg,
                                                                                              
    //     nPqAndPqqrTerms: pqAndPqqrTerms.Count,                   int64_t nPqAndPqqrTerms,  
        //(int64_t)(pqAndPqqrTerms.size()),
    //                                                              const Array* nPqAndPqqrTerms,
        &nPqAndPqqrTermsArg,

    //     pqAndPqqrTermIdxs: FlattenArray(pqAndPqqrTermIdxs),      const Array* pqAndPqqrTermIdxs, 
        &pqAndPqqrTermIdxsArg,
    //     pqAndPqqrCoeffs: FlattenArray(pqAndPqqrCoeffs),          const Array* pqAndPqqrCoeffs,   
        &pqAndPqqrCoeffsArg,
                                                                                              
    //     nH0123Terms: h0123Terms.Count,                           int64_t nH0123Terms,      
        (int64_t)(h0123Terms.size()),
    //     h0123TermIdxs: FlattenArray(h0123TermIdxs),              const Array* h0123TermIdxs,     
        &h0123TermIdxsArg,
    //     h0123Coeffs: FlattenArray(h0123Coeffs),                  const Array* h0123Coeffs,       
        &h0123CoeffsArg,
                                                                                              
    //     stateType: stateType,                                    int64_t stateType,        
        stateType,
    //     realStateCoeffs: realStateCoeffs,                        const Array* realStateCoeffs,   
        &realStateCoeffs,
    //     imagStateCoeffs: imagStateCoeffs,                        const Array* imagStateCoeffs,   
        &imagStateCoeffs,
    //     nStateTermIdxs: nStateTermIdxs,                          const Array* nStateTermIdxs,    
        &nStateTermIdxs,
    //     stateTermIdxs: stateTermIdxs,                            const Array* stateTermIdxs,     
        &stateTermIdxs,
                                                                                              
    //     energyOffset: energyOffset,                              double energyOffset,      
        energyOffset,
    //     nBitsPrecision: 10,                                      int64_t nBitsPrecision,   
        11,
    //     trotterStepSize: 1.0,                                    double trotterStepSize,   
        0.1,
    //     trotterOrder: 2                                          int64_t trotterOrder);    
        1);

    // Console.WriteLine($"Result: {result}");
    cout << "Result: " << result << endl;

    return 0;
}
