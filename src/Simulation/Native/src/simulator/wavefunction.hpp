// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cassert>
#include <complex>
#include <ctime>
#include <fstream>
#include <iostream>
#include <iterator>
#include <limits>
#include <random>
#include <string.h>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "gates.hpp"
#include "types.hpp"

#include "external/fused.hpp"

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{
namespace detail
{
inline std::size_t get_register(const std::vector<positional_qubit_id>& qs, std::size_t basis_state)
{
    std::size_t result = 0;
    for (unsigned i = 0; i < qs.size(); ++i)
        result |= ((basis_state >> qs[i]) & 1) << i;
    return result;
}

inline std::size_t set_register(
    const std::vector<positional_qubit_id>& qs,
    std::size_t qmask,
    std::size_t basis_state,
    std::size_t original = 0ull)
{
    std::size_t result = original & ~qmask;
    for (unsigned i = 0; i < qs.size(); ++i)
        result |= ((basis_state >> i) & 1) << qs[i];
    return result;
}
} // namespace detail

// Creating a gate wrapper datatype to represent a gate in a cluster
class GateWrapper
{
  public:
    GateWrapper(std::vector<logical_qubit_id> controls, logical_qubit_id target, TinyMatrix<ComplexType, 2> mat)
        : controls_(controls)
        , target_(target)
        , mat_(mat)
    {
    }
    std::vector<logical_qubit_id> get_controls()
    {
        return controls_;
    }
    logical_qubit_id get_target()
    {
        return target_;
    }
    TinyMatrix<ComplexType, 2> get_mat()
    {
        return mat_;
    }

  private:
    std::vector<logical_qubit_id> controls_;
    logical_qubit_id target_;
    TinyMatrix<ComplexType, 2> mat_;
};

// Creating a cluster datatype for new scheduling logic
class Cluster
{
  public:
    Cluster(std::vector<logical_qubit_id> qids, std::vector<GateWrapper> gates)
        : qids_(qids)
        , gates_(gates)
    {
    }
    std::vector<logical_qubit_id> get_qids()
    {
        return qids_;
    }
    std::vector<GateWrapper> get_gates()
    {
        return gates_;
    }

    void setQids(std::vector<logical_qubit_id> qids)
    {
        qids_ = qids;
    }

    void append_gates(std::vector<GateWrapper> gates)
    {
        gates_.insert(gates_.end(), gates.begin(), gates.end());
    }

    size_t size()
    {
        return gates_.size();
    }

    // Greedy method that finds next appropriate cluster
    std::pair<Cluster, std::vector<logical_qubit_id>> next_cluster(
        std::vector<Cluster>& nextClusters,
        unsigned maxWidth)
    {
        std::vector<logical_qubit_id> myUnion;                            // My qubits touched + Next qubits touched
        std::vector<logical_qubit_id> myDiff;                             // New qubits touched by Next
        std::vector<logical_qubit_id> myInter;                            // Old qubits touched by Next
        std::vector<logical_qubit_id> allInter;                           // My qubits + All touched qubits
        std::set<logical_qubit_id> myTouched(qids_.begin(), qids_.end()); // My qubits touched
        std::set<logical_qubit_id> allTouched = myTouched;                // All the qubits touched so far

        int lastNexts = (int)nextClusters.size() - 1; // nexts are in reverse order (from above)
        for (int i = 0; i <= lastNexts; i++)
        {                                                         // Look at the clusters that follow us
            auto nextQs = nextClusters[lastNexts - i].get_qids(); // Pull off one future cluster
            std::sort(nextQs.begin(), nextQs.end());              // Has to be sorted for set operations
            myUnion.clear();
            std::set_union(
                nextQs.begin(), nextQs.end(), // See what qubits we and the future cluster touch
                myTouched.begin(), myTouched.end(), std::back_inserter(myUnion));
            if (myUnion.size() <= maxWidth)
            { // It's a candiate if it's not beyond our allowed width
                myDiff.clear();
                std::set_difference(
                    nextQs.begin(), nextQs.end(), // Figure out if any of the future qubits aren't already seen by us
                    myTouched.begin(), myTouched.end(), std::back_inserter(myDiff));
                allInter.clear();
                std::set_intersection(
                    myDiff.begin(), myDiff.end(), // These are any new qubits that might have already been touched
                    allTouched.begin(), allTouched.end(), std::back_inserter(allInter));
                if (allInter.size() == 0)
                { // If the new qubits are untouched... then this is allowed
                    auto cl = nextClusters[lastNexts - i];
                    nextClusters.erase(nextClusters.begin() + (lastNexts - i)); // Remove the future cluster
                    return std::make_pair(cl, myUnion); // ... and add it to our cluster (done above)
                }
            }
            myInter.clear();
            std::set_intersection(
                nextQs.begin(), nextQs.end(), // If a future cluster touches any of our qubits... we've hit a hard wall
                myTouched.begin(), myTouched.end(), std::back_inserter(myInter));
            if (myInter.size() != 0) break;

            allTouched.insert(nextQs.begin(), nextQs.end()); // Add in all qubits touched, and try the next cluster
        }
        Cluster defCl = Cluster({}, {}); // Couldn't find any more clusters to add
        std::vector<logical_qubit_id> defVec = {};
        return std::make_pair(defCl, defVec);
    }

  private:
    std::vector<logical_qubit_id> qids_;
    std::vector<GateWrapper> gates_;
};

///
/// Wave function class represents the state of a n-qubit system.
///
template <class T = ComplexType>
class Wavefunction
{
#ifndef NDEBUG
    /// There are two distinct usage patterns to how qubits are allocated and they shouldn't be mixed after allocations
    /// have begun. However, we only check the pattern consistency in debug asserts.
    enum class QubitAllocationPattern : int
    {
        any = 0,           // no qubits allocated yet, so either pattern will be OK
        implicitLogicalId, // the wavefunction will assign logical qubit id as it sees fit
        explicitLogicalId, // the caller specifies the logical qubit id
    };
#endif

    /// Number of currently allocated qubits.
    unsigned num_qubits_;

    /// Represents the state of the system with num_qubits_ qubits. Might not reflect the current state if there are
    /// pending fused gates.
    mutable WavefunctionStorage wfn_;

    /// Each qubit has a client-facing id, which we call "logical qubit id" or just "logical qubit". However, the order
    /// of qubits in the internal representation of the state, that is, the positions of the qubits in the standard
    /// computational basis of the wave function, might not match their logical ids or even the order of the logical
    /// ids. `qubitmap_` stores the positional ids for all currently allocated qubits, the index into the vector is the
    /// logical id of the qubit (which means this map might grow rather large if logical qubit ids aren't reused).
    mutable std::vector<positional_qubit_id> qubitmap_;

    /// Cache of the pending gates that haven't been applied (i.e. flushed) to the wave function storage yet.
    static constexpr int MAX_PENDING_GATES = 999;
    mutable std::vector<GateWrapper> pending_gates_;

    /// TODO: add comment
    Fused fused_;

    /// TODO: add comment
    using RngEngine = std::mt19937;
    RngEngine rng_;

#ifndef NDEBUG
    QubitAllocationPattern usage_ = QubitAllocationPattern::any;
#endif

  public:
    using value_type = T;
    using RngEngine = std::mt19937;

    /// allocate a wave function for zero qubits
    Wavefunction()
        : num_qubits_(0)
        , wfn_(1, 1.)
    {
        rng_.seed(std::clock());
    }

    void reset()
    {
        fused_.reset();
        rng_.seed(std::clock());
        num_qubits_ = 0;
        wfn_.resize(1);
        wfn_[0] = 1.;
        qubitmap_.resize(0);

        // what about pending_gates_?
    }

    ~Wavefunction()
    {
        flush();
    }

    constexpr positional_qubit_id invalid_qubit_position() const
    {
        return std::numeric_limits<unsigned>::max();
    }

    positional_qubit_id get_qubit_position(logical_qubit_id q) const
    {
        assert(qubitmap_[q] != invalid_qubit_position());
        return qubitmap_[q];
    }

    positional_qubit_id get_qubit_position(Gates::OneQubitGate const& g) const
    {
        return get_qubit_position(g.qubit());
    }

    std::vector<positional_qubit_id> get_qubit_positions(std::vector<logical_qubit_id> const& qs) const
    {
        std::vector<positional_qubit_id> ps;
        for (logical_qubit_id q : qs)
            ps.push_back(get_qubit_position(q));
        return ps;
    }

    /// Returns the list of logical ids of all currently allocated qubits.
    std::vector<logical_qubit_id> get_qubit_ids() const
    {
        std::vector<logical_qubit_id> qs;
        for (unsigned i = 0; i < qubitmap_.size(); i++)
        {
            if (qubitmap_[i] != invalid_qubit_position())
            {
                qs.push_back(i);
            }
        }

        return qs;
    }

    void flush() const
    {
        int maxSpan = fused_.maxSpan();
        auto clusters = make_clusters(maxSpan, pending_gates_); // making clusters with gates in the queue

        if (clusters.size() == 0)
        {
            fused_.flush(wfn_);
        }
        else
        {
            // logic to flush gates in each cluster
            for (int i = 0; i < clusters.size(); i++)
            {
                Cluster cl = clusters.at(i);

                for (GateWrapper gate : cl.get_gates())
                {
                    std::vector<logical_qubit_id> cs = gate.get_controls();
                    if (cs.size() == 0)
                    {
                        fused_.apply(wfn_, gate.get_mat(), get_qubit_position(gate.get_target()));
                    }
                    else
                    {
                        fused_.apply_controlled(wfn_, gate.get_mat(), get_qubit_positions(cs), get_qubit_position(gate.get_target()));
                    }
                }

                fused_.flush(wfn_);
            }
        }
        pending_gates_.clear();
    }


    /// Allocate a qubit with implicitly assigned logical qubit id.
    logical_qubit_id allocate_qubit()
    {
#ifndef NDEBUG
        assert(usage_ != QubitAllocationPattern::explicitLogicalId);
        usage_ = QubitAllocationPattern::implicitLogicalId;
#endif

        flush();
        wfn_.resize(2 * wfn_.size());

        // Reuse a logical qubit id, if any is available.
        auto it = std::find(qubitmap_.begin(), qubitmap_.end(), invalid_qubit_position());
        if (it != qubitmap_.end())
        {
            logical_qubit_id num = static_cast<unsigned>(it - qubitmap_.begin());
            qubitmap_[num] = num_qubits_++;
            return num;
        }
        else
        {
            qubitmap_.push_back(num_qubits_++);
            return static_cast<unsigned>(qubitmap_.size() - 1);
        }
    }

    /// Allocate a qubit with explicitly provided logical qubit id. The caller is responsible for ensuring the id
    /// doesn't collide with other allocated qubits.
    void allocate_qubit(logical_qubit_id id)
    {
#ifndef NDEBUG
        assert(usage_ != QubitAllocationPattern::implicitLogicalId);
        usage_ = QubitAllocationPattern::explicitLogicalId;
#endif

        flush();
        wfn_.resize(2 * wfn_.size());

        if (id < qubitmap_.size())
        {
            assert(qubitmap_[id] == invalid_qubit_position());
            qubitmap_[id] = num_qubits_++;
        }
        else
        {
            assert(id == qubitmap_.size()); // we want qubitmap_ to be as small as possible
            qubitmap_.push_back(num_qubits_++);
        }
        assert((wfn_.size() >> num_qubits_) == 1);
    }

    /// release the specified qubit
    /// \pre the qubit has to be in a classical state in the computational basis
    void release(logical_qubit_id q)
    {
        positional_qubit_id p = get_qubit_position(q);
        flush();
        kernels::collapse(wfn_, p, getvalue(q), true);
        for (int i = 0; i < qubitmap_.size(); ++i)
            if (qubitmap_[i] > p && qubitmap_[i] != invalid_qubit_position()) qubitmap_[i]--;
        qubitmap_[q] = invalid_qubit_position();
        --num_qubits_;
    }

    /// the number of used qubits
    unsigned num_qubits() const
    {
        return num_qubits_;
    }

    /// probability of measuring a 1
    double probability(logical_qubit_id q) const
    {
        flush();
        return kernels::probability(wfn_, get_qubit_position(q));
    }

    /// probability of jointly measuring a 1
    double jointprobability(std::vector<logical_qubit_id> const& qs) const
    {
        flush();
        std::vector<positional_qubit_id> ps = get_qubit_positions(qs);
        return kernels::jointprobability(wfn_, ps);
    }

    /// probability of jointly measuring a 1
    double jointprobability(std::vector<Gates::Basis> const& bs, std::vector<logical_qubit_id> const& qs) const
    {
        flush();
        std::vector<positional_qubit_id> ps = get_qubit_positions(qs);
        return kernels::jointprobability(wfn_, bs, ps);
    }

    /// measure a qubit
    bool measure(logical_qubit_id q)
    {
        flush();
        std::uniform_real_distribution<double> uniform(0., 1.);
        bool result = (uniform(rng_) < probability(q));
        kernels::collapse(wfn_, get_qubit_position(q), result);
        kernels::normalize(wfn_);
        return result;
    }

    bool jointmeasure(std::vector<logical_qubit_id> const& qs)
    {
        flush();
        std::vector<positional_qubit_id> ps = get_qubit_positions(qs);
        std::uniform_real_distribution<double> uniform(0., 1.);
        bool result = (uniform(rng_) < jointprobability(qs));
        kernels::jointcollapse(wfn_, ps, result);
        kernels::normalize(wfn_);
        return result;
    }

    void apply_controlled_exp(
        std::vector<Gates::Basis> const& bs,
        double phi,
        std::vector<logical_qubit_id> const& cs,
        std::vector<logical_qubit_id> const& qs)
    {
        flush();
        kernels::apply_controlled_exp(wfn_, bs, phi, get_qubit_positions(cs), get_qubit_positions(qs));
    }

    /// checks if the qubit is in classical state
    bool isclassical(logical_qubit_id q) const
    {
        flush();
        return kernels::isclassical(wfn_, get_qubit_position(q));
    }

    /// returns the classical value of a qubit (if classical)
    /// \pre the qubit has to be in a classical state in the computational basis
    bool getvalue(logical_qubit_id q) const
    {
        flush();
        assert(isclassical(q));
        int res = kernels::getvalue(wfn_, get_qubit_position(q));
        if (res == 2) std::cout << *this;

        assert(res < 2);
        return res == 1;
    }

    /// the stored wave function as a vector
    WavefunctionStorage const& data() const
    {
        flush();
        return wfn_;
    }

    /// seed the random number engine for measurements
    void seed(unsigned s)
    {
        rng_.seed(s);
    }

    // method that makes clusters to be flushed
    std::vector<Cluster> make_clusters(unsigned fuseSpan, std::vector<GateWrapper> gates) const
    {
        std::vector<Cluster> curClusters;

        if (gates.size() > 0)
        {
            // creating initial cluster containing one gate each
            for (int i = 0; i < gates.size(); i++)
            {
                std::vector<logical_qubit_id> qids;
                std::vector<logical_qubit_id> controlQids = gates[i].get_controls();
                if (controlQids.size() > 0)
                {
                    qids = controlQids;
                }
                qids.push_back(gates[i].get_target());
                Cluster newCl = Cluster(qids, {gates[i]});
                curClusters.push_back(newCl);
            }
            // creating clusters using greedy algorithm
            for (int i = 1; i < (int)fuseSpan + 1; i++)
            {                                                         // Build clusters of width 1,2,...
                std::reverse(curClusters.begin(), curClusters.end()); // Keep everything in reverse order
                auto prevClusters = curClusters;                      // Save away the last set of clusters built
                curClusters.clear();
                auto prevCluster = prevClusters.back(); // Pop the first cluster
                prevClusters.pop_back();
                while (prevClusters.size() > 0)
                { // While there are more clusters...
                    auto foundCompat =
                        prevCluster.next_cluster(prevClusters, i); // See if we can accumlate anyone who follows
                    Cluster clusterFound = foundCompat.first;
                    std::vector<logical_qubit_id> foundTotQids = foundCompat.second;
                    if (clusterFound.get_gates().size() == 0 || // Can't append any more clusters to this one
                        (int)prevCluster.size() >= fused_.maxDepth())
                    {                                       // ... or we're beyond max depth
                        curClusters.push_back(prevCluster); // Save this cluster
                        if (prevCluster.size() > 0)
                        {
                            prevCluster = prevClusters.back();
                            prevClusters.pop_back();
                        }
                    }
                    else
                    {
                        prevCluster.setQids(foundTotQids); // New version of our cluster (appended)
                        prevCluster.append_gates(clusterFound.get_gates());
                    }
                }                                   // Keep looking for clusters to add
                curClusters.push_back(prevCluster); // Save the final cluster
            }                                       // Start all over with the next larger span
        }

        return curClusters;
    }

    /// generic application of a gate
    template <class Gate>
    void apply(Gate const& g)
    {
        std::vector<logical_qubit_id> cs;
        GateWrapper gateApplied = GateWrapper(cs, g.qubit(), g.matrix());
        pending_gates_.push_back(gateApplied);
        if (pending_gates_.size() > MAX_PENDING_GATES)
        {
            flush();
        }

        fused_.shouldFlush(wfn_, cs, g.qubit());
    }

    /// generic application of a multiply controlled gate
    template <class Gate>
    void apply_controlled(std::vector<logical_qubit_id> cs, Gate const& g)
    {
        GateWrapper gateApplied = GateWrapper(cs, g.qubit(), g.matrix());
        pending_gates_.push_back(gateApplied);
        if (pending_gates_.size() > MAX_PENDING_GATES)
        {
            flush();
        }

        fused_.shouldFlush(wfn_, cs, g.qubit());
    }

    /// generic application of a controlled gate
    template <class Gate>
    void apply_controlled(logical_qubit_id c, Gate const& g)
    {
        apply_controlled(std::vector<logical_qubit_id>{c}, g);
    }

    /// unoptimized application of a doubly controlled gate
    template <class Gate>
    void apply_controlled(logical_qubit_id c1, logical_qubit_id c2, Gate const& g)
    {
        apply_controlled(std::vector<logical_qubit_id>{c1, c2}, g);
    }

    template <class A>
    bool subsytemwavefunction(std::vector<logical_qubit_id> const& qs, std::vector<T, A>& qubitswfn, double tolerance)
    {
        flush(); // we have to flush before we can extract the state
        return kernels::subsytemwavefunction(wfn_, get_qubit_positions(qs), qubitswfn, tolerance);
    }

    // apply permutation of basis states to the wave function
    void permute_basis(
        std::vector<logical_qubit_id> const& qs,
        std::size_t table_size,
        std::size_t const* permutation_table,
        bool adjoint = false)
    {
        assert(table_size == 1ull << qs.size());
        flush();
        auto real_qs = get_qubit_positions(qs);
        auto num_states = wfn_.size();
        auto psi_new = WavefunctionStorage(num_states);
        auto qmask = kernels::make_mask(real_qs);

        auto permute = [&real_qs, qmask, table_size, permutation_table](std::size_t state) {
            auto qstate = detail::get_register(real_qs, state);
            assert(qstate < table_size);
            return detail::set_register(real_qs, qmask, permutation_table[qstate], state);
        };

        if (!adjoint)
        {
            for (size_t i = 0; i < num_states; ++i)
                psi_new[permute(i)] = wfn_[i];
        }
        else
        {
            for (size_t i = 0; i < num_states; ++i)
                psi_new[i] = wfn_[permute(i)];
        }

        std::swap(wfn_, psi_new);
    }

    RngEngine& rng()
    {
        return rng_;
    }
};

/// print information about the wave function
template <class T>
std::ostream& operator<<(std::ostream& out, Wavefunction<T> const& wfn)
{
    wfn.flush();
    out << "Wave function for " << wfn.num_qubits() << " with " << wfn.data().size() << " elements "
        << " using " << sizeof(T) * wfn.data().size() << " bytes" << std::endl;
    if (wfn.num_qubits() <= 6) std::copy(wfn.data().begin(), wfn.data().end(), std::ostream_iterator<T>(out, "\n"));
    return out;
}
} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
