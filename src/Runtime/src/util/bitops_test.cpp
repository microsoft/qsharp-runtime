// Copyright © 2017 Microsoft Corporation. All Rights Reserved.


#include <cassert>
#include <limits>

#include "bitops.hpp"

int main()
{
    using namespace Microsoft::Quantum;

    assert(ilog2(1) == 0);
    assert(ilog2(2) == 1);
    assert(ilog2(4) == 2);
    assert(ilog2(8) == 3);

    return 0;
}
