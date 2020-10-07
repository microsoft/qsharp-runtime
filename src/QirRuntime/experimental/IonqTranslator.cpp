#define _USE_MATH_DEFINES
#include <assert.h>
#include <cmath>
#include <sstream>
#include <vector>

#include "ITranslator.hpp"
#include "ExperimentalSimFactory.hpp"

#include "BitStates.hpp"
#include "QuantumApiBase.hpp"

using namespace std;

namespace quantum
{
    /*==============================================================================
      The purpose of the translator is to generate JSON in IonQ format that
      represents the program which was run by the translator.

      // Sample IonQ JSON object
      {
        "qubits": 4,
        "circuit": [
          {
          "gate": "h",
          "target": [0, 1, 2, 3],
          },
          {
          "gate": "rx",
          "target:" 0,
          "rotation": 1
          },
          {
          "gate": "x",
          "target": 2,
          "control": 0
          }
        ]
      }

      All qubits are measured at the end and the results are reported to the user.
      We will model this by marking measured qubits as "frozen" so no more quantum
      operations are allowed on them. The result of the measurement isn't relevant
      for the translator. Attempts to manipulate frozen or released qubits will be
      logged by the translator but won't abort it.
    ==============================================================================*/
    // NB: v, vi (square root of x) not supported by the translator
    enum class Gate
    {
        x = 0,
        y,
        z,
        h,
        s,
        si,
        t,
        ti,
        swap,

        // rotations
        rx,
        ry,
        rz,
        xx,
        yy,
        zz,

        // to track qubit allocations
        alloc,

        // to report errors
        undefined,

        // must be last
        n_gates
    };
    const char* const gate_names[] = {
        "x", "y", "z", "h", "s", "si", "t", "ti", "swap", "rx", "ry", "rz", "xx", "yy", "zz", "alloc", "undefined",
    };
    static_assert(
        sizeof(gate_names) / sizeof(gate_names[0]) == static_cast<size_t>(Gate::n_gates),
        L"The list of gates' names must match the Gate enumeration");

    static void PrintVector(ostringstream& os, const vector<long>& v, const char* name)
    {
        if (v.empty())
        {
            return;
        }

        os << "\"" << name << "\":";
        if (v.size() > 1)
        {
            os << "[";
        }
        for (long l : v)
        {
            os << l << ",";
        }
        if (v.size() > 1)
        {
            os << "],";
        }
    }

    /*==============================================================================
        As the simulator executes along a particular path, the translator would
        accumulate corresponding instructions and errors.
    ==============================================================================*/
    struct TranslationError
    {
        Gate gate = Gate::undefined;
        vector<long> targets;  // can be empty if error isn't specific to a particular qubit
        vector<long> controls; // can be empty
        string msg;

        void Print(ostringstream& os) const
        {
            os << "{";
            os << "\"gate\":\"" << gate_names[static_cast<size_t>(gate)] << "\",";
            PrintVector(os, targets, "target");
            PrintVector(os, controls, "control");
            os << "\"message\":\"" << msg << "\"";
            os << "},";
        }
    };

    struct Instruction
    {
        Gate gate;
        vector<long> targets;
        vector<long> controls; // can be empty
        double rotation = 0;   // only meaningful for rx, ry, rz, xx, yy and zz gates

        Instruction(Gate gate, vector<long>&& targets, vector<long>&& controls, double rotation)
            : gate(gate)
            , targets(std::move(targets))
            , controls(std::move(controls))
            , rotation(rotation)
        {
        }

        bool IsRotation() const
        {
            return Gate::rx <= gate && gate <= Gate::zz;
        }

        void Print(ostringstream& os) const
        {
            os << "{";
            os << "\"gate\":\"" << gate_names[static_cast<size_t>(gate)] << "\",";
            PrintVector(os, targets, "target");
            PrintVector(os, controls, "control");
            if (IsRotation())
            {
                os << "\"rotation\":" << rotation << ",";
            }
            os << "},";
        }
    };

    /*==============================================================================
        The decomposer provides classical "text book" decompositions for some of the
        unitaries without any hardware specific optimizations.

        A quantum processor, that wants to avail of the decompositions, should
        implement the primitive operations, pass itself to the decomposer and then
        delegate to it calls that should be decomposed.

        NB: because the owner opts-in for each decomposition separately the decomposer
        will call back for each step, even if it might come back to it (R1Frac -> R1).
    ==============================================================================*/
    class CCanonicalDecomposer final : public CQuantumApiBase
    {
        // The decomposer assumes that owner's lifetime exceeds its own.
        IQuantumApi* owner = nullptr;

