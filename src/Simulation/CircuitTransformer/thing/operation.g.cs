#pragma warning disable 1591
using System;
using Microsoft.Quantum.Core;
using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Core;

[assembly: CallableDeclaration("{\"Kind\":{\"Case\":\"Operation\"},\"QualifiedName\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"ClasicallyControlled\"},\"SourceFile\":\"D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs\",\"Position\":{\"Item1\":5,\"Item2\":4},\"SymbolRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":31}},\"ArgumentTuple\":{\"Case\":\"QsTuple\",\"Fields\":[[{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"q\"]},\"Type\":{\"Case\":\"Qubit\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":32},\"Item2\":{\"Line\":1,\"Column\":33}}}]},{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"op\"]},\"Type\":{\"Case\":\"Operation\",\"Fields\":[{\"Item1\":{\"Case\":\"Qubit\"},\"Item2\":{\"Case\":\"UnitType\"}},{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}]},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":42},\"Item2\":{\"Line\":1,\"Column\":44}}}]},{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"arg\"]},\"Type\":{\"Case\":\"Qubit\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":63},\"Item2\":{\"Line\":1,\"Column\":66}}}]}]]},\"Signature\":{\"TypeParameters\":[],\"ArgumentType\":{\"Case\":\"TupleType\",\"Fields\":[[{\"Case\":\"Qubit\"},{\"Case\":\"Operation\",\"Fields\":[{\"Item1\":{\"Case\":\"Qubit\"},\"Item2\":{\"Case\":\"UnitType\"}},{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}]},{\"Case\":\"Qubit\"}]]},\"ReturnType\":{\"Case\":\"UnitType\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}},\"Documentation\":[]}")]
[assembly: SpecializationDeclaration("{\"Kind\":{\"Case\":\"QsBody\"},\"TypeArguments\":{\"Case\":\"Null\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}},\"Parent\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"ClasicallyControlled\"},\"SourceFile\":\"D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs\",\"Position\":{\"Item1\":5,\"Item2\":4},\"HeaderRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":31}},\"Documentation\":[]}")]
[assembly: CallableDeclaration("{\"Kind\":{\"Case\":\"Operation\"},\"QualifiedName\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"Foo\"},\"SourceFile\":\"D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs\",\"Position\":{\"Item1\":12,\"Item2\":4},\"SymbolRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":14}},\"ArgumentTuple\":{\"Case\":\"QsTuple\",\"Fields\":[[]]},\"Signature\":{\"TypeParameters\":[],\"ArgumentType\":{\"Case\":\"UnitType\"},\"ReturnType\":{\"Case\":\"Int\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}},\"Documentation\":[]}")]
[assembly: SpecializationDeclaration("{\"Kind\":{\"Case\":\"QsBody\"},\"TypeArguments\":{\"Case\":\"Null\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}},\"Parent\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"Foo\"},\"SourceFile\":\"D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs\",\"Position\":{\"Item1\":12,\"Item2\":4},\"HeaderRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":14}},\"Documentation\":[]}")]
#line hidden
namespace Microsoft.Hack
{
    public partial class ClasicallyControlled : Operation<(Qubit,ICallable,Qubit), QVoid>, ICallable
    {
        public ClasicallyControlled(IOperationFactory m) : base(m)
        {
        }

        public class In : QTuple<(Qubit,ICallable,Qubit)>, IApplyData
        {
            public In((Qubit,ICallable,Qubit) data) : base(data)
            {
            }

            System.Collections.Generic.IEnumerable<Qubit> IApplyData.Qubits => Qubit.Concat(((IApplyData)Data.Item1)?.Qubits, ((IApplyData)Data.Item2)?.Qubits, ((IApplyData)Data.Item3)?.Qubits);
        }

        String ICallable.Name => "ClasicallyControlled";
        String ICallable.FullName => "Microsoft.Hack.ClasicallyControlled";
        protected ICallable<Qubit, Result> MicrosoftQuantumIntrinsicM
        {
            get;
            set;
        }

