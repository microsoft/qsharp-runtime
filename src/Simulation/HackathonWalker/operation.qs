// dotnet run -- -i operation.qs -r /home/cyl/q/qsharp-runtime/src/Simulation/Intrinsic/bin/Debug/netstandard2.0/Microsoft.Quantum.Intrinsic.dll -o thing
// dotnet run -- -i .\operation.qs -r D:\qsharp-hackathon\src\Simulation\Simulators\bin\Debug\netstandard2.0\Microsoft.Quantum.Intrinsic.dll -o thing 
namespace Microsoft.Hack {
    open Microsoft.Quantum.Intrinsic;

    operation ClasicallyControlled(q: Qubit, op: (Qubit => Unit), arg: Qubit) : Unit {
        let res = M(q) == One;
        if (res) {
            op(arg);
        }
    }

    operation Foo() : Int {
 
        using ((q1, q2) = (Qubit(), Qubit())) {
            H(q1);
    
            if (M(q1) == One) {
                X(q2);
            }
        }
    
        return 0;
    }


}

// replace with

// namespace Microsoft.Hack {
//     operation Foo() : Int {
 
//         using(q = Qubit()){
//             H(q);
 
//             Microsoft.Hack.ClassicallyControlled(q1, X, q2)
//         }
 
//         return 0;
//     }
// }
