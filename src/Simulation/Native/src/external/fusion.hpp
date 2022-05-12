// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#ifndef GATE_QUEUE_HPP_
#define GATE_QUEUE_HPP_

#include <set>
#include <vector>
#include <complex>
#include <algorithm>
#include <iostream>
#include <cassert>
#include "util/alignedalloc.hpp"
#include <unordered_map>

class Item{
public:  
	using Index = unsigned;
	using IndexVector = std::vector<Index>;
	using Complex = std::complex<double>;
	using Matrix = std::vector<std::vector<Complex, Microsoft::Quantum::Simulator::AlignedAlloc<Complex, 64>>>;
	Item(Matrix mat, IndexVector idx) : mat_(std::move(mat)), idx_(idx) {}
	Matrix& get_matrix() { return mat_; }
	IndexVector& get_indices() const { return idx_; }
	void remap_idx(std::unordered_map<unsigned, unsigned> elemDict) const {
		for (size_t i = 0; i < idx_.size(); i++) {
			idx_[i] = elemDict[idx_[i]];
		}
	}
private:
	Matrix mat_;
	mutable IndexVector idx_;
};

// Class handling the fusion of gates
class Fusion{
public:
	using Index = unsigned;
	using IndexSet = std::set<Index>;
	using IndexVector = std::vector<Index>;
	using Complex = std::complex<double>;
    using Matrix = std::vector<std::vector<Complex, Microsoft::Quantum::Simulator::AlignedAlloc<Complex, 64>>>;
	using ItemVector = std::vector<Item>;
	
	Fusion() : global_factor_(1.) {}
	
	Index num_qubits() const {
		return static_cast<Index>(target_set_.size());
	}

	Index num_controls() const {
		return static_cast<Index>( ctrl_set_.size());
	}

	
	Index size() const {
		return static_cast<Index>(items_.size());
	}
	
	template <class T>
	void global_factor(T const& factor) {
		assert(items_.size() > 0); // make sure we never drop a global factor
		global_factor_ *= factor;
		IndexVector empty_vec;
		Matrix empty_matrix;
		handle_controls(empty_matrix, empty_vec, {}); // remove all current control qubits (this is a GLOBAL factor)
	}
	
	const IndexSet& get_target_set() const {
		return target_set_;
	}

	const ItemVector& get_items() const {
		return items_;
	}

	const IndexSet& get_ctrl_set() const {
		return ctrl_set_;
	}

	const Complex& get_global_factor() const {
		return global_factor_;
	}

	static void remap_qubits(std::set<Index>& qubits, const std::unordered_map<unsigned, unsigned>& mapFromOldLocToNewLoc) {
		std::set<Index> tempSet;
		for (unsigned elem : qubits) {
			if (mapFromOldLocToNewLoc.find(elem) != mapFromOldLocToNewLoc.end()) {
				tempSet.insert(mapFromOldLocToNewLoc.at(elem));
			}
		}
		qubits.swap(tempSet);
	}

	void remap_target_set(const std::unordered_map<unsigned, unsigned>& mapFromOldLocToNewLoc) const {
		remap_qubits(target_set_, mapFromOldLocToNewLoc);
	}

	void remap_ctrl_set(const std::unordered_map<unsigned, unsigned>& mapFromOldLocToNewLoc) const {
		remap_qubits(ctrl_set_, mapFromOldLocToNewLoc);
	}
	
	void set_items(ItemVector&& newItems) const {
		items_.swap(newItems);
	}

	// This saves a class instance create/destroy on every gate insert
	// Need a quick way to decide if we're going to grow too wide
	int predict(IndexVector index_list, IndexVector const& ctrl_list = {}) {
		int cnt = num_qubits() + num_controls();
		for (auto idx : index_list)
			if (target_set_.count(idx) == 0 && ctrl_set_.count(idx) == 0) cnt++;
		for (auto idx : ctrl_list)
			if (target_set_.count(idx) == 0 && ctrl_set_.count(idx) == 0) cnt++;
		return cnt;
	}

	void insert(Matrix matrix, IndexVector index_list, IndexVector const& ctrl_list = {}) const {
		for (auto idx : index_list)
			target_set_.emplace(idx);
		
		if (global_factor_ != 1. && ctrl_list.size() > 0){
			assert(ctrl_set_.size() == 0);
			add_controls(matrix, index_list, ctrl_list);
		}
		else
			handle_controls(matrix, index_list, ctrl_list);
		Item item(matrix, index_list);
		items_.push_back(item);
	}
	
	void get_indices(IndexVector &indices) const{
		for (auto idx : target_set_)
			indices.push_back(idx);
	}
	
