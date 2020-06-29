﻿// Used for a unit test; 	
// do not change the name of this namespace!	
namespace Microsoft.Quantum.Library {	

    open Microsoft.Quantum.Intrinsic;	

    // Used for a unit test; 	
    // do not change the name or namespace of this type!	
    newtype Token = Unit;	

    // Used for a unit test; 	
    // do not change the name or namespace of this callable!	
    operation Hello(dummy : Token) : Unit {	
        Message("Hello!");	
    }     	
}