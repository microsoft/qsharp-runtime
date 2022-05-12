// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cassert>
#include <complex>
#include <ctime>
#include <iostream>
#include <iterator>
#include <limits>
#include <list>
#include <random>
#include <string.h>
#include <vector>
#include <chrono>

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
/// Projects `basis_vector` onto the subsystem defined by `ps`, in the standard computational basis imposed by the order
/// in which the positions are listed (little-endian). For example, consider `basis_vector` = |174> = |10101110> in an
/// 8-qubit system. If this basis vector is projected onto a subsystem of three qubits with positions {6,3,2}
/// (|_0__11__>), the corresponding -- reordered -- basis vector would be |110> = |6>.
inline size_t get_register(const std::vector<positional_qubit_id>& ps, size_t basis_vector)
{
    size_t result = 0;
    for (size_t i = 0; i < ps.size(); ++i)
    {
        result |= ((basis_vector >> ps[i]) & 1) << i;
    }
    return result;
}

/// Lifts `basis_vector_in_ps` from the subsystem defined by `ps` into the linear subspace of the full system, defined
/// by the complimentary positions in `basis_vector_target`.
/// Implementation notes: `qmask` can be computed from `ps` but is passed in for performance reasons as most clients
/// make repeated calls to `set_register` with the same set of positions.
inline size_t set_register(
    const std::vector<positional_qubit_id>& ps,
    size_t qmask,
    size_t basis_vector_in_ps,
    size_t basis_vector_target)
{
    assert(qmask == kernels::make_mask(ps));
    assert(basis_vector_in_ps < (1ull << ps.size()));

    size_t result = basis_vector_target & ~qmask;
    for (size_t i = 0; i < ps.size(); ++i)
    {
        result |= ((basis_vector_in_ps >> i) & 1) << ps[i];
    }
    return result;
}
} // namespace detail

///
/// When a gate is invoked, we might not apply it immediately but save all its pertinent information into an immutable
/// cache so we can apply the gate later, possibly fused with other gates to improve performance.
///
class DeferredGate
{
    std::vector<logical_qubit_id> controls_;
    logical_qubit_id target_;
    TinyMatrix<ComplexType, 2> mat_;

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

    const std::vector<logical_qubit_id>& get_controls() const
    {
        return controls_;
    }
    logical_qubit_id get_target() const
    {
        return target_;
    }
    const TinyMatrix<ComplexType, 2>& get_mat() const
    {
        return mat_;
    }
};

///
/// A few utility functions for Cluster class
///
static bool is_sorted_assending(const std::vector<logical_qubit_id>& x)
{
    return std::adjacent_find(x.begin(), x.end(), std::greater<logical_qubit_id>()) == x.end();
}

static bool is_intersection_empty(const std::vector<logical_qubit_id>& x, const std::vector<logical_qubit_id>& y)
{
    assert(is_sorted_assending(x));
    assert(is_sorted_assending(y));

    std::vector<logical_qubit_id> intersection;
    std::set_intersection(x.begin(), x.end(), y.begin(), y.end(), std::back_inserter(intersection));
    return intersection.empty();
}

static bool is_intersection_empty(const std::vector<logical_qubit_id>& x, const std::set<logical_qubit_id>& y)
{
    assert(is_sorted_assending(x));

    std::vector<logical_qubit_id> intersection;
    std::set_intersection(x.begin(), x.end(), y.begin(), y.end(), std::back_inserter(intersection));
    return intersection.empty();
}

///
/// Cluster represents a group of gates that should be flushed together.
///
class Cluster
{
    /// Union of logical qubit ids for controls and targets of all gates in this cluster. For performance reasons must
    /// be sorted in assending order.
    std::vector<logical_qubit_id> qids_;

    /// Gates in this cluster. When flushing the cluster, the gates will be applied in order from left to rigth.
    std::vector<DeferredGate> gates_;

  public:
    Cluster() = default;
    Cluster(const std::vector<logical_qubit_id>& qids, const std::vector<DeferredGate>& gates)
        : qids_(qids)
        , gates_(gates)
    {
        assert(is_sorted_assending(qids));
    }
    Cluster(Cluster&& other)
        : qids_(std::move(other.qids_))
        , gates_(std::move(other.gates_))
    {
    }

