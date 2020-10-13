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
#include <list>
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

///
/// When a gate is invoked, we might not apply it immediately but save all its pertinent information into an immutable
/// cache so we can apply the gate later.
///
struct DeferredGate
{
    const std::vector<logical_qubit_id> controls_;
    const logical_qubit_id target_;
    const TinyMatrix<ComplexType, 2> mat_;

  public:
    DeferredGate(
        const std::vector<logical_qubit_id>& controls,
        logical_qubit_id target,
        const TinyMatrix<ComplexType, 2>& mat)
        : controls_(controls)
        , target_(target)
        , mat_(mat)
    {
    }
    DeferredGate(DeferredGate&& other)
        : controls_(std::move(other.controls_))
        , target_(other.target_)
        , mat_(std::move(other.mat_))
    {
    }
    DeferredGate(const DeferredGate& other)
        : controls_(other.controls_)
        , target_(other.target_)
        , mat_(other.mat_)
    {
    }
};

///
/// Logic for discovering clusters of gates that can be scheduled to be flushed together.
///
class Cluster
{
    std::vector<logical_qubit_id> qids_;
    std::vector<DeferredGate> gates_;

  public:
    Cluster(std::vector<logical_qubit_id>&& qids, std::vector<DeferredGate>&& gates)
        : qids_(std::move(qids))
        , gates_(std::move(gates))
    {
    }
    Cluster(Cluster&& other)
        : qids_(std::move(other.qids_))
        , gates_(std::move(other.gates_))
    {
    }

    // Clusters can potentially be quite big, so we don't want to copy them around gratuitously. (We probably don't want
    // to copy them around at all, but fixing that would require more understanding of the clustering algorithm than I
    // have right now.) Thus, we'll keep the copy operator but at least prohibit copy assignment.
    Cluster(const Cluster& other)
        : qids_(other.qids_)
        , gates_(other.gates_)
    {
    }
    Cluster& operator=(const Cluster&) = delete;

    const std::vector<logical_qubit_id>& get_qids() const
    {
        return qids_;
    }
    const std::vector<DeferredGate>& get_gates() const
    {
        return gates_;
    }

    void set_qids(const std::vector<logical_qubit_id>& qids)
    {
        qids_ = qids;
    }

    void append_gates(const std::vector<DeferredGate>& gates)
    {
        for (const DeferredGate& gate : gates)
        {
            gates_.emplace_back(gate);
        }
    }

    void set_from_other(const Cluster& other)
    {
        gates_.clear();
        set_qids(other.get_qids());
        append_gates(other.get_gates());
    }

    size_t size()
    {
        return gates_.size();
    }

    // Greedy method that finds next appropriate cluster
    // TODO: it would be nice to provide a comment, outlining the algorithm...
    std::pair<Cluster, std::vector<logical_qubit_id>> next_cluster(std::list<Cluster>& nextClusters, unsigned maxWidth)
    {
        std::vector<logical_qubit_id> myUnion;                            // My qubits touched + Next qubits touched
        std::vector<logical_qubit_id> myDiff;                             // New qubits touched by Next
        std::vector<logical_qubit_id> myInter;                            // Old qubits touched by Next
        std::vector<logical_qubit_id> allInter;                           // My qubits + All touched qubits
        std::set<logical_qubit_id> myTouched(qids_.begin(), qids_.end()); // My qubits touched
        std::set<logical_qubit_id> allTouched = myTouched;                // All the qubits touched so far

        for (auto it = nextClusters.rbegin(); it != nextClusters.rend(); ++it)
        {                                            // Look at the clusters that follow us
            auto nextQs = it->get_qids();            // Pull off one future cluster
            std::sort(nextQs.begin(), nextQs.end()); // Has to be sorted for set operations
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
                    auto ret = std::make_pair(std::move(*it), myUnion);
                    nextClusters.erase(--(it.base())); // base of reverse iterator points at the next item
                    return ret;
                }
            }
            myInter.clear();
            std::set_intersection(
                nextQs.begin(), nextQs.end(), // If a future cluster touches any of our qubits... we've hit a hard wall
                myTouched.begin(), myTouched.end(), std::back_inserter(myInter));
            if (myInter.size() != 0) break;

