#pragma once

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// To be included by the QIS implementation and QIS tests only. 
// Not to be included by parties outside QIS.

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

extern "C"
{
    QIR_SHARED_API extern char const excStrDrawRandomInt[]; // = "Invalid Argument: minimum > maximum for DrawRandomInt()";
}

QIR_SHARED_API extern std::ostream& SetQOstream(std::ostream & newOStream);