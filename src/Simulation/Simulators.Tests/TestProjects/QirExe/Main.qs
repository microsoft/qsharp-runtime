namespace QirExe {
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Main(xs : Int[], (y : Int, z : Int)) : Unit {
        Message("Hello, world!");
        Message($"({xs}, ({y}, {z}))");
    }
}
