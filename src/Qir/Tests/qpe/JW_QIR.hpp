#ifndef JW_QIR_HPP
#define JW_QIR_HPP

#include <tuple>
#include <vector>
#include "JW.hpp"
#include "QirUtils.hpp"     // Array

std::tuple<std::vector<std::vector<int64_t> >, 
           std::vector<std::vector<double > > 
          > 
FlattenTerms(const std::vector<HTerm>& terms);

template<typename T>
const Array FlattenArray(const std::vector<std::vector<T>>& xs);

// template<typename T>
// const QirArray1DWrapper<T> FlattenArray(const std::vector<std::vector<T>>& xs);


//-------------------------------------------
// int64_t OverallItemCount(const vector<JWInputState>& xs)
// {
//     int64_t retVal = 0;
//     for_each(xs.begin(), xs.end(), [&retVal](const JWInputState& state){ retVal += state.ints.size(); } );
//     return retVal;
// }

template<typename T>
static int64_t OverallItemCount(const std::vector<std::vector<T>>& xs)
{
    int64_t retVal = 0;
    for(const auto& innerVec: xs)       // Iterate through the elements of xs. TODO: `std::for_each`.
    {
        retVal += innerVec.size();
    }
    return retVal;
}

template<typename T>
const Array FlattenArray(const std::vector<std::vector<T>>& xs)
{
    // Allocate the return value:
    const int64_t overallItemCount =  OverallItemCount(xs);
    Array retVal { overallItemCount,
                   new T[(size_t)overallItemCount]};    // Includes the possible alignment padding between the elements.
                                                // In case of `bad_alloc` thrown we fail fast.
    // Copy the values to the return value buffer:
    T* copyToIter = (T*)(retVal.buffer);
    for(const auto& innerVec: xs)       // Iterate through the elements of xs.  TODO: `std::for_each`.
    {
        copyToIter = std::copy(innerVec.begin(), innerVec.end(), copyToIter);
            // Steps over the possible alignment padding between the elements.
    }

    return retVal;
}

const Array FlattenArrayI64(const std::vector<std::vector<int64_t>>& xs);


// template<typename T>
// const QirArray1DWrapper<T> FlattenArray(const std::vector<std::vector<T>>& xs)
// {
//     QirArray1DWrapper<T> retVal{0};

//     for(const auto& innerVec: xs)       // Iterate through the elements of xs.
//     {
//         // Convert innerVec to QirArray1DWrapper<T>:
//         QirArray1DWrapper<T> innerQirArr{innerVec.size()};
//         for(size_t idx = 0; i < innerVec.size(); ++i)
//         {
//             innerQirArr[i] = innerVec[i];
//         }

//         // Concat innerVec data to retVal:
//         retVal.concat(innerQirArr);
//     }

//     return retVal;
// }

#endif