    // prevent gratuitous copying of clusters (which might be quite large)
    Cluster(const Cluster&) = delete;
    Cluster& operator=(const Cluster&) = delete;

    void swap(Cluster& other)
    {
        qids_.swap(other.qids_);
        gates_.swap(other.gates_);
    }

    const std::vector<logical_qubit_id>& get_qids() const
    {
        return qids_;
    }
    const std::vector<DeferredGate>& get_gates() const
    {
        return gates_;
    }

    Cluster& append(const Cluster& other)
    {
        gates_.insert(gates_.end(), other.gates_.begin(), other.gates_.end());

        std::vector<logical_qubit_id> merged;
        std::set_union(other.qids_.begin(), other.qids_.end(), qids_.begin(), qids_.end(), std::back_inserter(merged));
        qids_.swap(merged);

        return *this;
    }

    size_t size() const
    {
        return gates_.size();
    }

    bool empty() const
    {
        return gates_.empty();
    }

    /// We say that two clusters "commute" if their sets of qubits don't intersect. The list of clusters given to this
    /// method is assumed to be in temporal order, where this cluster is implicitly the earliest. Our goal is to find a
    /// cluster that can be commuted to the front of the list and merged with this cluster without increasing its width
    /// beyond `max_cluster_width`. The algorithm picks first such cluster from the start of the list (with the least
    /// distance to commute).
    std::list<Cluster>::const_iterator find_compatible_cluster(
        const std::list<Cluster>& nextClusters,
        unsigned max_cluster_width)
    {
        // Union of all qubits in clusters that we are skipping as we are searching for the compatible one.
        std::set<logical_qubit_id> skipped_qids;

        for (auto candidate = nextClusters.begin(); candidate != nextClusters.end(); ++candidate)
        {
            const std::vector<logical_qubit_id>& candidate_qids = candidate->get_qids();

            // New qubits the candidate cluster would add into this cluster.
            std::vector<logical_qubit_id> qids_new;
            std::set_difference(
                candidate_qids.begin(), candidate_qids.end(), qids_.begin(), qids_.end(), std::back_inserter(qids_new));

            // If the new qubits from the candidate cluster don't touch any of the clusters we've skipped, the candidate
            // cluster is compatible with this one. But we also need to check that the new qubits wouldn't increase the
            // width of the cluster too much.
            if (is_intersection_empty(qids_new, skipped_qids) && (qids_.size() + qids_new.size() <= max_cluster_width))
            {
                return candidate;
            }

            // If the candidate cluster isn't compatible with this one but shares qubits, we treat it as a barrier no
            // other cluster can be pulled through (<irinayat> example #5 below shows that this might lead to more
            // final clusters than necessary -- why this condition and not checking for intersection of candidate_qids
            // with qids_skipped?).
            if (!is_intersection_empty(candidate_qids, qids_)) break;

            skipped_qids.insert(candidate_qids.begin(), candidate_qids.end());
        }

        // Found no compatible cluster.
        return nextClusters.end();
    }