        static double CalculateAngle(long numerator, long power)
        {
            return -numerator * M_PI / std::pow(2.0, power - 1);
        }

      public:
        CCanonicalDecomposer(IQuantumApi* ownerIQP)
            : owner(ownerIQP)
        {
        }

        void R1(Qubit qubit, double theta) override
        {
            this->owner->R(PauliId_Z, qubit, theta);
            this->owner->R(PauliId_I, qubit, -theta);
        }

        void ControlledR1(long numControls, Qubit* const controls, Qubit qubit, double theta) override
        {
            this->owner->ControlledR(numControls, controls, PauliId_I, qubit, -theta);
            this->owner->ControlledR(numControls, controls, PauliId_Z, qubit, theta);
        }

        void RFraction(PauliId axis, Qubit qubit, long numerator, long power) override
        {
            this->owner->R(axis, qubit, CalculateAngle(numerator, power));
        }

        void ControlledRFraction(
            long numControls,
            Qubit* const controls,
            PauliId axis,
            Qubit qubit,
            long numerator,
            long power) override
        {
            this->owner->ControlledR(numControls, controls, axis, qubit, CalculateAngle(numerator, power));
        }

        void R1Fraction(Qubit qubit, long numerator, long power) override
        {
            this->owner->R1(qubit, CalculateAngle(numerator, power));
        }

        void ControlledR1Fraction(long numControls, Qubit* const controls, Qubit qubit, long numerator, long power)
            override
        {
            double theta = -numerator * M_PI / std::pow(2.0, power - 1);
            this->owner->ControlledR1(numControls, controls, qubit, CalculateAngle(numerator, power));
        }

        // TODO: implement exponents
    };

    /*==============================================================================
        CIonqTranslator
    ==============================================================================*/
    class CIonqTranslator final : public ITranslator
    {
        // List of IonQ instructions that correspond to the commands executed by the
        // translator.
        vector<Instruction> instructions;

        // Errors, encountered by the translator (might or might not be ignorable).
        vector<TranslationError> errors;

        // IonQ allocates all qubits upfront and doesn't reuse them, so the translator
        // keeps track of the number of allocations to specify the size of quantum register.
        long quantumRegisterSize = 0;

      public:
        CIonqTranslator() = default;
        ~CIonqTranslator() = default;

        void AddInstruction(Instruction&& instr)
        {
            if (instr.gate == Gate::alloc)
            {
                this->quantumRegisterSize++;
            }
            else
            {
                instructions.push_back(std::move(instr));
            }
        }

        void AddError(TranslationError&& error)
        {
            this->errors.push_back(std::move(error));
        }

        void PrintRepresentation(ostringstream& os, ostringstream* err) override
        {
            os << "{\"qubits\":" << this->quantumRegisterSize << ",\"circuit\":[";
            for (const Instruction& inst : this->instructions)
            {
                inst.Print(os);
            }
            os << "]}";

            if (err != nullptr && !this->errors.empty())
            {
                *err << "{\"error_count\":" << this->errors.size() << ",\"errors\":[";
                for (const TranslationError& error : this->errors)
                {
                    error.Print(*err);
                }
                *err << "]}";
            }
        }
    };

    /*==============================================================================
        CIonqSimulator
    ==============================================================================*/
    class CIonqSimulator final : public CQuantumApiBase
    {
        unique_ptr<IQuantumApi> decomposer;

        // The translator doesn't allocate any memory for qubits but tracks them by id.
        long lastUsedId = -1;

        // State of a qubit is represented by a bit in frozen indexed by qubit's id,
        // bits 0 and 1 correspond to whether the qubit is active or has been measured
        // or released and cannot be used anymore.
        BitStates frozen;

        shared_ptr<ITranslator> itranslator = nullptr;
        CIonqTranslator* translator = nullptr;

      private:
        static const long invalidQubitId = -1;

        long GetQubitId(Qubit qubit)
        {
            long id = reinterpret_cast<long>(qubit);
            assert(id <= this->lastUsedId);
            return id;
        }

        vector<long> GetQubitIds(long numQubits, Qubit* qubits)
        {
            vector<long> qubitIds;
            qubitIds.reserve(numQubits);
            for (long i = 0; i < numQubits; i++)
            {
                qubitIds.push_back(GetQubitId(qubits[i]));
            }
            return qubitIds;
        }