        public override Func<(Qubit,ICallable,Qubit), QVoid> Body => (__in__) =>
        {
            var (q,op,arg) = __in__;
#line 7 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
            var res = (MicrosoftQuantumIntrinsicM.Apply(q) == Result.One);
#line 8 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
            if (res)
            {
#line 9 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
                op.Apply(arg);
            }

#line hidden
            return QVoid.Instance;
        }

        ;
        public override void Init()
        {
            this.MicrosoftQuantumIntrinsicM = this.Factory.Get<ICallable<Qubit, Result>>(typeof(Microsoft.Quantum.Intrinsic.M));
        }

        public override IApplyData __dataIn((Qubit,ICallable,Qubit) data) => new In(data);
        public override IApplyData __dataOut(QVoid data) => data;
        public static System.Threading.Tasks.Task<QVoid> Run(IOperationFactory __m__, Qubit q, ICallable op, Qubit arg)
        {
            return __m__.Run<ClasicallyControlled, (Qubit,ICallable,Qubit), QVoid>((q, op, arg));
        }
    }

    public partial class Foo : Operation<QVoid, Int64>, ICallable
    {
        public Foo(IOperationFactory m) : base(m)
        {
        }

        String ICallable.Name => "Foo";
        String ICallable.FullName => "Microsoft.Hack.Foo";
        protected ApplyIfOne MicrosoftQuantumClassicalControlApplyIfOne
        {
            get;
            set;
        }

        protected Allocate Allocate
        {
            get;
            set;
        }

        protected IUnitary<Qubit> MicrosoftQuantumIntrinsicH
        {
            get;
            set;
        }

        protected ICallable<Qubit, Result> MicrosoftQuantumIntrinsicM
        {
            get;
            set;
        }

        protected Release Release
        {
            get;
            set;
        }

        protected IUnitary<Qubit> MicrosoftQuantumIntrinsicX
        {
            get;
            set;
        }

        public override Func<QVoid, Int64> Body => (__in__) =>
        {
#line hidden
            {
#line 15 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
                var (q1,q2) = (Allocate.Apply(), Allocate.Apply());
#line hidden
                Exception __arg1__ = null;
                try
                {
#line 16 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
                    MicrosoftQuantumIntrinsicH.Apply(q1);
#line 18 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
                    MicrosoftQuantumClassicalControlApplyIfOne.Apply((MicrosoftQuantumIntrinsicM.Apply(q1), (MicrosoftQuantumIntrinsicX, q2)));
                }
#line hidden
                catch (Exception __arg2__)
                {
                    __arg1__ = __arg2__;
                    throw __arg1__;
                }
#line hidden
                finally
                {
                    if (__arg1__ != null)
                    {
                        throw __arg1__;
                    }

#line hidden
                    Release.Apply(q1);
#line hidden
                    Release.Apply(q2);
                }
            }

#line 23 "D:/qsharp-hackathon/src/Simulation/HackathonWalker/operation.qs"
            return 0L;
        }

        ;
        public override void Init()
        {
            this.MicrosoftQuantumClassicalControlApplyIfOne = this.Factory.Get<ApplyIfOne>(typeof(Microsoft.Quantum.ClassicalControl.ApplyIfOne));
            this.Allocate = this.Factory.Get<Allocate>(typeof(Microsoft.Quantum.Intrinsic.Allocate));
            this.MicrosoftQuantumIntrinsicH = this.Factory.Get<IUnitary<Qubit>>(typeof(Microsoft.Quantum.Intrinsic.H));
            this.MicrosoftQuantumIntrinsicM = this.Factory.Get<ICallable<Qubit, Result>>(typeof(Microsoft.Quantum.Intrinsic.M));
            this.Release = this.Factory.Get<Release>(typeof(Microsoft.Quantum.Intrinsic.Release));
            this.MicrosoftQuantumIntrinsicX = this.Factory.Get<IUnitary<Qubit>>(typeof(Microsoft.Quantum.Intrinsic.X));
        }

        public override IApplyData __dataIn(QVoid data) => data;
        public override IApplyData __dataOut(Int64 data) => new QTuple<Int64>(data);
        public static System.Threading.Tasks.Task<Int64> Run(IOperationFactory __m__)
        {
            return __m__.Run<Foo, QVoid, Int64>(QVoid.Instance);
        }
    }
}