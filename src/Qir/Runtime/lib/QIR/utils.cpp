// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <stdexcept>
#include <memory>
#include <unordered_set>
#include <iostream>
#include <cstdint>
#include <cstdlib>

#include "QirTypes.hpp"
#include "QirRuntime.hpp"
#include "OutputStream.hpp"


extern "C"
{
    void __quantum__rt__fail_cstr(const char* cstr)
    {
        Microsoft::Quantum::OutputStream::Get() << cstr << std::endl;
        Microsoft::Quantum::OutputStream::Get().flush();
        throw std::runtime_error(cstr);
    }
}
