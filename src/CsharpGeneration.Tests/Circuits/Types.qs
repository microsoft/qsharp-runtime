namespace Microsoft.Quantum {

    newtype Pair = (Fst : Int, Snd : Int);
    newtype NestedPair = (Double, ((Fst : Bool, String), Snd : Int));
}