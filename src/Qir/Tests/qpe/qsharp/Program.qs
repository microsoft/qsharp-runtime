// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.PnnlCollaboration {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Core;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Chemistry.JordanWigner;  
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    function Unpacked<'T>(n : Int, xs : 'T[]) : 'T[][] {
        return IsEmpty(xs) ? [] | Transposed(Chunks(n, xs));
    }

    function UnpackedJagged<'T>(ns : Int[], xs : 'T[]) : 'T[][] {
        return IsEmpty(xs) ? [] | Most(Partitioned(ns, xs));
    }

    @EntryPoint()
    operation EstimateEnergyFromFlattenedJWData(
        nQubits : Int,

        nZTerms : Int,
        zTermIdxs : Int[],
        zCoeffs : Double[],

        nZzTerms : Int,
        zzTermIdxs : Int[],
        zzCoeffs : Double[],

        // nPqAndPqqrTerms : Int,
        nPqAndPqqrTerms : Int[],

        pqAndPqqrTermIdxs : Int[],
        pqAndPqqrCoeffs : Double[],

        nH0123Terms : Int,
        h0123TermIdxs : Int[],
        h0123Coeffs : Double[],

        stateType : Int,
        realStateCoeffs : Double[],
        imagStateCoeffs : Double[],
        nStateTermIdxs : Int[],
        stateTermIdxs : Int[],

        energyOffset : Double,
        nBitsPrecision : Int, 
        trotterStepSize : Double, 
        trotterOrder : Int
    ) : Double {
        let zTerms = Mapped(HTerm, Zipped(Unpacked(nZTerms, zTermIdxs), Unpacked(nZTerms, zCoeffs)));
        //Message($"zTerms:\n{zTerms}");

        // Message($"nZzTerms: {nZzTerms}");
        // Message($"zzTermIdxs:\n{zzTermIdxs}");
        // Message($"Chunks(2, zzTermIdxs):\n{Chunks(2, zzTermIdxs)}");
        //let zzTerms = Mapped(HTerm, Zipped(Unpacked(nZzTerms, zzTermIdxs), Unpacked(nZzTerms, zzCoeffs)));
        let zzTerms = Mapped(HTerm, Zipped(IsEmpty(zzTermIdxs) ? [] | Chunks(2, zzTermIdxs), Unpacked(nZzTerms, zzCoeffs)));
        // Message($"zzTerms:\n{zzTerms}");

        // Message($"pqAndPqqrTermIdxs[{Length(pqAndPqqrTermIdxs)}]:");
        // for index in 0..4..(Length(pqAndPqqrTermIdxs) - 1) {
        //     Message($"{pqAndPqqrTermIdxs[index]}, {pqAndPqqrTermIdxs[index+1]}, {pqAndPqqrTermIdxs[index+2]}, {pqAndPqqrTermIdxs[index+3]}");
        // }

        // Message($"Chunks(<= {nPqAndPqqrTerms} items each):");
        // let chunks = Chunks(nPqAndPqqrTerms, pqAndPqqrTermIdxs);
        // mutable i = 0;
        // for chunkItem in chunks {
        //     for intItem in chunkItem {
        //         Message($"{i}: {intItem}");
        //         set i = i + 1;
        //     }
        //     Message("");
        // }

        // for chunkStartIndex in 0..nPqAndPqqrTerms..(Length(pqAndPqqrTermIdxs) - 1) {
        //     for offsInChunk in 0..(nPqAndPqqrTerms - 1) {
        //         let overallIndex = chunkStartIndex + offsInChunk;
        //         if overallIndex < Length(pqAndPqqrTermIdxs) {
        //             Message($"pqAndPqqrTermIdxs[overallIndex]");
        //         }
        //     }
        //     Message("");
        // }

        // let pqAndPqqrTerms = Mapped(HTerm, Zipped(Unpacked(nPqAndPqqrTerms, pqAndPqqrTermIdxs), Unpacked(nPqAndPqqrTerms, pqAndPqqrCoeffs)));
        Message("A");
        let pqAndPqqrTerms = Mapped(HTerm, Zipped(UnpackedJagged(nPqAndPqqrTerms, pqAndPqqrTermIdxs), Unpacked(Length(pqAndPqqrCoeffs), pqAndPqqrCoeffs)));
        //Message($"pqAndPqqrTerms:\n{pqAndPqqrTerms}");
        Message("B");

        // let h0123Terms = Mapped(HTerm, Zipped(Unpacked(nH0123Terms, h0123TermIdxs), Unpacked(nH0123Terms, h0123Coeffs)));
        let h0123Terms = Mapped(HTerm, Zipped(Chunks(4, h0123TermIdxs), Chunks(4, h0123Coeffs)));
        //Message($"h0123Terms:\n{h0123Terms}");
        Message("C");
        let terms = JWOptimizedHTerms(zTerms, zzTerms, pqAndPqqrTerms, h0123Terms);
        // Message($"terms:\n{terms}");
        Message("D");

        let stateCoeffs = Zipped(realStateCoeffs, imagStateCoeffs);
        // Message($"stateCoeffs:\n{stateCoeffs}");
        Message("E");
        let stateTerms = Zipped(stateCoeffs, UnpackedJagged(nStateTermIdxs, stateTermIdxs));
        // Message($"stateTerms:\n{stateTerms}");
        Message("F");
        let inputState = (stateType, Mapped(JordanWignerInputState, stateTerms));
        // Message($"inputState:\n{inputState}");
        Message("G");

        let jwEncodedData = JordanWignerEncodingData(
            nQubits, terms, inputState, energyOffset
        );
        //Message($"jwEncodedData: {jwEncodedData}");
        Message("H");

        // Message($"jwEncodedData:\n{jwEncodedData}");
        return EstimateEnergyFromJWData(jwEncodedData, nBitsPrecision, trotterStepSize, trotterOrder);
    }

    // NB: The entry point without flattening for QIR.
    operation EstimateEnergyFromJWData(
        jwEncodedData: JordanWignerEncodingData,
        nBitsPrecision : Int, 
        trotterStepSize : Double, 
        trotterOrder : Int
    ) : Double {
        Message("I");

        // Extract the input state and energy offset, leaving the Hamiltonian
        // itself.
        let (_, _, inputState, energyOffset) = jwEncodedData!;
        // Message($"inputState:\n{inputState}");
        // Message($"energyOffset:\n{energyOffset}");
        Message("J");
        let statePrep = PrepareTrialState(inputState, _);
        // Message($"statePrep:\n{statePrep}");    // <operation>
        Message("K");

        // Use Trotter–Suzuki to encode the Hamiltonian into an evolution
        // oracle.
        let (nQubits, (rescaleFactor, oracle)) = TrotterStepOracle(jwEncodedData, trotterStepSize, trotterOrder);
        // Message($"nQubits: {nQubits}, rescaleFactor: {rescaleFactor}, oracle: {oracle}");
        Message("L");

        // Define how we want to run iterative PE.
        let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
        // Message($"phaseEstAlgorithm:\n{phaseEstAlgorithm}");
        Message("M");

        // Use IPE to estimate the GS energy of the given oracle.
        let estPhase = EstimateEnergy(nQubits, statePrep, oracle, phaseEstAlgorithm);
        Message("N");
        let estEnergy = estPhase * rescaleFactor + energyOffset;
        Message("P");

        return estEnergy;
    }
}
