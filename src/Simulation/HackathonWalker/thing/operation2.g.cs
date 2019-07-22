#pragma warning disable 1591
using System;
using Microsoft.Quantum.Core;
using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Core;

[assembly: CallableDeclaration("{\"Kind\":{\"Case\":\"Operation\"},\"QualifiedName\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"Foo\"},\"SourceFile\":\"/home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation2.qs\",\"Position\":{\"Item1\":3,\"Item2\":4},\"SymbolRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":14}},\"ArgumentTuple\":{\"Case\":\"QsTuple\",\"Fields\":[[{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"n\"]},\"Type\":{\"Case\":\"Int\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":15},\"Item2\":{\"Line\":1,\"Column\":16}}}]}]]},\"Signature\":{\"TypeParameters\":[],\"ArgumentType\":{\"Case\":\"Int\"},\"ReturnType\":{\"Case\":\"UnitType\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}},\"Documentation\":[]}")]
[assembly: SpecializationDeclaration("{\"Kind\":{\"Case\":\"QsBody\"},\"TypeArguments\":{\"Case\":\"Null\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}},\"Parent\":{\"Namespace\":\"Microsoft.Hack\",\"Name\":\"Foo\"},\"SourceFile\":\"/home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation2.qs\",\"Position\":{\"Item1\":3,\"Item2\":4},\"HeaderRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":14}},\"Documentation\":[]}")]
#line hidden
namespace Microsoft.Hack
{
    public partial class Foo : Operation<Int64, QVoid>, ICallable
    {
        public Foo(IOperationFactory m) : base(m)
        {
        }

        String ICallable.Name => "Foo";
        String ICallable.FullName => "Microsoft.Hack.Foo";
        public override Func<Int64, QVoid> Body => (__in__) =>
        {
            var n = __in__;
#line 5 "/home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation2.qs"
            var r = Result.One;
#line 6 "/home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation2.qs"
            if ((r == Result.Zero))
            {
#line 7 "/home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation2.qs"
                return QVoid.Instance;
            }

#line hidden
            return QVoid.Instance;
        }

        ;
        public override void Init()
        {
        }

        public override IApplyData __dataIn(Int64 data) => new QTuple<Int64>(data);
        public override IApplyData __dataOut(QVoid data) => data;
        public static System.Threading.Tasks.Task<QVoid> Run(IOperationFactory __m__, Int64 n)
        {
            return __m__.Run<Foo, Int64, QVoid>(n);
        }
    }
}