        bool IsFrozen(Qubit qubit)
        {
            return this->frozen.IsBitSetAt(GetQubitId(qubit));
        }

        void TryAddInstruction(Qubit qubit, Instruction&& instr)
        {
            if (!IsFrozen(qubit))
            {
                this->translator->AddInstruction(std::move(instr));
            }
            else
            {
                TranslationError error{instr.gate, instr.targets, instr.controls, "qubit used after being frozen"};
                this->translator->AddError(std::move(error));
            }
        }

        void TryAddInstruction(long numQubits, Qubit* qubits, Instruction&& instr)
        {
            Qubit frozen = nullptr;
            for (long i = 0; i < numQubits; i++)
            {
                if (IsFrozen(qubits[i]))
                {
                    frozen = qubits[i];
                    break;
                }
            }
            if (frozen == nullptr)
            {
                this->translator->AddInstruction(std::move(instr));
            }
            else
            {
                ostringstream os;
                os << "qubit used after being frozen (" << GetQubitId(frozen) << ")";
                TranslationError error{instr.gate, instr.targets, instr.controls, os.str()};
                this->translator->AddError(std::move(error));
            }
        }

        void TryAddInstruction(vector<Qubit> qubits, Instruction&& instr)
        {
            TryAddInstruction(qubits.size(), qubits.data(), std::move(instr));
        }

      public:
        explicit CIonqSimulator(shared_ptr<ITranslator> ionqTranslator)
            : decomposer(make_unique<CCanonicalDecomposer>(this))
            , itranslator(std::move(ionqTranslator))
        {
            translator = (static_cast<CIonqTranslator*>(itranslator.get()));
        }
        ~CIonqSimulator() = default;

        //============================================================================
        // implementation of the relevant subset of IQuantumApi
        //============================================================================
        Qubit AllocateQubit() override
        {
            this->lastUsedId++;
            this->frozen.ExtendToInclude(this->lastUsedId);
            this->translator->AddInstruction({Gate::alloc, {this->lastUsedId}, {}, 0});
            return reinterpret_cast<Qubit>(this->lastUsedId);
        }

        void ReleaseQubit(Qubit qubit) override
        {
            this->frozen.SetBitAt(GetQubitId(qubit));
        }

        Result M(Qubit qubit) override
        {
            long qubitId = GetQubitId(qubit);
            this->frozen.SetBitAt(qubitId);
            return reinterpret_cast<Result>(qubitId);
        }

        Result UseZero() override
        {
            return reinterpret_cast<Result>(-2);
        }

        Result UseOne() override
        {
            return reinterpret_cast<Result>(-3);
        }

        void ReleaseResult(Result result) override {}

        TernaryBool AreEqualResults(Result r1, Result r2) override
        {
            if ((r1 == UseZero() || r1 == UseOne()) && (r2 == UseZero() || r2 == UseOne()))
            {
                return r1 == r2 ? TernaryBool_True : TernaryBool_False;
            }

            vector<long> targets;
            if (r1 == UseZero() || r1 == UseOne())
            {
                targets.push_back(reinterpret_cast<long>(r2));
            }
            else if (r2 == UseZero() || r2 == UseOne())
            {
                targets.push_back(reinterpret_cast<long>(r1));
            }
            else
            {
                targets.push_back(reinterpret_cast<long>(r1));
                targets.push_back(reinterpret_cast<long>(r2));
            }

            TranslationError error{
                Gate::undefined, targets, {}, "comparing results to each other or to Zero/One not supported"};
            this->translator->AddError(std::move(error));

            return TernaryBool_Undefined;
        }

        ResultValue GetResultValue(Result result) override
        {
            if (result == UseZero())
            {
                return Result_Zero;
            }
            if (result == UseOne())
            {
                return Result_One;
            }
            return Result_Pending;
        }

