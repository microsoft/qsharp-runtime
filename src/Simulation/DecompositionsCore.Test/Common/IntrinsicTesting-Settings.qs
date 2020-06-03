namespace IntrinsicTesting {
    function MaxControls() : Int {
        return 3;
    }

    function MaxTargets() : Int {
        return 3;
    }

    function NumberOfTestRepetitions() : Int {
        return 1;
    }

    function AnglesToTest() : Double[] {
        let pi = Microsoft.Quantum.Math.PI();
        return [
            0.0, 
            pi/8.0,
            pi/4.0,
            pi/2.0,
            3.0 * pi/4.0,
            pi,
            5.0 * pi/4.0,
            3.0 * pi/2.0,
            2.0 * pi,
            3.0 * pi,
            4.0 * pi,
            0.1984 ];
    }

    function FractionsToTest() : (Int,Int)[] {
        return [
            (0,-1),
            (1,1),
            (-1,1),
            (1,2),
            (3,2),
            (-3,2),
            (-1,2),
            (1,3),
            (-1,3),
            (3,4),
            (-1,4),
            //(1, 9223372036854775807),
            (1, 13)
            //(1, -13)
        ];
    }
}