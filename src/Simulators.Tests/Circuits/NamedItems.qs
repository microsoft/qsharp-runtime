namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    newtype NestedPair = (Double, ((Fst : Bool, String), Snd : Int));

    operation NamedItemAccessTest () : Unit {

		let udt = NestedPair(1.0, ((true, "Hello"), 10));
		if (not udt::Fst) {
			fail "wrong initialization";
		}
		Message($"Snd is {udt::Snd}");		
    }

    operation NamedItemUpdateTest () : Unit {

		let udt1 = NestedPair(1.0, ((true, "Hello"), 10));
		mutable udt2 = udt1 w/ Fst <- false;
		set udt2 w/= Snd <- 5;
		if (not udt1::Fst or udt1::Snd != 10 or udt2::Fst or udt2::Snd != 5) {
			fail "wrong values";
		}
    }

}

