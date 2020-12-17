// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation QuantumRandomNumberGenerator() : Int {
       mutable randomNumber = 0;

       for (i in 1 .. 64)
       {
           using(q = Qubit())
           {
               H(q);
               set randomNumber = randomNumber <<< 1;
               if (M(q) == One) {
                   set randomNumber += 1;
               }
           }
       }
       return randomNumber;
   } 
}