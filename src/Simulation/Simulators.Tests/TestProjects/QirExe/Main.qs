namespace QirExe {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Main(x : Int, (y : Int, z : Int)) : Unit {
        Message("Hello, world!");
        Message($"({x}, ({y}, {z}))");
    }
}
