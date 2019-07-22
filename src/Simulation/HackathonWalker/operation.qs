//  
namespace Microsoft.Hack {
    open Microsoft.Quantum.Intrinsic;
    
    operation Foo() : Int {
 
        using (q = Qubit()) {
            // /home/cyl/q/qsharp-runtime/src/Simulation/HackathonWalker/operation.qs(6,13): error QS5022: No identifier with that name exists.
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
