// Used for a unit test; 
// do not change the name of this namespace!
namespace Microsoft.Quantum.Library {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    
    // Used for a unit test; 
    // do not change the name or namespace of this type!
    @EnableTestingViaName("Library2.MyInt")
    newtype MyInt = (Value2 : Int);

    // Used for a unit test; 
    // do not change the name or namespace of this type!
    @EnableTestingViaName("Library2.MyString")
    newtype MyString = (Text : String);

    // Used for a unit test; 
    // do not change the name or namespace of this callable!
    @EnableTestingViaName("Library2.LibraryId")
    function LibraryId() : Int {
        return 2;
    }

    // Used for a unit test; 
    // do not change the name or namespace of this callable!
    @EnableTestingViaName("Library2.DllName")
    function DllName() : String {
        return "Library2";
    }
}
