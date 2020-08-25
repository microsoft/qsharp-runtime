// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace NativeOperations
{
    operation IntrinsicBody () : String
    {
        body intrinsic;
    }

    operation DefaultBody () : String
    {
        return "hello";
    }

    operation IntrinsicBodyGeneric<'T>(arg: 'T) : String
    {
        body intrinsic;
    }

    operation DefaultBodyGeneric<'T>(arg: 'T) : 'T
    {
        return arg;
    }
}