            allTouched.insert(nextQs.begin(), nextQs.end()); // Add in all qubits touched, and try the next cluster
        }

        // Couldn't find any more clusters to add
        return std::make_pair(Cluster({}, {}), std::vector<logical_qubit_id>{});
    }

    /// Method that identifies clusters that can be flushed together.
    // TODO: it would be nice to provide description of the clustering algorithm here...
    static std::list<Cluster> make_clusters(unsigned fuseSpan, int maxFuseDepth, const std::vector<DeferredGate>& gates)
    {
        std::list<Cluster> curClusters;

        if (gates.size() > 0)
        {
            // creating initial cluster containing one gate each
            for (const DeferredGate& gate : gates)
            {
                std::vector<logical_qubit_id> qids = gate.controls_;
                qids.push_back(gate.target_);
                curClusters.emplace_back(std::move(qids), std::vector<DeferredGate>{gate});
            }
            // creating clusters using greedy algorithm
            for (int i = 1; i < (int)fuseSpan + 1; i++)
            {
                // Build clusters of width 1,2,...
                // Reverse the current clusters for processing
                std::list<Cluster> prevClusters;
                for (auto it = curClusters.rbegin(); it != curClusters.rend(); ++it)
                {
                    prevClusters.emplace_back(std::move(*it));
                }
                curClusters.clear();

                Cluster prevCluster = std::move(prevClusters.back());
                prevClusters.pop_back();

                while (prevClusters.size() > 0)
                { // While there are more clusters...
                    // See if we can accumlate anyone who follows
                    auto foundCompat = prevCluster.next_cluster(prevClusters, i);
                    const Cluster& clusterFound = foundCompat.first;

                    if (clusterFound.get_gates().size() == 0 || // Can't append any more clusters to this one
                        (int)prevCluster.size() >= maxFuseDepth)
                    {                                       // ... or we're beyond max depth
                        curClusters.push_back(prevCluster); // Save this cluster
                        if (prevCluster.size() > 0)
                        {
                            prevCluster.set_from_other(prevClusters.back());
                            prevClusters.pop_back();
                        }
                    }
                    else
                    {
                        prevCluster.set_qids(foundCompat.second); // New version of our cluster (appended)
                        prevCluster.append_gates(clusterFound.get_gates());
                    }
                }                                   // Keep looking for clusters to add
                curClusters.push_back(prevCluster); // Save the final cluster
            }                                       // Start all over with the next larger span
        }

        return curClusters;
    }
};

///
/// Wave function represents the state of a n-qubit system.
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
    mutable std::vector<DeferredGate> pending_gates_;

    Fused fused_;

    using RngEngine = std::mt19937;
    RngEngine rng_;

#ifndef NDEBUG
    QubitAllocationPattern usage_ = QubitAllocationPattern::any;
#endif

  public:
    using value_type = T;

    /// Allocate a wave function for a 0-qubit system.
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

        // What about pending_gates_?
    }

    ~Wavefunction()
    {
        // Why is it necessary to flush in the destructor? Who will be able to observe the effect?
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
        std::list<Cluster> clusters = Cluster::make_clusters(fused_.maxSpan(), fused_.maxDepth(), pending_gates_);

        if (clusters.size() == 0)
        {
            fused_.flush(wfn_);
        }
        else
        {
            // flush gates in each cluster
            for (const Cluster& cl : clusters)
            {
                for (const DeferredGate& gate : cl.get_gates())
                {
                    if (gate.controls_.size() == 0)
                    {
                        fused_.apply(wfn_, gate.mat_, get_qubit_position(gate.target_));
                    }
                    else
                    {
                        fused_.apply_controlled(
                            wfn_, gate.mat_, get_qubit_positions(gate.controls_), get_qubit_position(gate.target_));
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
            positional_qubit_id num = static_cast<unsigned>(it - qubitmap_.begin());
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

    /// Release the specified qubit.
    /// \pre The qubit has to be in a classical state in the computational basis.
    void release(logical_qubit_id q)
    {
        positional_qubit_id p = qubitmap_[q];
        flush();
        kernels::collapse(wfn_, p, getvalue(q), true);

        qubitmap_[q] = invalid_qubit_position();
        for (int i = 0; i < qubitmap_.size(); ++i)
        {
            if (qubitmap_[i] > p && qubitmap_[i] != invalid_qubit_position()) qubitmap_[i]--;
        }
        --num_qubits_;
    }

    /// The number of currently allocated qubits.
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

    /// Checks whether the qubit is in classical state.
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

    /// Generic application of an uncontrolled gate.
    template <class Gate>
    void apply(Gate const& g)
    {
        pending_gates_.emplace_back(std::vector<logical_qubit_id>{}, g.qubit(), g.matrix());
        if (pending_gates_.size() > MAX_PENDING_GATES)
        {
            flush();
        }

        fused_.shouldFlush(wfn_, std::vector<logical_qubit_id>{}, g.qubit());
    }

    /// Generic application of a multiply-controlled gate.
    template <class Gate>
    void apply_controlled(const std::vector<logical_qubit_id>& cs, Gate const& g)
    {
        pending_gates_.emplace_back(cs, g.qubit(), g.matrix());
        if (pending_gates_.size() > MAX_PENDING_GATES)
        {
            flush();
        }

        fused_.shouldFlush(wfn_, cs, g.qubit());
    }

    /// Generic application of a gate with a single control.
    template <class Gate>
    void apply_controlled(logical_qubit_id c, Gate const& g)
    {
        apply_controlled(std::vector<logical_qubit_id>{c}, g);
    }

    /// Unoptimized application of a doubly-controlled gate.
    template <class Gate>
    void apply_controlled(logical_qubit_id c1, logical_qubit_id c2, Gate const& g)
    {
        apply_controlled({c1, c2}, g);
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

        auto num_states = wfn_.size();
        auto psi_new = WavefunctionStorage(num_states);

        auto real_qs = get_qubit_positions(qs);
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
