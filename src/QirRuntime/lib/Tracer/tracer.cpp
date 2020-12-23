// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#include "tracer.hpp"

void InitializeTracer()
{
    tracer = std::make_shared<CTracer>();
}