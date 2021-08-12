// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// https://stackoverflow.com/a/5419388/6362941  redirect std::cout to a string
// Discussion/history and some more info about the output redirection:
//  https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574170031
//  https://github.com/microsoft/qsharp-runtime/pull/511#discussion_r574194191

#include <iostream>
#include "QirRuntime.hpp"
#include "OutputStream.hpp"

namespace Microsoft // Replace with `namespace Microsoft::Quantum` after migration to C++17.
{
namespace Quantum
{
    std::ostream* OutputStream::currentOutputStream = &std::cout; // Output to std::cout by default.

    std::ostream& OutputStream::Get()
    {
        return *currentOutputStream;
    }

    std::ostream& OutputStream::Set(std::ostream& newOStream)
    {
        std::ostream& oldOStream = *currentOutputStream;
        currentOutputStream      = &newOStream;
        return oldOStream;
    }

    OutputStream::ScopedRedirector::ScopedRedirector(std::ostream& newOstream) : old(OutputStream::Set(newOstream))
    {
    }

    OutputStream::ScopedRedirector::~ScopedRedirector()
    {
        OutputStream::Set(old);
    }

    std::ostream& SetOutputStream(std::ostream& newOStream)
    {
        return OutputStream::Set(newOStream);
    }

} // namespace Quantum
} // namespace Microsoft
