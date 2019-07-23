// dotnet run -- -i operation.qs -r /home/cyl/q/qsharp-runtime/src/Simulation/Intrinsic/bin/Debug/netstandard2.0/Microsoft.Quantum.Intrinsic.dll -o thing
namespace Microsoft.Hack {
    open Microsoft.Quantum.Intrinsic;

    operation Foo() : Int {
 
        using (q = Qubit()) {
            H(q);
    
            if (M(q) == Zero) {
                return 1;
            }
        }
    
        return 0;
    }
}

// replace with

// namespace Microsoft.Hack {
//     operation __onTrue() : Unit {
//         return 1;
//     }
 
//     operation Foo() : Int {
 
//         using(q = Qubit()){
//             H(q);
 
//             Microsoft.Hack.ClassicallyControlled(q, __onTrue)
//         }
 
//         return 0;
//     }
// }