    ///
    /// Group given gates into clusters that should be flushed together (in the order of the returned list). The order
    /// of elements in `gates` list represents the temporal order in which the gates were invoked.
    ///
    /// Cluster of width one can contain multiple single-qubit gates that apply to the same qubit. Cluster of width two
    /// can contain multiple single- or two-qubit gates that apply to the same two qubits, and so on. Given a list of
    /// gates in temporal order, our goal is to group them into clusters of gates that can be efficiently fused but such
    /// that applying these clusters in order would be equivalent to applying the original gates sequence. Therefore,
    /// the order of gates inside the cluster is important but it's not guaranteed to be the same as in the original
    /// gates sequence.
    ///
    /// The greedy algorithm we use doesn't necessarily produce an 'optimal' clustering (e.g. it might not find the
    /// clustering with the least number of clusters, or balance clusters in terms of gate/qubit counts, or group qubits
    /// with close positional id together). To delay creating clusters that interfere with each other, the merging is
    /// done in multiple passes that increment the number of allowed qubits per cluster until the maximum of `fuseSpan`
    /// is reached.
    ///
    /// Examples:
    ///
    /// 1. Sequence of gates: {H(q1), X(q2), Y(q2), Z(q1)}
    ///    Will be organized into clusters of width 1 as: {{q1: H(q1), Z(q1)}, {q2: X(q2), Y(q2)}}.
    /// 2. Sequence of gates: {H(q1), Z(q1), CNOT(q1, q2), X(q1)}
    ///    X(q1) gate cannot be clustered together with H and Z because that would affect execution of CNOT (these two
    ///    gates don't commute). Thus, clusters of width 1 are:
    ///    {{q1: H(q1), Z(q1)}, {q1, q2: CNOT(q1, q2)}, {q1: X(q1)}}.
    ///    Note, that single-gate clusters might excede the maximum cluster width.
    /// 3. Sequence of gates: X(q1), X(q2), CNOT(q2, q3), Y(q2), X(q3), Y(q1)
    ///    Because the algorithm grows the clusters gradually, it will be able to combine X(q1) and Y(q1) when creating
    ///    clusters of width 1, and on the second step for width 2 it will create:
    ///    {q1, q2: X(q1), Y(q1), X(q2)}, {q2, q3: CNOT(q2, q3), Y(q2), X(q3)}
    ///    Note, that running the algorithm for width = 3 doesn't change the clusters, and for width = 4 it would
    ///    combine all gates together into single sequence, but in different order than the original!
    /// 4. Sequence of gates: X(q1), X(q2), X(q3), CNOT(q1, q2), CNOT(q1, q3), Y(q1), Y(q2), Y(q3)
    ///    For width 2 clustering our algorithm gets:
    ///    {X(q1), X(q2), CNOT(q1, q2)}, {X(q3), CNOT(q1, q3), Y(q1), Y(q3)}, {Y(q2)}
    ///    and not this one: {X(q1), X(q2), CNOT(q1, q2), Y(q2)}, {X(q3), CNOT(q1, q3), Y(q1), Y(q3)} (see the comment
    ///    in `find_compatible_cluster`)
    static std::list<Cluster> make_clusters(
        unsigned fuseSpan,
        int maxFusedDepth,
        const std::vector<DeferredGate>& gates)
    {
        if (gates.empty()) return std::list<Cluster>{};

        // Create initial clusters, containing one gate each.
        std::list<Cluster> curClusters;
        for (const DeferredGate& gate : gates)
        {
            std::vector<logical_qubit_id> qids = gate.get_controls();
            qids.push_back(gate.get_target());
            std::sort(qids.begin(), qids.end());
            curClusters.emplace_back(qids, std::vector<DeferredGate>{gate});
        }

        // Run incremental left-to-right passes over the clusters, increasing the number of allowed qubits on each pass.
        std::list<Cluster> prevClusters;
        for (unsigned cluster_width = 1; cluster_width < fuseSpan + 1; cluster_width++)
        {
            assert(prevClusters.empty());
            prevClusters.swap(curClusters);

            Cluster prevCluster;
            prevCluster.swap(prevClusters.front());
            prevClusters.pop_front();

            while (!prevClusters.empty())
            {
                std::list<Cluster>::const_iterator clusterFound =
                    prevCluster.find_compatible_cluster(prevClusters, cluster_width);

                if (clusterFound == prevClusters.end() || prevCluster.size() >= maxFusedDepth)
                {
                    // Cannot extend this cluster anymore, stash it away for the next pass and try to extend the next
                    // one from the list. Doing swap/move/pop in this order allows us to avoid copying clusters.
                    prevCluster.swap(prevClusters.front());
                    curClusters.push_back(std::move(prevClusters.front()));
                    prevClusters.pop_front();
                }
                else
                {
                    // Extend this cluster and try again whether it can be extended even further while keeping its
                    // width <= cluster_width.
                    prevCluster.append(*clusterFound);
                    prevClusters.erase(clusterFound);
                }
            }

            curClusters.push_back(std::move(prevCluster)); // Save the final cluster
        }

        return curClusters;
    }
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

