#include <tuple>
#include <vector>
#include "JW_QIR.hpp"
#include "JW.hpp"

struct QirArray;

using namespace std;

// (long[][], double[][]) FlattenTerms(IEnumerable<HTerm> terms) =>
//     (
//         terms.Select(term => term.Item1.ToArray()).ToArray(),
//         terms.Select(term => term.Item2.ToArray()).ToArray()
//     );
tuple<vector<vector<int64_t> >, vector<vector<double> > > FlattenTerms(const vector<HTerm>& terms)
{
    vector<vector<int64_t> > idxs;
    vector<vector<double > > coeffs;
    for(const auto& item : terms)
    {
        idxs.emplace_back(item.termIdxs);   // TODO: std::transform
        coeffs.emplace_back(item.coeffs);
    }
    return make_tuple(idxs, coeffs);
}

const Array FlattenArrayI64(const std::vector<std::vector<int64_t>>& xs)
{
    // Allocate the return value:
    const int64_t overallItemCount =  OverallItemCount(xs);
    Array retVal { overallItemCount,
                   new int64_t[(size_t)overallItemCount]};    // Includes the possible alignment padding between the elements.
                                                // In case of `bad_alloc` thrown we fail fast.
    // Copy the values to the return value buffer:
    int64_t* copyToIter = (int64_t*)(retVal.buffer);
    for(const auto& innerVec: xs)       // Iterate through the elements of xs.  TODO: `std::for_each`.
    {
        copyToIter = std::copy(innerVec.begin(), innerVec.end(), copyToIter);
            // Steps over the possible alignment padding between the elements.
    }

    return retVal;
}


// IQArray<T> FlattenArray<T>(T[][] xs) =>
//     new QArray<T>(xs.Aggregate(
//         Array.Empty<T>(),
//         (acc, inner) => acc.Concat(inner).ToArray()
//     ));

// template<typename T>
// const QirArray* FlattenArray(const std::vector<std::vector<T>> & xs)
// {
//     QirArray* retVal = __quantum__rt__array_create_1d(sizeof(T), 0);

//     for(const auto& innerVec: xs)
//     {
//         QirArray* innerQirArr = __quantum__rt__array_create_1d(sizeof(T), innerVec.size());
//         for(size_t idx = 0; i < innerVec.size(); ++i)
//         {
//             *(T *)__quantum__rt__array_get_element_ptr_1d(innerQirArr, i) = innerVec[i];
//         }
//         retVal = __quantum__rt__array_concatenate(retVal, innerQirArr);
//         __quantum__rt__array_update_reference_count(innerQirArr, -1);
//     }

//     return retVal;

//     // new QArray<T>(xs.Aggregate(
//     //     Array.Empty<T>(),
//     //     (acc, inner) => acc.Concat(inner).ToArray()
//     // ));
// }