        void X(Qubit qubit) override
        {
            Instruction instr{Gate::x, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledX(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::x, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void Y(Qubit qubit) override
        {
            Instruction instr{Gate::y, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledY(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::y, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void Z(Qubit qubit) override
        {
            Instruction instr{Gate::z, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledZ(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::z, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void SWAP(Qubit qubit1, Qubit qubit2) override
        {
            Instruction instr{Gate::swap, {GetQubitId(qubit1), GetQubitId(qubit2)}, {}, 0};
            TryAddInstruction({qubit1, qubit2}, std::move(instr));
        }

        void ControlledSWAP(long numControls, Qubit* const controls, Qubit qubit1, Qubit qubit2) override
        {
            Instruction instr{
                Gate::swap, {GetQubitId(qubit1), GetQubitId(qubit2)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction({qubit1, qubit2}, std::move(instr));
        }

        void H(Qubit qubit) override
        {
            Instruction instr{Gate::h, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledH(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::h, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void S(Qubit qubit) override
        {
            Instruction instr{Gate::s, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledS(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::s, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void SAdjoint(Qubit qubit) override
        {
            Instruction instr{Gate::si, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledSAdjoint(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::si, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void T(Qubit qubit) override
        {
            Instruction instr{Gate::t, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledT(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::t, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void TAdjoint(Qubit qubit) override
        {
            Instruction instr{Gate::ti, {GetQubitId(qubit)}, {}, 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledTAdjoint(long numControls, Qubit* const controls, Qubit qubit) override
        {
            Instruction instr{Gate::ti, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), 0};
            TryAddInstruction(qubit, std::move(instr));
        }

        void R(PauliId axis, Qubit qubit, double theta) override
        {
            if (axis == PauliId_I)
            {
                return;
            }

            Gate gate = (axis == PauliId_X) ? Gate::rx : (axis == PauliId_Y) ? Gate::ry : Gate::rz;
            Instruction instr{gate, {GetQubitId(qubit)}, {}, theta};
            TryAddInstruction(qubit, std::move(instr));
        }

        void ControlledR(long numControls, Qubit* const controls, PauliId axis, Qubit qubit, double theta) override
        {
            if (numControls == 0)
            {
                R(axis, qubit, theta);
            }
            else if (axis == PauliId_I)
            {
                this->decomposer->ControlledR1(numControls - 1, &controls[1], controls[0], -theta / 2);
            }
            else
            {
                Gate gate = (axis == PauliId_X) ? Gate::rx : ((axis == PauliId_Y) ? Gate::ry : Gate::rz);
                Instruction instr{gate, {GetQubitId(qubit)}, GetQubitIds(numControls, controls), theta};
                TryAddInstruction(qubit, std::move(instr));
            }
        }

        Gate CalculateExpGate(long numPaulis, PauliId* const paulis)
        {
            if (numPaulis != 2 || paulis[0] != paulis[1] || paulis[0] == PauliId_I)
            {
                return Gate::undefined;
            }

            // Add the matching Ising gate.
            return (paulis[0] == PauliId_X) ? Gate::xx : ((paulis[0] == PauliId_Y) ? Gate::yy : Gate::zz);
        }

        void Exp(long numTargets, PauliId* const paulis, Qubit* const qubits, double theta) override
        {
            Gate gate = CalculateExpGate(numTargets, paulis);
            if (gate == Gate::undefined)
            {
                TranslationError error{
                    Gate::undefined,
                    GetQubitIds(numTargets, qubits),
                    {},
                    "Exp is supported for exactly two same PauliId matrices"};
                this->translator->AddError(std::move(error));
            }
            else
            {
                Instruction instr{gate, GetQubitIds(numTargets, qubits), {}, theta / 2};
                TryAddInstruction(numTargets, qubits, std::move(instr));
            }
        }

        void ControlledExp(
            long numControls,
            Qubit* const controls,
            long numTargets,
            PauliId* const paulis,
            Qubit* const qubits,
            double theta) override
        {
            Gate gate = CalculateExpGate(numTargets, paulis);
            if (gate == Gate::undefined)
            {
                TranslationError error{
                    Gate::undefined, GetQubitIds(numTargets, qubits), GetQubitIds(numControls, controls),
                    "ControlledExp is supported for exactly two same PauliId matrices"};
                this->translator->AddError(std::move(error));
            }
            else
            {
                Instruction instr{gate, GetQubitIds(numTargets, qubits), GetQubitIds(numControls, controls), theta / 2};
                TryAddInstruction(numTargets, qubits, std::move(instr));
            }
        }
    };

    std::shared_ptr<ITranslator> CreateIonqTranslator()
    {
        return std::make_shared<CIonqTranslator>();
    }
    std::unique_ptr<IQuantumApi> CreateIonqSimulator(shared_ptr<ITranslator> translator)
    {
        return std::make_unique<CIonqSimulator>(std::move(translator));
    }

} // namespace quantum