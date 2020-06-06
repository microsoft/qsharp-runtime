// Used for a unit test; 
// do not change the name of this namespace!
namespace Quantum.Library {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    // Used for a unit test; 
    // do not change the name or namespace of this callable!
    @EnableTestingViaName("Library2.Hello")
    operation Hello() : Unit {
        Message("Hello from Library2!");
    }
}