	void perform_fusion(Matrix& fused_matrix, IndexVector& index_list, IndexVector& ctrl_list){
		if (global_factor_ != 1.)
			assert(ctrl_set_.size() == 0);
		
		for (auto idx : target_set_)
			index_list.push_back(idx);
		
		unsigned N = num_qubits();
		fused_matrix = Matrix(1ULL<<N, std::vector<Complex, Microsoft::Quantum::Simulator::AlignedAlloc<Complex, 64>>(1ULL<<N));
		auto &M = fused_matrix;
		
		for (std::size_t i = 0; i < (1ULL<<N); ++i)
			M[i][i] = 1. * global_factor_;
		
		for (auto& item : items_){
			auto const& idx = item.get_indices();
			IndexVector idx2mat(idx.size());
			for (std::size_t i = 0; i < idx.size(); ++i)
				idx2mat[i] = static_cast<unsigned>(((std::equal_range(index_list.begin(), index_list.end(), idx[i])).first - index_list.begin()));
			
			#pragma omp parallel for schedule(static)
			for (unsigned long long k = 0; k < (1ULL<<N); ++k){ // loop over big matrix columns
				// check if column index satisfies control-mask
				// if not: leave it unchanged
				std::vector<Complex> oldcol(1ULL<<N);
				for (std::size_t i = 0; i < (1ULL<<N); ++i)
					oldcol[i] = M[i][k];

				for (std::size_t i = 0; i < (1ULL<<N); ++i){
					unsigned local_i = 0;
					for (std::size_t l = 0; l < idx.size(); ++l)
						local_i |= ((i >> idx2mat[l])&1)<<l;
						
					Complex res = 0.;
					for (std::size_t j = 0; j < (1ULL<<idx.size()); ++j){
						std::size_t locidx = i;
						for (std::size_t l = 0; l < idx.size(); ++l)
							if (((j >> l)&1) != ((i >> idx2mat[l])&1))
								locidx ^= (1ULL << idx2mat[l]);
						res += oldcol[locidx] * item.get_matrix()[local_i][j];
					}
					M[i][k] = res;
				}
			}
		}
		ctrl_list.reserve(ctrl_set_.size());
		for (auto ctrl : ctrl_set_)
			ctrl_list.push_back(ctrl);
	}

private:
	void add_controls(Matrix &matrix, IndexVector &indexList, IndexVector const& new_ctrls) const {
		indexList.reserve(indexList.size()+new_ctrls.size());
		indexList.insert(indexList.end(), new_ctrls.begin(), new_ctrls.end());
		
		std::size_t F = (1ULL << new_ctrls.size());
		Matrix newmatrix(F*matrix.size(), std::vector<Complex, Microsoft::Quantum::Simulator::AlignedAlloc<Complex,64>>(F*matrix.size(), 0.));
		
		std::size_t Offset = newmatrix.size()-matrix.size();
		
		for (std::size_t i = 0; i < Offset; ++i)
			newmatrix[i][i] = 1.;
		for (std::size_t i = 0; i < matrix.size(); ++i){
			for (std::size_t j = 0; j < matrix.size(); ++j)
				newmatrix[Offset+i][Offset+j] = matrix[i][j];
		}
		matrix = std::move(newmatrix);
	}
	
	void handle_controls(Matrix &matrix, IndexVector &indexList, IndexVector const& ctrlList) const {
		auto unhandled_ctrl = ctrl_set_; // will contain all ctrls that are not part of the new command
		// --> need to be removed from the global mask and the controls incorporated into the old
		// commands (the ones already in the list).
		
		for (auto ctrlIdx : ctrlList){
			if (ctrl_set_.count(ctrlIdx) == 0){ // need to either add it to the list or to the command
				if (items_.size() > 0){ // add it to the command
					add_controls(matrix, indexList, {ctrlIdx});
					target_set_.insert(ctrlIdx);
				}
				else // add it to the list
					ctrl_set_.emplace(ctrlIdx);
			}
			else
				unhandled_ctrl.erase(ctrlIdx);
		}
		// remove global controls which are no longer global (because the current command didn't
		// have it)
		if (unhandled_ctrl.size() > 0){
			IndexVector new_ctrls;
			new_ctrls.reserve(unhandled_ctrl.size());
			for (auto idx : unhandled_ctrl){
				new_ctrls.push_back(idx);
				ctrl_set_.erase(idx);
				target_set_.insert(idx);
			}
			for (auto &item : items_)
				add_controls(item.get_matrix(), item.get_indices(), new_ctrls);
		}
	}
	
	mutable IndexSet target_set_; //set of qubits being acted on
	mutable ItemVector items_; //queue if gates to be fused
	mutable IndexSet ctrl_set_; //set of controls
	mutable Complex global_factor_;
};

#endif