    /// Represents the state of the system with num_qubits_ qubits in little-endian notation (that is, the qubit
    /// with positional id = 0 corresponds to the least significant bit in the index of the standard computational
    /// basic vector of this wave function). Might not reflect the current state if there are pending fused gates.
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

    /// allocate a wave function for zero qubits
    Wavefunction()
        : num_qubits_(0)
        , wfn_(1, 1.)
    {
        rng_.seed((unsigned)std::chrono::system_clock::now().time_since_epoch().count());
    }

    void reset()
    {
        fused_.reset();
        rng_.seed((unsigned)std::chrono::system_clock::now().time_since_epoch().count());
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

    positional_qubit_id get_qubit_position(const Gates::OneQubitGate& g) const
    {
        return get_qubit_position(g.qubit());
    }

    std::vector<positional_qubit_id> get_qubit_positions(const std::vector<logical_qubit_id>& qs) const
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
        for (size_t i = 0; i < qubitmap_.size(); i++)
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

        if (clusters.empty())
        {
            fused_.flush(wfn_);
        }
        else
        {
            // logic to flush gates in each cluster
            for (const Cluster& cl : clusters)
            {
                for (const DeferredGate& gate : cl.get_gates())
                {
                    const std::vector<logical_qubit_id>& cs = gate.get_controls();
                    if (cs.size() == 0)
                    {
                        fused_.apply(wfn_, gate.get_mat(), get_qubit_position(gate.get_target()));
                    }
                    else
                    {
                        fused_.apply_controlled(
                            wfn_, gate.get_mat(), get_qubit_positions(cs), get_qubit_position(gate.get_target()));
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
        for (size_t i = 0; i < qubitmap_.size(); ++i)
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
        return kernels::jointprobability(wfn_, get_qubit_positions(qs));
    }

    /// probability of jointly measuring a 1
    double jointprobability(std::vector<Gates::Basis> const& bs, std::vector<logical_qubit_id> const& qs) const
    {
        flush();
        return kernels::jointprobability(wfn_, bs, get_qubit_positions(qs));
    }

    /// \pre: Each qubit, listed in `q`, must be unentangled and in state |0>. If the prerequisite isn't satisfied,
    /// the method returns `false` and leaves the state of the system unchanged.
    /// Place qubits, listed in `q` into superposition of basis vectors with provided `amplitudes`, where the order of
    /// qubits in array `q` defines the standard computational basis in little endian order. Returns `true` if the state
    /// is successfuly injected.
    bool inject_state(const std::vector<logical_qubit_id>& qubits, const std::vector<ComplexType>& amplitudes)
    {
        assert((static_cast<size_t>(1) << qubits.size()) == amplitudes.size());

        flush();

        if (qubits.size() == num_qubits_)
        {
            // Check prerequisites. In the case of total state injection the wave function must consist of a single
            // term |0...0> (so we can avoid checking each qubit individually).
            double eps = 100. * std::numeric_limits<double>::epsilon();
            if (std::norm(wfn_[0]) < 1.0 - eps)
            {
                return false;
            }

            // For full state injection we can copy the user's wave function into our store and reorder the
            // positions map without doing any math.
            for (size_t i = 0; i < qubits.size(); i++)
            {
                qubitmap_[qubits[i]] = i;
            }
            wfn_.assign(amplitudes.begin(), amplitudes.end());
        }
        else
        {
            // Check prerequisites.
            std::vector<positional_qubit_id> positions = get_qubit_positions(qubits);
            for (positional_qubit_id p : positions)
            {
                if (!kernels::isclassical(wfn_, p) || kernels::getvalue(wfn_, p) != 0)
                {
                    return false;
                }
            }

            // The current state can be thought of as Sum(a_i*|i>|0...0>), after the state injection it will become
            // Sum(a_i*|i>Sum(b_j*|j>)) = Sum(a_i*b_j|i>|j>). Thus, to compute amplitude of a term |k> after the state
            // injection we need to find the corresponding |i> vector from the original wave function and |j> vector
            // from the state being injected, and multiply their amplitudes. The things are complicated by the fact that
            // the state might not be injected on adjacently positioned qubits, but get/set_register takes care of that.
            const int64_t num_states = static_cast<int64_t>(wfn_.size());
            const size_t mask = kernels::make_mask(positions);
            WavefunctionStorage wfn_new(num_states);

            // For systems with more qubits (>16) the pragma yields x2-x4 performance boost in the micro benchmarks run
            // on a machine with 16 cores. For systems with fewer qubits (<10) the pragma might regress perf somewhat
            // but for small systems the overall time of state injection is negligible and might still outperform
            // quantum preparation (and might fall short of it even without the pragma), so to avoid extra complexity
            // we are not conditioning enabling the pragma on the size of the system.
#pragma omp parallel for schedule(static)
            for (int64_t basis_index = 0; basis_index < num_states; basis_index++)
            {
                const size_t injected_index = detail::get_register(positions, basis_index);
                const size_t original_term = detail::set_register(positions, mask, 0, basis_index);
                wfn_new[basis_index] = wfn_[original_term] * amplitudes[injected_index];
            }
            std::swap(wfn_, wfn_new);
        }

        return true;
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

    /// generic application of a gate
    template <class Gate>
    void apply(Gate const& g)
    {
        std::vector<logical_qubit_id> cs;
        pending_gates_.emplace_back(cs, g.qubit(), g.matrix());
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
        pending_gates_.emplace_back(cs, g.qubit(), g.matrix());
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

    /// Apply the unitary operator that permutes the standard computational basis of the subsystem, defined by the
    /// provided qubits. `qs` lists the qubits of the subsystem in little-endian order (the front qubit in the list
    /// corresponds to the last position of the standard computational basis). `table_size` must be equal 2^n, where n
    /// is the number of qubits in `qs`. `permutation_table` must point to an array of `table_size` integers that
    /// describes a permutation of set {0, 1, ... , 2^n -1}. `adjoint` specifies whether to apply the adjoint of the
    /// unitary.
    ///
    /// Implementation notes: the current positions of the provided qubits might not match the order in which they are
    /// listed, so the unitary has to be Adjoint(V)*U*V, where V permutes the _provided qubits_ to match their positions
    /// to the requested, and U does the specified permutation of the _standard computational basis_ of these qubits.
    /// Note, that the positions of the qubits in the end remain unchanged.
    void permute_basis(
        std::vector<logical_qubit_id> const& qs,
        size_t table_size,
        size_t const* permutation_table,
        bool adjoint = false)
    {
        if (qs.empty()) return;

#ifndef NDEBUG
        assert(table_size == (1ull << qs.size()));
        // permutation_table should describe a permutation of {0, 1, 2, ..., table_size - 1}
        std::set<size_t> permutations(permutation_table, permutation_table + table_size);
        assert(permutations.size() == table_size);         // no duplicates
        assert(*permutations.begin() == 0);                // min element in ordered set
        assert(*(--permutations.end()) == table_size - 1); // max element in ordered set
#endif

        flush();

        std::vector<positional_qubit_id> positions = get_qubit_positions(qs);

        const size_t num_states = wfn_.size();
        WavefunctionStorage psi_new(num_states);
        const size_t qmask = kernels::make_mask(positions);

        auto permute = [&positions, qmask, table_size, permutation_table](size_t basis_vector) {
            size_t qstate = detail::get_register(positions, basis_vector);
            return detail::set_register(positions, qmask, permutation_table[qstate], basis_vector);
        };

#ifndef NDEBUG
        std::set<size_t> permuted;
#endif
        if (!adjoint)
        {
            for (size_t i = 0; i < num_states; ++i)
            {
                const size_t target = permute(i);
                assert(permuted.insert(target).second); // should see no duplicates
                psi_new[target] = wfn_[i];
            }
        }
        else
        {
            for (size_t i = 0; i < num_states; ++i)
            {
                const size_t source = permute(i);
                assert(permuted.insert(source).second); // should see no duplicates
                psi_new[i] = wfn_[source];
            }
        }

        // check that this was, indeed, a permutation of the basis
        assert(permuted.size() == num_states);         // would follow if no duplicates encountered above
        assert(*permuted.begin() == 0);                // min element in ordered set
        assert(*(--permuted.end()) == num_states - 1); // max element in ordered set

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
